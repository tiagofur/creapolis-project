/**
 * Script para crear usuario de prueba
 * Uso: node create-test-user.js
 */

import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function createTestUser() {
  try {
    console.log("🔧 Creando usuario de prueba...");

    // Usuario de prueba
    const testUser = {
      email: "test@creapolis.com",
      password: "Test123!",
      name: "Usuario de Prueba",
    };

    // Verificar si ya existe
    const existing = await prisma.user.findUnique({
      where: { email: testUser.email },
    });

    if (existing) {
      console.log("⚠️  Usuario ya existe:", testUser.email);
      console.log("📧 Email:", testUser.email);
      console.log("🔑 Password:", testUser.password);
      return;
    }

    // Hash de la contraseña
    const hashedPassword = await bcrypt.hash(testUser.password, 10);

    // Crear usuario
    const user = await prisma.user.create({
      data: {
        email: testUser.email,
        password: hashedPassword,
        name: testUser.name,
      },
    });

    console.log("✅ Usuario creado exitosamente!");
    console.log("");
    console.log("📋 Credenciales de prueba:");
    console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    console.log("📧 Email:    ", testUser.email);
    console.log("🔑 Password: ", testUser.password);
    console.log("👤 Nombre:   ", testUser.name);
    console.log("🆔 ID:       ", user.id);
    console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    console.log("");
    console.log("🚀 Puedes usar estas credenciales para hacer login");
    console.log("   POST http://localhost:3001/api/auth/login");
    console.log("");
  } catch (error) {
    console.error("❌ Error al crear usuario:", error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

// Ejecutar
createTestUser()
  .then(() => {
    console.log("✅ Script completado");
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ Script falló:", error);
    process.exit(1);
  });
