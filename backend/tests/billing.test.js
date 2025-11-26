import request from 'supertest';
import { app, startServer } from '../../src/server.js';
import prisma from '../../src/prisma/client.js';

let server;
let user;
let token;
let workspace;

beforeAll(async () => {
  const { httpServer } = await startServer({ listen: false });
  server = httpServer;

  // Create a user and workspace for the tests
  user = await prisma.user.create({
    data: {
      name: 'Test User',
      email: 'test.user.billing@example.com',
      password: 'password',
    },
  });

  workspace = await prisma.workspace.create({
    data: {
      name: 'Test Workspace',
      ownerId: user.id,
    },
  });

  // Log in the user to get a token
  const res = await request(server).post('/api/auth/login').send({
    email: 'test.user.billing@example.com',
    password: 'password',
  });
  token = res.body.token;
});

afterAll(async () => {
  await prisma.user.delete({ where: { id: user.id } });
  await prisma.workspace.delete({ where: { id: workspace.id } });
  await new Promise(resolve => server.close(resolve));
});

describe('Billing and Plan Limits', () => {
  it('should allow creating a project if within plan limits', async () => {
    // Create a plan with a limit of 1 project
    const plan = await prisma.plan.create({
      data: {
        name: 'Free Plan',
        slug: 'free',
        limits: JSON.stringify({ projects: 1 }),
      },
    });

    // Subscribe the workspace to the plan
    await prisma.subscription.create({
      data: {
        workspaceId: workspace.id,
        planId: plan.id,
        stripeSubscriptionId: 'sub_test_123',
        status: 'ACTIVE',
        currentPeriodEnd: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
      },
    });

    // Create the first project
    const res = await request(server)
      .post('/api/projects')
      .set('Authorization', `Bearer ${token}`)
      .send({
        name: 'First Project',
        workspaceId: workspace.id,
      });

    expect(res.statusCode).toEqual(201);
    expect(res.body.name).toEqual('First Project');
  });

  it('should deny creating a project if plan limit is reached', async () => {
    // Try to create a second project
    const res = await request(server)
      .post('/api/projects')
      .set('Authorization', `Bearer ${token}`)
      .send({
        name: 'Second Project',
        workspaceId: workspace.id,
      });

    expect(res.statusCode).toEqual(403);
    expect(res.body.message).toContain('You have reached the limit');
  });
});
