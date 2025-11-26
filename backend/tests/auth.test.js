import request from "supertest";
import { app, serverReady } from "../src/server.js";
let prisma;
const HAS_DB = !!process.env.DATABASE_URL;

// Mock the email service
jest.mock("../src/services/email.service.js", () => ({
  sendVerificationEmail: jest.fn().mockResolvedValue({ sent: true }),
  sendResetEmail: jest.fn().mockResolvedValue({ sent: true }),
}));

import emailService from "../src/services/email.service.js"; // Import after mock

const suite = HAS_DB ? describe : describe.skip;

suite("Auth Endpoints", () => {
  beforeAll(async () => {
    await serverReady;
    // Clean database before tests
    if (HAS_DB) {
      prisma = (await import("../src/config/database.js")).default;
      await prisma.user.deleteMany();
    }
  });

  afterAll(async () => {
    // Clean up and disconnect
    if (HAS_DB) {
      await prisma.user.deleteMany();
      await prisma.$disconnect();
    }
    jest.clearAllMocks();
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

  describe("Email and Password Flows", () => {
    let resetToken;
    let verificationToken;

    beforeEach(() => {
      // Clear mock calls before each test
      emailService.sendResetEmail.mockClear();
      emailService.sendVerificationEmail.mockClear();
    });

    it("should request a password reset and call email service", async () => {
      const res = await request(app)
        .post("/api/auth/forgot-password")
        .send({ email: "test@example.com" });

      expect(res.statusCode).toBe(200);
      expect(res.body.data).toHaveProperty("token");
      resetToken = res.body.data.token;

      // Check that email service was called
      expect(emailService.sendResetEmail).toHaveBeenCalledTimes(1);
      expect(emailService.sendResetEmail).toHaveBeenCalledWith(
        "test@example.com",
        expect.any(String)
      );
    });

    it("should fail to reset password with invalid token", async () => {
      const res = await request(app).post("/api/auth/reset-password").send({
        token: "invalidtoken",
        newPassword: "newpassword123",
      });

      expect(res.statusCode).toBe(400);
      expect(res.body.success).toBe(false);
    });

    it("should reset password with valid token", async () => {
      const res = await request(app).post("/api/auth/reset-password").send({
        token: resetToken,
        newPassword: "newpassword123",
      });

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);

      // Verify new password works
      const loginRes = await request(app).post("/api/auth/login").send({
        email: "test@example.com",
        password: "newpassword123",
      });
      expect(loginRes.statusCode).toBe(200);
    });

    it("should send a verification email", async () => {
      // Login to get a valid auth token
      const loginRes = await request(app).post("/api/auth/login").send({
        email: "test@example.com",
        password: "newpassword123",
      });
      const authToken = loginRes.body.data.token;

      const res = await request(app)
        .post("/api/auth/verify/send")
        .set("Authorization", `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.data).toHaveProperty("token");
      verificationToken = res.body.data.token;

      expect(emailService.sendVerificationEmail).toHaveBeenCalledTimes(1);
      expect(emailService.sendVerificationEmail).toHaveBeenCalledWith(
        "test@example.com",
        expect.any(String)
      );
    });

    it("should verify email with valid token", async () => {
      const userBefore = await prisma.user.findUnique({
        where: { email: "test@example.com" },
      });
      expect(userBefore.emailVerified).toBe(false);

      const res = await request(app)
        .post("/api/auth/verify")
        .send({ token: verificationToken });

      expect(res.statusCode).toBe(200);
      expect(res.body.data.emailVerified).toBe(true);

      const userAfter = await prisma.user.findUnique({
        where: { email: "test@example.com" },
      });
      expect(userAfter.emailVerified).toBe(true);
    });
  });
});
