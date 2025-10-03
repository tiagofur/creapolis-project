import request from "supertest";
import app from "../src/server.js";
import prisma from "../src/config/database.js";

describe("Project Endpoints", () => {
  let authToken;
  let userId;
  let projectId;

  beforeAll(async () => {
    // Clean database
    await prisma.projectMember.deleteMany();
    await prisma.project.deleteMany();
    await prisma.user.deleteMany();

    // Create test user
    const res = await request(app).post("/api/auth/register").send({
      email: "project-test@example.com",
      password: "password123",
      name: "Project Test User",
    });

    authToken = res.body.data.token;
    userId = res.body.data.user.id;
  });

  afterAll(async () => {
    await prisma.projectMember.deleteMany();
    await prisma.project.deleteMany();
    await prisma.user.deleteMany();
    await prisma.$disconnect();
  });

  describe("POST /api/projects", () => {
    it("should create a new project", async () => {
      const res = await request(app)
        .post("/api/projects")
        .set("Authorization", `Bearer ${authToken}`)
        .send({
          name: "Test Project",
          description: "A test project description",
        });

      expect(res.statusCode).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data.name).toBe("Test Project");
      expect(res.body.data.members).toHaveLength(1);
      projectId = res.body.data.id;
    });

    it("should require authentication", async () => {
      const res = await request(app).post("/api/projects").send({
        name: "Test Project 2",
      });

      expect(res.statusCode).toBe(401);
    });

    it("should validate project name", async () => {
      const res = await request(app)
        .post("/api/projects")
        .set("Authorization", `Bearer ${authToken}`)
        .send({
          name: "AB", // Too short
          description: "Test",
        });

      expect(res.statusCode).toBe(400);
    });
  });

  describe("GET /api/projects", () => {
    it("should list user projects", async () => {
      const res = await request(app)
        .get("/api/projects")
        .set("Authorization", `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.projects).toBeInstanceOf(Array);
      expect(res.body.data.projects.length).toBeGreaterThan(0);
    });

    it("should support pagination", async () => {
      const res = await request(app)
        .get("/api/projects?page=1&limit=5")
        .set("Authorization", `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.data.pagination).toBeDefined();
      expect(res.body.data.pagination.page).toBe(1);
      expect(res.body.data.pagination.limit).toBe(5);
    });
  });

  describe("GET /api/projects/:id", () => {
    it("should get project by id", async () => {
      const res = await request(app)
        .get(`/api/projects/${projectId}`)
        .set("Authorization", `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.id).toBe(projectId);
    });

    it("should return 404 for non-existent project", async () => {
      const res = await request(app)
        .get("/api/projects/999999")
        .set("Authorization", `Bearer ${authToken}`);

      expect(res.statusCode).toBe(404);
    });
  });

  describe("PUT /api/projects/:id", () => {
    it("should update project", async () => {
      const res = await request(app)
        .put(`/api/projects/${projectId}`)
        .set("Authorization", `Bearer ${authToken}`)
        .send({
          name: "Updated Project Name",
          description: "Updated description",
        });

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.name).toBe("Updated Project Name");
    });
  });

  describe("DELETE /api/projects/:id", () => {
    it("should delete project", async () => {
      const res = await request(app)
        .delete(`/api/projects/${projectId}`)
        .set("Authorization", `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
    });
  });
});
