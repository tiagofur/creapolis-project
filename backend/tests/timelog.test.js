import request from "supertest";
import app, { serverReady } from "../src/server.js";
import prisma from "../src/config/database.js";

describe("TimeLog Endpoints", () => {
  let authToken;
  let userId;
  let projectId;
  let taskId;
  let workspaceId;

  beforeAll(async () => {
    await serverReady;
    // Clean database
    await prisma.timeLog.deleteMany();
    await prisma.task.deleteMany();
    await prisma.projectMember.deleteMany();
    await prisma.project.deleteMany();
    await prisma.workspaceMember.deleteMany();
    await prisma.workspaceInvitation.deleteMany();
    await prisma.workspace.deleteMany();
    await prisma.user.deleteMany();

    // Create test user
    const userRes = await request(app).post("/api/auth/register").send({
      email: "timelog-test@example.com",
      password: "password123",
      name: "TimeLog Test User",
    });

    authToken = userRes.body.data.token;
    userId = userRes.body.data.user.id;

    // Create workspace required for project creation
    const workspaceRes = await request(app)
      .post("/api/workspaces")
      .set("Authorization", `Bearer ${authToken}`)
      .send({
        name: "TimeLog Test Workspace",
        description: "Workspace for timelog endpoint tests",
        type: "TEAM",
        settings: {
          timezone: "UTC",
          language: "en",
          allowGuestInvites: true,
          requireEmailVerification: false,
          autoAssignNewMembers: true,
        },
      });

    workspaceId = workspaceRes.body.data.id;

    // Create test project
    const projectRes = await request(app)
      .post("/api/projects")
      .set("Authorization", `Bearer ${authToken}`)
      .send({
        name: "Test Project for TimeLogs",
        description: "A test project description",
        workspaceId,
        status: "ACTIVE",
        startDate: new Date().toISOString(),
        endDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
        memberIds: [userId],
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
    await prisma.workspaceMember.deleteMany();
    await prisma.workspaceInvitation.deleteMany();
    await prisma.workspace.deleteMany();
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

  describe("GET /api/timelogs/heatmap", () => {
    beforeAll(async () => {
      // Create additional time logs for heatmap testing
      const task2Res = await request(app)
        .post(`/api/projects/${projectId}/tasks`)
        .set("Authorization", `Bearer ${authToken}`)
        .send({
          title: "Test Task 2 for Heatmap",
          estimatedHours: 3,
        });

      const task2Id = task2Res.body.data.id;

      // Start and stop tracking to create time logs
      await request(app)
        .post(`/api/tasks/${task2Id}/start`)
        .set("Authorization", `Bearer ${authToken}`);

      await new Promise((resolve) => setTimeout(resolve, 100));

      await request(app)
        .post(`/api/tasks/${task2Id}/stop`)
        .set("Authorization", `Bearer ${authToken}`);
    });

    it("should get productivity heatmap data", async () => {
      const res = await request(app)
        .get("/api/timelogs/heatmap")
        .set("Authorization", `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toBeDefined();
      expect(res.body.data.hourlyData).toBeInstanceOf(Array);
      expect(res.body.data.hourlyData.length).toBe(24);
      expect(res.body.data.weeklyData).toBeInstanceOf(Array);
      expect(res.body.data.weeklyData.length).toBe(7);
      expect(res.body.data.hourlyWeeklyMatrix).toBeInstanceOf(Array);
      expect(res.body.data.hourlyWeeklyMatrix.length).toBe(7);
      expect(res.body.data.totalHours).toBeGreaterThan(0);
      expect(res.body.data.insights).toBeInstanceOf(Array);
    });

    it("should filter heatmap by date range", async () => {
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - 7);
      const endDate = new Date();

      const res = await request(app)
        .get("/api/timelogs/heatmap")
        .query({
          startDate: startDate.toISOString(),
          endDate: endDate.toISOString(),
        })
        .set("Authorization", `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.data.period.startDate).toBeDefined();
      expect(res.body.data.period.endDate).toBeDefined();
    });

    it("should support individual view mode", async () => {
      const res = await request(app)
        .get("/api/timelogs/heatmap")
        .query({ teamView: false })
        .set("Authorization", `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.data).toBeDefined();
    });

    it("should return valid peak hour and day", async () => {
      const res = await request(app)
        .get("/api/timelogs/heatmap")
        .set("Authorization", `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.data.peakHour).toBeGreaterThanOrEqual(0);
      expect(res.body.data.peakHour).toBeLessThanOrEqual(23);
      expect(res.body.data.peakDay).toBeGreaterThanOrEqual(0);
      expect(res.body.data.peakDay).toBeLessThanOrEqual(6);
    });

    it("should return top productive slots", async () => {
      const res = await request(app)
        .get("/api/timelogs/heatmap")
        .set("Authorization", `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.data.topProductiveSlots).toBeInstanceOf(Array);
      expect(res.body.data.topProductiveSlots.length).toBeLessThanOrEqual(3);

      if (res.body.data.topProductiveSlots.length > 0) {
        const slot = res.body.data.topProductiveSlots[0];
        expect(slot.day).toBeGreaterThanOrEqual(0);
        expect(slot.day).toBeLessThanOrEqual(6);
        expect(slot.hour).toBeGreaterThanOrEqual(0);
        expect(slot.hour).toBeLessThanOrEqual(23);
        expect(slot.hours).toBeGreaterThan(0);
      }
    });
  });
});
