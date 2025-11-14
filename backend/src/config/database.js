import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient({
  log:
    process.env.NODE_ENV === "development"
      ? ["query", "info", "warn", "error"]
      : ["error"],
});

const isTest = process.env.NODE_ENV === "test";

// Handle connection errors (skip auto-connect in tests)
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
}

// Graceful shutdown (skip in tests; Jest manages lifecycle)
if (!isTest) {
  process.on("beforeExit", async () => {
    await prisma.$disconnect();
    console.log("🔌 Database disconnected");
  });
}

export default prisma;
