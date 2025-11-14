import request from "supertest";
import { app, serverReady } from "../src/server.js";
import prisma from "../src/config/database.js";
const HAS_DB = !!process.env.DATABASE_URL;

const suite = HAS_DB ? describe : describe.skip;

suite("Auth Endpoints", () => {
  beforeAll(async () => {
    await serverReady;
    // Clean database before tests
    await prisma.user.deleteMany();
  });

  afterAll(async () => {
    // Clean up and disconnect
    await prisma.user.deleteMany();
    await prisma.$disconnect();
  });

  describe("POST /api/auth/register", () => {
    it("should register a new user", async () => {
      const res = await request(app).post("/api/auth/register").send({
        email: "test@example.com",
        password: "password123",
        name: "Test User",
      });

      expect(res.statusCode).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toHaveProperty("user");
      expect(res.body.data).toHaveProperty("token");
      expect(res.body.data.user.email).toBe("test@example.com");
    });

    it("should not register user with existing email", async () => {
      const res = await request(app).post("/api/auth/register").send({
        email: "test@example.com",
        password: "password123",
        name: "Test User 2",
      });

      expect(res.statusCode).toBe(409);
      expect(res.body.success).toBe(false);
    });

    it("should validate email format", async () => {
      const res = await request(app).post("/api/auth/register").send({
        email: "invalid-email",
        password: "password123",
        name: "Test User",
      });

      expect(res.statusCode).toBe(400);
      expect(res.body.success).toBe(false);
    });

    it("should validate password length", async () => {
      const res = await request(app).post("/api/auth/register").send({
        email: "test2@example.com",
        password: "123",
        name: "Test User",
      });

      expect(res.statusCode).toBe(400);
      expect(res.body.success).toBe(false);
    });
  });

  describe("POST /api/auth/login", () => {
    it("should login with valid credentials", async () => {
      const res = await request(app).post("/api/auth/login").send({
        email: "test@example.com",
        password: "password123",
      });

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toHaveProperty("token");
      expect(res.body.data.user.email).toBe("test@example.com");
    });

    it("should not login with invalid password", async () => {
      const res = await request(app).post("/api/auth/login").send({
        email: "test@example.com",
        password: "wrongpassword",
      });

      expect(res.statusCode).toBe(401);
      expect(res.body.success).toBe(false);
    });

    it("should not login with non-existent user", async () => {
      const res = await request(app).post("/api/auth/login").send({
        email: "nonexistent@example.com",
        password: "password123",
      });

      expect(res.statusCode).toBe(401);
      expect(res.body.success).toBe(false);
    });
  });

  describe("GET /api/auth/me", () => {
    let token;

    beforeAll(async () => {
      const res = await request(app).post("/api/auth/login").send({
        email: "test@example.com",
        password: "password123",
      });
      token = res.body.data.token;
    });

    it("should get user profile with valid token", async () => {
      const res = await request(app)
        .get("/api/auth/me")
        .set("Authorization", `Bearer ${token}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.email).toBe("test@example.com");
    });

    it("should not get profile without token", async () => {
      const res = await request(app).get("/api/auth/me");

      expect(res.statusCode).toBe(401);
      expect(res.body.success).toBe(false);
    });

    it("should not get profile with invalid token", async () => {
      const res = await request(app)
        .get("/api/auth/me")
        .set("Authorization", "Bearer invalid-token");

      expect(res.statusCode).toBe(401);
      expect(res.body.success).toBe(false);
    });
  });
});
