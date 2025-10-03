import request from "supertest";
import app from "../src/server.js";
import prisma from "../src/config/database.js";

describe("TimeLog Endpoints", () => {
  let authToken;
  let userId;
  let projectId;
  let taskId;

  beforeAll(async () => {
    // Clean database
    await prisma.timeLog.deleteMany();
    await prisma.task.deleteMany();
    await prisma.projectMember.deleteMany();
    await prisma.project.deleteMany();
    await prisma.user.deleteMany();

    // Create test user
    const userRes = await request(app).post("/api/auth/register").send({
      email: "timelog-test@example.com",
      password: "password123",
      name: "TimeLog Test User",
    });

    authToken = userRes.body.data.token;
    userId = userRes.body.data.user.id;

    // Create test project
    const projectRes = await request(app)
      .post("/api/projects")
      .set("Authorization", `Bearer ${authToken}`)
      .send({
        name: "Test Project for TimeLogs",
      });

    projectId = projectRes.body.data.id;

    // Create test task
    const taskRes = await request(app)
      .post(`/api/projects/${projectId}/tasks`)
      .set("Authorization", `Bearer ${authToken}`)
      .send({
        title: "Test Task for Tracking",
        estimatedHours: 5,
      });

    taskId = taskRes.body.data.id;
  });

  afterAll(async () => {
    await prisma.timeLog.deleteMany();
    await prisma.task.deleteMany();
    await prisma.projectMember.deleteMany();
    await prisma.project.deleteMany();
    await prisma.user.deleteMany();
    await prisma.$disconnect();
  });

  describe("POST /api/tasks/:taskId/start", () => {
    it("should start time tracking", async () => {
      const res = await request(app)
        .post(`/api/tasks/${taskId}/start`)
        .set("Authorization", `Bearer ${authToken}`);

      expect(res.statusCode).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data.taskId).toBe(taskId);
      expect(res.body.data.endTime).toBeNull();
    });

    it("should not allow multiple active time logs", async () => {
      const res = await request(app)
        .post(`/api/tasks/${taskId}/start`)
        .set("Authorization", `Bearer ${authToken}`);

      expect(res.statusCode).toBe(400);
    });
  });

  describe("GET /api/timelogs/active", () => {
    it("should get active time log", async () => {
      const res = await request(app)
        .get("/api/timelogs/active")
        .set("Authorization", `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.data).toBeDefined();
      expect(res.body.data.taskId).toBe(taskId);
    });
  });

  describe("POST /api/tasks/:taskId/stop", () => {
    it("should stop time tracking", async () => {
      // Wait a bit to have a duration
      await new Promise((resolve) => setTimeout(resolve, 100));

      const res = await request(app)
        .post(`/api/tasks/${taskId}/stop`)
        .set("Authorization", `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.endTime).not.toBeNull();
      expect(res.body.data.duration).toBeGreaterThan(0);
    });

    it("should return error if no active log", async () => {
      const res = await request(app)
        .post(`/api/tasks/${taskId}/stop`)
        .set("Authorization", `Bearer ${authToken}`);

      expect(res.statusCode).toBe(400);
    });
  });

  describe("GET /api/tasks/:taskId/timelogs", () => {
    it("should get task time logs", async () => {
      const res = await request(app)
        .get(`/api/tasks/${taskId}/timelogs`)
        .set("Authorization", `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.data).toBeInstanceOf(Array);
      expect(res.body.data.length).toBeGreaterThan(0);
    });
  });

  describe("POST /api/tasks/:taskId/finish", () => {
    it("should finish task and calculate hours", async () => {
      const res = await request(app)
        .post(`/api/tasks/${taskId}/finish`)
        .set("Authorization", `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.status).toBe("COMPLETED");
      expect(res.body.data.actualHours).toBeGreaterThan(0);
    });
  });

  describe("GET /api/timelogs/stats", () => {
    it("should get user statistics", async () => {
      const res = await request(app)
        .get("/api/timelogs/stats")
        .set("Authorization", `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.data.totalHours).toBeGreaterThan(0);
      expect(res.body.data.taskCount).toBeGreaterThan(0);
    });
  });
});
