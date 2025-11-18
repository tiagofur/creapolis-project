import request from "supertest";
import { app, serverReady } from "../src/server.js";
let prisma;
const HAS_DB = !!process.env.DATABASE_URL;

const suite = HAS_DB ? describe : describe.skip;

suite("Auth Reset Password", () => {
  let userEmail = "reset@example.com";

  beforeAll(async () => {
    await serverReady;
    prisma = (await import("../src/config/database.js")).default;
    if (HAS_DB) {
      await prisma.user.deleteMany();
    }
    await request(app).post("/api/auth/register").send({
      email: userEmail,
      password: "password123",
      name: "Reset User",
    });
  });

  afterAll(async () => {
    if (HAS_DB) {
      await prisma.user.deleteMany();
      await prisma.$disconnect();
    }
  });

  it("should issue reset token and reset password", async () => {
    const resToken = await request(app)
      .post("/api/auth/forgot-password")
      .send({ email: userEmail });
    expect(resToken.statusCode).toBe(200);
    const token = resToken.body.data.token;
    expect(token).toBeDefined();

    const resReset = await request(app)
      .post("/api/auth/reset-password")
      .send({ token, newPassword: "newpass123" });
    expect(resReset.statusCode).toBe(200);

    const resLogin = await request(app)
      .post("/api/auth/login")
      .send({ email: userEmail, password: "newpass123" });
    expect(resLogin.statusCode).toBe(200);
    expect(resLogin.body.data.token).toBeDefined();
  });
});