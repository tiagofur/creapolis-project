import dotenv from "dotenv";
dotenv.config({ path: process.env.NODE_ENV === "test" ? ".env.test" : ".env" });
const isTest = process.env.NODE_ENV === "test";
const hasDb = !!process.env.DATABASE_URL;

let prisma;

if (!(isTest && !hasDb)) {
  const { PrismaClient } = await import("@prisma/client");
  prisma = new PrismaClient({
    log:
      process.env.NODE_ENV === "development"
        ? ["query", "info", "warn", "error"]
        : ["error"],
  });

  if (!isTest) {
    prisma
      .$connect()
      .then(() => {
        console.log("✅ Database connected successfully");
      })
      .catch((error) => {
        console.error("❌ Database connection failed:", error);
        process.exit(1);
      });

    process.on("beforeExit", async () => {
      await prisma.$disconnect();
      console.log("🔌 Database disconnected");
    });
  }
} else {
  prisma = null;
}

export default prisma;
