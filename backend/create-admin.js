import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

const createAdminUser = async () => {
  try {
    console.log('Creating admin user...');

    const adminEmail = 'admin@creapolis.com';
    const adminPassword = 'admin123';

    // Check if admin user already exists
    const existingAdmin = await prisma.user.findFirst({
      where: { email: adminEmail }
    });

    if (existingAdmin) {
      console.log('Admin user already exists:', adminEmail);
      return existingAdmin;
    }

    // Hash the password
    const hashedPassword = await bcrypt.hash(adminPassword, 10);

    // Create admin user
    const adminUser = await prisma.user.create({
      data: {
        email: adminEmail,
        password: hashedPassword,
        name: 'Administrador Creapolis',
        role: 'ADMIN'
      }
    });

    console.log('Admin user created successfully!');
    console.log('Email:', adminEmail);
    console.log('Password:', adminPassword);
    console.log('Role:', adminUser.role);

    return adminUser;
  } catch (error) {
    console.error('Error creating admin user:', error);
  } finally {
    await prisma.$disconnect();
  }
};

createAdminUser();