process.env.NODE_ENV = process.env.NODE_ENV || "test";
// Avoid DB-bound tests running when DB is not available
process.env.DATABASE_URL = "";