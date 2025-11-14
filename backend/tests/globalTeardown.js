export default async () => {
  const server = global.__HTTP_SERVER__;
  if (server) {
    await new Promise((resolve) => server.close(resolve));
  }
  try {
    const { default: prisma } = await import("../src/config/database.js");
    await prisma.$disconnect();
  } catch {}
};
