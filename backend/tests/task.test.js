import request from "supertest";
import app from "../src/server.js";
import prisma from "../src/config/database.js";

describe("Task Endpoints", () => {
  let authToken;
  let userId;
  let projectId;
  let taskId;

  beforeAll(async () => {
    // Clean database
    await prisma.timeLog.deleteMany();
    await prisma.dependency.deleteMany();
    await prisma.task.deleteMany();
    await prisma.projectMember.deleteMany();
    await prisma.project.deleteMany();
    await prisma.user.deleteMany();

    // Create test user
    const userRes = await request(app).post("/api/auth/register").send({
      email: "task-test@example.com",
      password: "password123",
      name: "Task Test User",
    });

    authToken = userRes.body.data.token;
    userId = userRes.body.data.user.id;

    // Create test project
    const projectRes = await request(app)
      .post("/api/projects")
      .set("Authorization", `Bearer ${authToken}`)
      .send({
        name: "Test Project for Tasks",
        description: "Test description",
      });

    projectId = projectRes.body.data.id;
  });

  afterAll(async () => {
    await prisma.timeLog.deleteMany();
    await prisma.dependency.deleteMany();
    await prisma.task.deleteMany();
    await prisma.projectMember.deleteMany();
    await prisma.project.deleteMany();
    await prisma.user.deleteMany();
    await prisma.$disconnect();
  });

  describe("POST /api/projects/:projectId/tasks", () => {
    it("should create a new task", async () => {
      const res = await request(app)
        .post(`/api/projects/${projectId}/tasks`)
        .set("Authorization", `Bearer ${authToken}`)
        .send({
          title: "Test Task",
          description: "A test task description",
          estimatedHours: 5,
          assigneeId: userId,
        });

      expect(res.statusCode).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data.title).toBe("Test Task");
      expect(res.body.data.estimatedHours).toBe(5);
      taskId = res.body.data.id;
    });

    it("should validate required fields", async () => {
      const res = await request(app)
        .post(`/api/projects/${projectId}/tasks`)
        .set("Authorization", `Bearer ${authToken}`)
        .send({
          title: "AB", // Too short
          estimatedHours: -1, // Invalid
        });

      expect(res.statusCode).toBe(400);
    });
  });

  describe("GET /api/projects/:projectId/tasks", () => {
    it("should list project tasks", async () => {
      const res = await request(app)
        .get(`/api/projects/${projectId}/tasks`)
        .set("Authorization", `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toBeInstanceOf(Array);
      expect(res.body.data.length).toBeGreaterThan(0);
    });

    it("should filter by status", async () => {
      const res = await request(app)
        .get(`/api/projects/${projectId}/tasks?status=PLANNED`)
        .set("Authorization", `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.data.every((task) => task.status === "PLANNED")).toBe(
        true
      );
    });
  });

  describe("PUT /api/projects/:projectId/tasks/:taskId", () => {
    it("should update task", async () => {
      const res = await request(app)
        .put(`/api/projects/${projectId}/tasks/${taskId}`)
        .set("Authorization", `Bearer ${authToken}`)
        .send({
          title: "Updated Task Title",
          status: "IN_PROGRESS",
        });

      expect(res.statusCode).toBe(200);
      expect(res.body.data.title).toBe("Updated Task Title");
      expect(res.body.data.status).toBe("IN_PROGRESS");
    });
  });

  describe("Task Dependencies", () => {
    let task2Id;

    beforeAll(async () => {
      const res = await request(app)
        .post(`/api/projects/${projectId}/tasks`)
        .set("Authorization", `Bearer ${authToken}`)
        .send({
          title: "Task 2",
          description: "Second task",
          estimatedHours: 3,
        });
      task2Id = res.body.data.id;
    });

    it("should add dependency", async () => {
      const res = await request(app)
        .post(`/api/projects/${projectId}/tasks/${task2Id}/dependencies`)
        .set("Authorization", `Bearer ${authToken}`)
        .send({
          predecessorId: taskId,
          type: "FINISH_TO_START",
        });

      expect(res.statusCode).toBe(201);
      expect(res.body.data.predecessorId).toBe(taskId);
    });

    it("should prevent self-dependency", async () => {
      const res = await request(app)
        .post(`/api/projects/${projectId}/tasks/${taskId}/dependencies`)
        .set("Authorization", `Bearer ${authToken}`)
        .send({
          predecessorId: taskId,
        });

      expect(res.statusCode).toBe(400);
    });
  });
});
