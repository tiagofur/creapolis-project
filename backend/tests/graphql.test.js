import { describe, it, expect, beforeAll, afterAll } from "@jest/globals";
import request from "supertest";
import app, { serverReady } from "../src/server.js";
import prisma from "../src/config/database.js";

describe("GraphQL API Tests", () => {
  let authToken;
  let userId;
  let workspaceId;

  beforeAll(async () => {
    await serverReady;
    // Clean database before tests
    await prisma.timeLog.deleteMany({});
    await prisma.task.deleteMany({});
    await prisma.projectMember.deleteMany({});
    await prisma.project.deleteMany({});
    await prisma.workspaceMember.deleteMany({});
    await prisma.workspaceInvitation.deleteMany({});
    await prisma.workspace.deleteMany({});
    await prisma.user.deleteMany({});
  });

  afterAll(async () => {
    // Clean up and disconnect
    await prisma.timeLog.deleteMany({});
    await prisma.task.deleteMany({});
    await prisma.projectMember.deleteMany({});
    await prisma.project.deleteMany({});
    await prisma.workspaceMember.deleteMany({});
    await prisma.workspaceInvitation.deleteMany({});
    await prisma.workspace.deleteMany({});
    await prisma.user.deleteMany({});
    await prisma.$disconnect();
  });

  describe("Authentication", () => {
    it("should register a new user via GraphQL", async () => {
      const mutation = `
        mutation {
          register(input: {
            email: "graphql@example.com"
            password: "password123"
            name: "GraphQL User"
          }) {
            token
            user {
              id
              email
              name
              role
            }
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .send({ query: mutation })
        .expect(200);

      expect(res.body.data).toBeDefined();
      expect(res.body.data.register).toBeDefined();
      expect(res.body.data.register.user.email).toBe("graphql@example.com");
      expect(res.body.data.register.token).toBeDefined();

      authToken = res.body.data.register.token;
      userId = parseInt(res.body.data.register.user.id, 10);
    });

    it("should login a user via GraphQL", async () => {
      const mutation = `
        mutation {
          login(input: {
            email: "graphql@example.com"
            password: "password123"
          }) {
            token
            user {
              id
              email
              name
            }
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .send({ query: mutation })
        .expect(200);

      expect(res.body.data).toBeDefined();
      expect(res.body.data.login).toBeDefined();
      expect(res.body.data.login.user.email).toBe("graphql@example.com");
      expect(res.body.data.login.token).toBeDefined();
    });

    it("should get current user profile", async () => {
      const query = `
        query {
          me {
            id
            email
            name
            role
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query })
        .expect(200);

      expect(res.body.data).toBeDefined();
      expect(res.body.data.me).toBeDefined();
      expect(res.body.data.me.email).toBe("graphql@example.com");
    });

    it("should fail to get profile without token", async () => {
      const query = `
        query {
          me {
            id
            email
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .send({ query })
        .expect(200);

      expect(res.body.errors).toBeDefined();
      expect(res.body.errors[0].code).toBe("UNAUTHENTICATED");
    });

    it("should update user profile", async () => {
      const mutation = `
        mutation {
          updateProfile(name: "Updated Name") {
            id
            name
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query: mutation })
        .expect(200);

      expect(res.body.data).toBeDefined();
      expect(res.body.data.updateProfile.name).toBe("Updated Name");
    });
  });

  describe("Workspaces", () => {
    it("should create a workspace", async () => {
      const mutation = `
        mutation {
          createWorkspace(input: {
            name: "Test Workspace"
            description: "A test workspace"
            type: TEAM
          }) {
            id
            name
            type
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query: mutation })
        .expect(200);

      expect(res.body.data).toBeDefined();
      expect(res.body.data.createWorkspace).toBeDefined();
      expect(res.body.data.createWorkspace.name).toBe("Test Workspace");

      workspaceId = parseInt(res.body.data.createWorkspace.id, 10);
    });

    it("should list workspaces", async () => {
      const query = `
        query {
          workspaces(page: 1, limit: 10) {
            edges {
              node {
                id
                name
                type
              }
            }
            pageInfo {
              totalCount
              hasNextPage
            }
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query })
        .expect(200);
      expect(res.body.data).toBeDefined();
      expect(res.body.data.workspaces).toBeDefined();
      expect(res.body.data.workspaces.edges.length).toBeGreaterThan(0);
    });
  });

  describe("Projects", () => {
    let projectId;

    beforeAll(async () => {
      if (!workspaceId) {
        const mutation = `
          mutation {
            createWorkspace(input: {
              name: "Project Test Workspace"
              description: "Workspace created for GraphQL project tests"
              type: TEAM
            }) {
              id
            }
          }
        `;

        const res = await request(app)
          .post("/graphql")
          .set("Authorization", `Bearer ${authToken}`)
          .send({ query: mutation })
          .expect(200);

        workspaceId = parseInt(res.body.data.createWorkspace.id, 10);
      }
    });

    it("should create a project", async () => {
      const startDate = new Date().toISOString();
      const endDate = new Date(
        Date.now() + 7 * 24 * 60 * 60 * 1000
      ).toISOString();
      const mutation = `
        mutation {
          createProject(input: {
            name: "Test Project"
            description: "A test project"
            workspaceId: ${workspaceId}
            status: ACTIVE
            startDate: "${startDate}"
            endDate: "${endDate}"
          }) {
            id
            name
            description
            status
            startDate
            endDate
            managerId
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query: mutation })
        .expect(200);

      expect(res.body.data).toBeDefined();
      expect(res.body.data.createProject).toBeDefined();
      expect(res.body.data.createProject.name).toBe("Test Project");
      expect(res.body.data.createProject.status).toBe("ACTIVE");
      expect(
        new Date(res.body.data.createProject.startDate).toISOString()
      ).toBe(new Date(startDate).toISOString());
      expect(new Date(res.body.data.createProject.endDate).toISOString()).toBe(
        new Date(endDate).toISOString()
      );
      expect(res.body.data.createProject.managerId).toBe(userId);

      projectId = parseInt(res.body.data.createProject.id, 10);
    });

    it("should list projects", async () => {
      const query = `
        query {
          projects(page: 1, limit: 10) {
            edges {
              node {
                id
                name
                description
                status
                startDate
                endDate
              }
            }
            pageInfo {
              totalCount
            }
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query })
        .expect(200);

      expect(res.body.data).toBeDefined();
      expect(res.body.data.projects.edges.length).toBeGreaterThan(0);
    });

    it("should get project statistics", async () => {
      const query = `
        query {
          projectStatistics(id: "${projectId}") {
            totalTasks
            completedTasks
            inProgressTasks
            completionPercentage
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query })
        .expect(200);

      expect(res.body.data).toBeDefined();
      expect(res.body.data.projectStatistics).toBeDefined();
      expect(res.body.data.projectStatistics.totalTasks).toBe(0);
    });
  });

  describe("Tasks", () => {
    let taskWorkspaceId;
    let projectId;
    let taskId;

    beforeAll(async () => {
      const workspaceMutation = `
        mutation {
          createWorkspace(input: {
            name: "Task Test Workspace"
            description: "Workspace for GraphQL task tests"
            type: TEAM
          }) {
            id
          }
        }
      `;

      const workspaceRes = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query: workspaceMutation })
        .expect(200);

      taskWorkspaceId = parseInt(workspaceRes.body.data.createWorkspace.id, 10);

      const startDate = new Date().toISOString();
      const endDate = new Date(
        Date.now() + 7 * 24 * 60 * 60 * 1000
      ).toISOString();

      const projectMutation = `
        mutation {
          createProject(input: {
            name: "Task Test Project"
            description: "Project for GraphQL task tests"
            workspaceId: ${taskWorkspaceId}
            status: ACTIVE
            startDate: "${startDate}"
            endDate: "${endDate}"
          }) {
            id
          }
        }
      `;

      const projectRes = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query: projectMutation })
        .expect(200);

      projectId = parseInt(projectRes.body.data.createProject.id, 10);
    });

    it("should create a task", async () => {
      const mutation = `
        mutation {
          createTask(input: {
            title: "Test Task"
            description: "A test task"
            estimatedHours: 4
            projectId: ${projectId}
          }) {
            id
            title
            status
            estimatedHours
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query: mutation })
        .expect(200);

      expect(res.body.data).toBeDefined();
      expect(res.body.data.createTask).toBeDefined();
      expect(res.body.data.createTask.title).toBe("Test Task");
      expect(res.body.data.createTask.status).toBe("PLANNED");

      taskId = res.body.data.createTask.id;
    });

    it("should update task status", async () => {
      const mutation = `
        mutation {
          updateTask(id: "${taskId}", input: {
            status: IN_PROGRESS
          }) {
            id
            status
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query: mutation })
        .expect(200);

      expect(res.body.data).toBeDefined();
      expect(res.body.data.updateTask.status).toBe("IN_PROGRESS");
    });

    it("should list my tasks", async () => {
      const query = `
        query {
          myTasks(page: 1, limit: 10) {
            edges {
              node {
                id
                title
                status
              }
            }
            pageInfo {
              totalCount
            }
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query })
        .expect(200);

      expect(res.body.data).toBeDefined();
      expect(res.body.data.myTasks).toBeDefined();
    });
  });

  describe("Error Handling", () => {
    it("should return error for invalid email", async () => {
      const mutation = `
        mutation {
          register(input: {
            email: "invalid-email"
            password: "password123"
            name: "Test User"
          }) {
            token
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .send({ query: mutation })
        .expect(200);

      // GraphQL always returns 200, errors are in the response
      expect(res.body.errors).toBeDefined();
      expect(res.body.errors[0].code).toBe("BAD_REQUEST");
    });

    it("should return error for unauthorized access", async () => {
      const query = `
        query {
          users(page: 1, limit: 10) {
            edges {
              node {
                id
                email
              }
            }
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query })
        .expect(200);

      expect(res.body.errors).toBeDefined();
      expect(res.body.errors[0].code).toBe("FORBIDDEN");
    });
  });
});
