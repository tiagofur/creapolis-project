import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function seedForum() {
  try {
    console.log('🌱 Starting forum seeding...');

    // Create forum categories
    const categories = [
      {
        name: 'General Discussion',
        description: 'General topics about productivity, work-life balance, and wellness',
        color: '#3B82F6',
        icon: '💬',
        sortOrder: 1
      },
      {
        name: 'Productivity Tips',
        description: 'Share and discuss productivity techniques and strategies',
        color: '#10B981',
        icon: '🚀',
        sortOrder: 2
      },
      {
        name: 'Work-Life Balance',
        description: 'Discussions about maintaining healthy work-life balance',
        color: '#F59E0B',
        icon: '⚖️',
        sortOrder: 3
      },
      {
        name: 'Burnout Prevention',
        description: 'Support and advice for preventing and managing burnout',
        color: '#EF4444',
        icon: '🛡️',
        sortOrder: 4
      },
      {
        name: 'Project Management',
        description: 'Best practices and discussions about project management',
        color: '#8B5CF6',
        icon: '📊',
        sortOrder: 5
      },
      {
        name: 'Creapolis App',
        description: 'Questions, feedback, and discussions about the Creapolis app',
        color: '#06B6D4',
        icon: '🏛️',
        sortOrder: 6
      }
    ];

    for (const categoryData of categories) {
      const existingCategory = await prisma.forumCategory.findUnique({
        where: { name: categoryData.name }
      });

      if (!existingCategory) {
        const slug = categoryData.name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
        await prisma.forumCategory.create({ 
          data: {
            ...categoryData,
            slug
          } 
        });
        console.log(`✅ Created forum category: ${categoryData.name}`);
      } else {
        console.log(`⚠️  Forum category already exists: ${categoryData.name}`);
      }
    }

    // Get the first admin user
    const adminUser = await prisma.user.findFirst({
      where: { role: 'ADMIN' }
    });

    if (!adminUser) {
      console.log('❌ No admin user found. Please create an admin user first.');
      return;
    }

    // Get all categories
    const allCategories = await prisma.forumCategory.findMany();

    // Create sample threads
    const sampleThreads = [
      {
        title: 'Welcome to the Creapolis Community Forum!',
        content: `Welcome to our community forum! This is a place where we can discuss productivity, work-life balance, and wellness topics together.

Feel free to share your experiences, ask questions, and help others in their journey towards better productivity and well-being.

Let's build a supportive community together! 🌟`,
        categoryId: allCategories[0].id, // General Discussion
        authorId: adminUser.id,
        isPinned: true
      },
      {
        title: 'Best productivity tips for remote workers?',
        content: `I've been working remotely for the past year and I'm always looking for ways to improve my productivity. What are your favorite productivity tips that work well in a remote setting?

I personally find that:
- Having a dedicated workspace helps
- Using time-blocking techniques
- Taking regular breaks
- Setting clear boundaries

What works for you?`,
        categoryId: allCategories[1].id, // Productivity Tips
        authorId: adminUser.id,
        isPinned: false
      },
      {
        title: 'How do you maintain work-life balance?',
        content: `Work-life balance is something I struggle with, especially when working from home. The lines between work and personal life seem to blur together.

How do you maintain a healthy work-life balance? Do you have any specific routines or practices that help you switch off from work mode?

Looking forward to hearing your strategies!`,
        categoryId: allCategories[2].id, // Work-Life Balance
        authorId: adminUser.id,
        isPinned: false
      },
      {
        title: 'Signs of burnout and how to prevent it',
        content: `Burnout is a serious issue that affects many professionals. Let's discuss the early warning signs and prevention strategies.

Some common signs I've noticed:
- Constant fatigue
- Loss of motivation
- Increased irritability
- Difficulty concentrating
- Physical symptoms like headaches

Prevention strategies that work for me:
- Regular exercise
- Mindfulness practices
- Setting realistic goals
- Taking regular breaks
- Maintaining social connections

What are your experiences with burnout prevention?`,
        categoryId: allCategories[3].id, // Burnout Prevention
        authorId: adminUser.id,
        isPinned: false
      }
    ];

    for (const threadData of sampleThreads) {
      const existingThread = await prisma.forumThread.findFirst({
        where: { title: threadData.title }
      });

      if (!existingThread) {
        // Generate unique slug
        let slug = threadData.title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
        let counter = 1;
        let uniqueSlug = slug;

        while (await prisma.forumThread.findUnique({ where: { slug: uniqueSlug } })) {
          uniqueSlug = `${slug}-${counter}`;
          counter++;
        }

        await prisma.forumThread.create({
          data: {
            ...threadData,
            slug: uniqueSlug,
            lastReplyAt: new Date()
          }
        });
        console.log(`✅ Created forum thread: ${threadData.title}`);
      } else {
        console.log(`⚠️  Forum thread already exists: ${threadData.title}`);
      }
    }

    console.log('✅ Forum seeding completed successfully!');
  } catch (error) {
    console.error('❌ Error seeding forum:', error);
  } finally {
    await prisma.$disconnect();
  }
}

// Run the seed function
seedForum();