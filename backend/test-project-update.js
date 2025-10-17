// Test Project Update
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient({
  log: ["query", "info", "warn", "error"],
});

async function testProjectUpdate() {
  try {
    console.log("🔍 Testing project update functionality...\n");

    // 1. Buscar un proyecto existente
    const projects = await prisma.project.findMany({
      take: 1,
      include: {
        workspace: true,
        manager: true,
      },
    });

    if (projects.length === 0) {
      console.log("⚠️  No hay proyectos en la base de datos para probar");
      return;
    }

    const project = projects[0];
    console.log("📋 Proyecto encontrado:");
    console.log(`   ID: ${project.id}`);
    console.log(`   Nombre: ${project.name}`);
    console.log(`   Status: ${project.status}`);
    console.log(`   Workspace: ${project.workspace.name}`);
    console.log(`   Progress: ${project.progress}\n`);

    // 2. Actualizar el proyecto
    const updatedData = {
      name: `${project.name} - Updated`,
      description: `Actualizado el ${new Date().toLocaleString()}`,
      status: project.status === "PLANNED" ? "ACTIVE" : "PLANNED",
      progress: Math.min(project.progress + 10, 100),
    };

    console.log("🔄 Actualizando proyecto con:");
    console.log(JSON.stringify(updatedData, null, 2));
    console.log("");

    const updatedProject = await prisma.project.update({
      where: { id: project.id },
      data: updatedData,
      include: {
        workspace: true,
        manager: true,
        members: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                email: true,
              },
            },
          },
        },
      },
    });

    console.log("✅ Proyecto actualizado exitosamente:");
    console.log(`   ID: ${updatedProject.id}`);
    console.log(`   Nombre: ${updatedProject.name}`);
    console.log(`   Descripción: ${updatedProject.description}`);
    console.log(`   Status: ${updatedProject.status}`);
    console.log(`   Progress: ${updatedProject.progress}`);
    console.log(`   Updated At: ${updatedProject.updatedAt}\n`);

    // 3. Verificar la actualización
    const verifyProject = await prisma.project.findUnique({
      where: { id: project.id },
    });

    if (
      verifyProject.name === updatedData.name &&
      verifyProject.status === updatedData.status &&
      verifyProject.progress === updatedData.progress
    ) {
      console.log(
        "✅ Verificación exitosa: Los cambios se guardaron correctamente"
      );
    } else {
      console.log("❌ Error: Los cambios no se guardaron correctamente");
      console.log("Esperado:", updatedData);
      console.log("Obtenido:", {
        name: verifyProject.name,
        status: verifyProject.status,
        progress: verifyProject.progress,
      });
    }

    // 4. Mostrar estructura completa del proyecto
    console.log("\n📊 Estructura completa del proyecto:");
    console.log(JSON.stringify(updatedProject, null, 2));
  } catch (error) {
    console.error("❌ Error en la prueba:", error);
  } finally {
    await prisma.$disconnect();
  }
}

testProjectUpdate();
