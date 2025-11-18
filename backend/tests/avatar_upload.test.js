import request from "supertest";
import { app, serverReady } from "../src/server.js";
let prisma;
const HAS_DB = !!process.env.DATABASE_URL;

const suite = HAS_DB ? describe : describe.skip;

suite("Avatar Upload", () => {
  let authToken;

  beforeAll(async () => {
    await serverReady;
    prisma = (await import("../src/config/database.js")).default;
    if (HAS_DB) {
      await prisma.user.deleteMany();
    }
    const res = await request(app).post("/api/auth/register").send({
      email: "avatar@example.com",
      password: "password123",
      name: "Avatar User",
    });
    authToken = res.body.data.token;
  });

  afterAll(async () => {
    if (HAS_DB) {
      await prisma.user.deleteMany();
      await prisma.$disconnect();
    }
  });

  it("should upload avatar and update profile url", async () => {
    const base64 = Buffer.from("PNG", "utf8").toString("base64");
    const res = await request(app)
      .post("/api/auth/avatar")
      .set("Authorization", `Bearer ${authToken}`)
      .send({ avatarBase64: base64, contentType: "image/png" });
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.avatarUrl).toContain("/uploads/avatars/");
  });
});