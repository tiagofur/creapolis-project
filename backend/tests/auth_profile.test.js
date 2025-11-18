import request from "supertest";
import { app, serverReady } from "../src/server.js";
let prisma;
const HAS_DB = !!process.env.DATABASE_URL;

const suite = HAS_DB ? describe : describe.skip;

suite("Auth Profile Update", () => {
  let authToken;

  beforeAll(async () => {
    await serverReady;
    prisma = (await import("../src/config/database.js")).default;
    if (HAS_DB) {
      await prisma.user.deleteMany();
    }

    const res = await request(app).post("/api/auth/register").send({
      email: "profile-update@example.com",
      password: "password123",
      name: "Original Name",
    });
    authToken = res.body.data.token;
  });

  afterAll(async () => {
    if (HAS_DB) {
      await prisma.user.deleteMany();
      await prisma.$disconnect();
    }
  });

  it("should update user name and avatarUrl", async () => {
    const res = await request(app)
      .put("/api/auth/me")
      .set("Authorization", `Bearer ${authToken}`)
      .send({ name: "Updated User", avatarUrl: "https://example.com/avatar.png" });

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.name).toBe("Updated User");
    expect(res.body.data.avatarUrl).toBe("https://example.com/avatar.png");
  });

  it("should validate avatarUrl format", async () => {
    const res = await request(app)
      .put("/api/auth/me")
      .set("Authorization", `Bearer ${authToken}`)
      .send({ avatarUrl: "not-a-url" });

    expect(res.statusCode).toBe(400);
    expect(res.body.success).toBe(false);
  });
});