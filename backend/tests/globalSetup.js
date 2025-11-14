export default async () => {
  process.env.NODE_ENV = "test";
  const { startServer } = await import("../src/server.js");
  const { httpServer } = await startServer({ listen: false });
  global.__HTTP_SERVER__ = httpServer;
};
