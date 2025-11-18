import request from "supertest";
import { app, serverReady } from "../src/server.js";
let prisma;
const HAS_DB = !!process.env.DATABASE_URL;

const suite = HAS_DB ? describe : describe.skip;

suite("Auth Email Verification", () => {
  let authToken;
  let userId;

  beforeAll(async () => {
    await serverReady;
    prisma = (await import("../src/config/database.js")).default;
    if (HAS_DB) {
      await prisma.user.deleteMany();
    }
    const res = await request(app).post("/api/auth/register").send({
      email: "verify@example.com",
      password: "password123",
      name: "Verify User",
    });
    authToken = res.body.data.token;
    userId = res.body.data.user.id;
  });

  afterAll(async () => {
    if (HAS_DB) {
      await prisma.user.deleteMany();
      await prisma.$disconnect();
    }
  });

  it("should generate verification token and verify", async () => {
    const sendRes = await request(app)
      .post("/api/auth/verify/send")
      .set("Authorization", `Bearer ${authToken}`)
      .send();
    expect(sendRes.statusCode).toBe(200);
    const token = sendRes.body.data.token;
    expect(token).toBeDefined();

    const verifyRes = await request(app)
      .post("/api/auth/verify")
      .send({ token });
    expect(verifyRes.statusCode).toBe(200);
    expect(verifyRes.body.data.emailVerified).toBe(true);
  });
});