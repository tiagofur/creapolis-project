import request from "supertest";
import { app, serverReady } from "../src/server.js";
let prisma;
const HAS_DB = !!process.env.DATABASE_URL;

const suite = HAS_DB ? describe : describe.skip;

suite("AI Routes", () => {
  let authToken;
  let workspaceId;
  let projectId;
  let taskId;

  beforeAll(async () => {
    await serverReady;
    prisma = (await import("../src/config/database.js")).default;
    // Clean minimal tables
    if (HAS_DB) {
      await prisma.categorySuggestion.deleteMany();
      await prisma.categoryFeedback.deleteMany();
      await prisma.timeLog.deleteMany();
      await prisma.dependency.deleteMany();
      await prisma.task.deleteMany();
      await prisma.projectMember.deleteMany();
      await prisma.project.deleteMany();
      await prisma.workspaceMember.deleteMany();
      await prisma.workspaceInvitation.deleteMany();
      await prisma.workspace.deleteMany();
      await prisma.user.deleteMany();
    }

    const userRes = await request(app).post("/api/auth/register").send({
      email: "ai-routes@example.com",
      password: "password123",
      name: "AI Tester",
    });
    authToken = userRes.body.data.token;

    const wsRes = await request(app)
      .post("/api/workspaces")
      .set("Authorization", `Bearer ${authToken}`)
      .send({ name: "AI Workspace" });
    workspaceId = wsRes.body.data.id;

    const startDate = new Date().toISOString();
    const endDate = new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString();
    const projectRes = await request(app)
      .post("/api/projects")
      .set("Authorization", `Bearer ${authToken}`)
      .send({ name: "AI Project", workspaceId, startDate, endDate, status: "ACTIVE" });
    projectId = projectRes.body.data.id;

    const taskRes = await request(app)
      .post(`/api/projects/${projectId}/tasks`)
      .set("Authorization", `Bearer ${authToken}`)
      .send({ title: "Task for AI", estimatedHours: 2 });
    taskId = taskRes.body.data.id;
  });

  afterAll(async () => {
    if (HAS_DB) {
      await prisma.categorySuggestion.deleteMany();
      await prisma.categoryFeedback.deleteMany();
      await prisma.task.deleteMany();
      await prisma.projectMember.deleteMany();
      await prisma.project.deleteMany();
      await prisma.workspaceMember.deleteMany();
      await prisma.workspaceInvitation.deleteMany();
      await prisma.workspace.deleteMany();
      await prisma.user.deleteMany();
      await prisma.$disconnect();
    }
  });

  it("should require auth for AI categorize route", async () => {
    const res = await request(app).post("/api/ai/categorize").send({
      taskId,
      title: "Implementar API de usuarios",
    });
    expect(res.statusCode).toBe(401);
  });

  it("should categorize task when authenticated", async () => {
    const res = await request(app)
      .post("/api/ai/categorize")
      .set("Authorization", `Bearer ${authToken}`)
      .send({ taskId, title: "Implementar API de usuarios" });

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data).toHaveProperty("suggestedCategory");
  });
});