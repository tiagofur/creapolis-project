// Test Database Connection
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient({
  log: ["query", "info", "warn", "error"],
});

async function testConnection() {
  try {
    console.log("🔍 Testing database connection...");

    // Test basic connection
    await prisma.$connect();
    console.log("✅ Database connected successfully");

    // Test query
    const userCount = await prisma.user.count();
    console.log(`✅ Database query successful - Found ${userCount} users`);

    // Get database version
    const result = await prisma.$queryRaw`SELECT version();`;
    console.log("✅ PostgreSQL version:", result[0].version);
  } catch (error) {
    console.error("❌ Database connection failed:", error);
    console.error("Error details:", {
      message: error.message,
      code: error.code,
      meta: error.meta,
    });
  } finally {
    await prisma.$disconnect();
    console.log("🔌 Disconnected from database");
  }
}

testConnection();
