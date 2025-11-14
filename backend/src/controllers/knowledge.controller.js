import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

// Knowledge Base Categories
const getKnowledgeCategories = async (req, res) => {
  try {
    const categories = await prisma.knowledgeCategory.findMany({
      where: { isActive: true },
      orderBy: { sortOrder: 'asc' },
      include: {
        _count: {
          select: { articles: { where: { status: 'PUBLISHED' } } }
        }
      }
    });

    res.json(categories);
  } catch (error) {
    console.error('Error fetching knowledge categories:', error);
    res.status(500).json({ error: 'Error fetching knowledge categories' });
  }
};

const createKnowledgeCategory = async (req, res) => {
  try {
    const { name, description, color, icon, parentId, sortOrder } = req.body;
    
    const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
    
    const category = await prisma.knowledgeCategory.create({
      data: {
        name,
        slug,
        description,
        color,
        icon,
        parentId: parentId || null,
        sortOrder: sortOrder || 0
      }
    });

    res.json(category);
  } catch (error) {
    console.error('Error creating knowledge category:', error);
    res.status(500).json({ error: 'Error creating knowledge category' });
  }
};

// Knowledge Articles
const getKnowledgeArticles = async (req, res) => {
  try {
    const { 
      categoryId, 
      difficulty, 
      page = 1, 
      limit = 20, 
      search = '', 
      sortBy = 'createdAt',
      featured = false
    } = req.query;
    
    const skip = (page - 1) * limit;

    const where = {
      status: 'PUBLISHED',
      ...(categoryId && { categoryId: parseInt(categoryId) }),
      ...(difficulty && { difficulty }),
      ...(featured === 'true' && { isFeatured: true }),
      ...(search && {
        OR: [
          { title: { contains: search, mode: 'insensitive' } },
          { content: { contains: search, mode: 'insensitive' } },
          { tags: { hasSome: [search] } }
        ]
      })
    };

    const articles = await prisma.knowledgeArticle.findMany({
      where,
      skip: parseInt(skip),
      take: parseInt(limit),
      orderBy: [
        { isFeatured: 'desc' },
        sortBy === 'views' ? { views: 'desc' } : { createdAt: 'desc' }
      ],
      include: {
        author: {
          select: { id: true, name: true, avatarUrl: true }
        },
        category: {
          select: { id: true, name: true, slug: true, color: true }
        },
        _count: {
          select: { likesRelation: true }
        }
      }
    });

    const total = await prisma.knowledgeArticle.count({ where });

    res.json({
      articles,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error fetching knowledge articles:', error);
    res.status(500).json({ error: 'Error fetching knowledge articles' });
  }
};

const getKnowledgeArticle = async (req, res) => {
  try {
    const { slug } = req.params;

    const article = await prisma.knowledgeArticle.findUnique({
      where: { slug },
      include: {
        author: {
          select: { id: true, name: true, avatarUrl: true, createdAt: true }
        },
        category: {
          select: { id: true, name: true, slug: true, color: true }
        },
        _count: {
          select: { likesRelation: true }
        }
      }
    });

    if (!article) {
      return res.status(404).json({ error: 'Article not found' });
    }

    if (article.status !== 'PUBLISHED') {
      return res.status(403).json({ error: 'Article not available' });
    }

    // Increment view count
    await prisma.knowledgeArticle.update({
      where: { id: article.id },
      data: { views: { increment: 1 } }
    });

    res.json(article);
  } catch (error) {
    console.error('Error fetching knowledge article:', error);
    res.status(500).json({ error: 'Error fetching knowledge article' });
  }
};

const createKnowledgeArticle = async (req, res) => {
  try {
    const { title, content, excerpt, categoryId, tags, difficulty, readingTime, featuredImage } = req.body;
    const authorId = req.user.id;

    // Generate unique slug
    let slug = title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
    let counter = 1;
    let uniqueSlug = slug;

    while (await prisma.knowledgeArticle.findUnique({ where: { slug: uniqueSlug } })) {
      uniqueSlug = `${slug}-${counter}`;
      counter++;
    }

    const article = await prisma.knowledgeArticle.create({
      data: {
        title,
        slug: uniqueSlug,
        content,
        excerpt,
        authorId,
        categoryId: categoryId ? parseInt(categoryId) : null,
        tags: tags || [],
        difficulty: difficulty || 'BEGINNER',
        readingTime: readingTime || 5,
        featuredImage,
        status: 'DRAFT'
      },
      include: {
        author: {
          select: { id: true, name: true, avatarUrl: true }
        },
        category: {
          select: { id: true, name: true, slug: true, color: true }
        }
      }
    });

    res.json(article);
  } catch (error) {
    console.error('Error creating knowledge article:', error);
    res.status(500).json({ error: 'Error creating knowledge article' });
  }
};

const updateKnowledgeArticle = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, content, excerpt, categoryId, tags, difficulty, readingTime, featuredImage, status, isFeatured } = req.body;
    const userId = req.user.id;

    // Check if user is admin or article author
    const existingArticle = await prisma.knowledgeArticle.findUnique({
      where: { id: parseInt(id) }
    });

    if (!existingArticle) {
      return res.status(404).json({ error: 'Article not found' });
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { role: true }
    });

    if (existingArticle.authorId !== userId && user.role !== 'ADMIN') {
      return res.status(403).json({ error: 'Not authorized to update this article' });
    }

    const updateData = {};
    if (title) updateData.title = title;
    if (content) updateData.content = content;
    if (excerpt) updateData.excerpt = excerpt;
    if (categoryId !== undefined) updateData.categoryId = categoryId ? parseInt(categoryId) : null;
    if (tags) updateData.tags = tags;
    if (difficulty) updateData.difficulty = difficulty;
    if (readingTime) updateData.readingTime = readingTime;
    if (featuredImage !== undefined) updateData.featuredImage = featuredImage;
    if (status) updateData.status = status;
    if (typeof isFeatured === 'boolean') updateData.isFeatured = isFeatured;

    // Set published date if status changes to PUBLISHED
    if (status === 'PUBLISHED' && existingArticle.status !== 'PUBLISHED') {
      updateData.publishedAt = new Date();
    }

    const article = await prisma.knowledgeArticle.update({
      where: { id: parseInt(id) },
      data: updateData,
      include: {
        author: {
          select: { id: true, name: true, avatarUrl: true }
        },
        category: {
          select: { id: true, name: true, slug: true, color: true }
        }
      }
    });

    res.json(article);
  } catch (error) {
    console.error('Error updating knowledge article:', error);
    res.status(500).json({ error: 'Error updating knowledge article' });
  }
};

const deleteKnowledgeArticle = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    // Check if user is admin or article author
    const existingArticle = await prisma.knowledgeArticle.findUnique({
      where: { id: parseInt(id) }
    });

    if (!existingArticle) {
      return res.status(404).json({ error: 'Article not found' });
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { role: true }
    });

    if (existingArticle.authorId !== userId && user.role !== 'ADMIN') {
      return res.status(403).json({ error: 'Not authorized to delete this article' });
    }

    await prisma.knowledgeArticle.delete({
      where: { id: parseInt(id) }
    });

    res.json({ message: 'Article deleted successfully' });
  } catch (error) {
    console.error('Error deleting knowledge article:', error);
    res.status(500).json({ error: 'Error deleting knowledge article' });
  }
};

// Article likes
const likeKnowledgeArticle = async (req, res) => {
  try {
    const { articleId } = req.body;
    const userId = req.user.id;

    const existingLike = await prisma.knowledgeArticleLike.findUnique({
      where: {
        articleId_userId: {
          articleId: parseInt(articleId),
          userId: userId
        }
      }
    });

    if (existingLike) {
      await prisma.knowledgeArticleLike.delete({
        where: { id: existingLike.id }
      });
      return res.json({ liked: false });
    } else {
      await prisma.knowledgeArticleLike.create({
        data: {
          articleId: parseInt(articleId),
          userId: userId
        }
      });
      return res.json({ liked: true });
    }
  } catch (error) {
    console.error('Error liking knowledge article:', error);
    res.status(500).json({ error: 'Error liking knowledge article' });
  }
};

// Get featured articles
const getFeaturedArticles = async (req, res) => {
  try {
    const { limit = 5 } = req.query;

    const articles = await prisma.knowledgeArticle.findMany({
      where: {
        status: 'PUBLISHED',
        isFeatured: true
      },
      take: parseInt(limit),
      orderBy: { createdAt: 'desc' },
      include: {
        author: {
          select: { id: true, name: true, avatarUrl: true }
        },
        category: {
          select: { id: true, name: true, slug: true, color: true }
        },
        _count: {
          select: { likesRelation: true }
        }
      }
    });

    res.json(articles);
  } catch (error) {
    console.error('Error fetching featured articles:', error);
    res.status(500).json({ error: 'Error fetching featured articles' });
  }
};

// Get popular articles (by views)
const getPopularArticles = async (req, res) => {
  try {
    const { limit = 10 } = req.query;

    const articles = await prisma.knowledgeArticle.findMany({
      where: {
        status: 'PUBLISHED'
      },
      take: parseInt(limit),
      orderBy: { views: 'desc' },
      include: {
        author: {
          select: { id: true, name: true, avatarUrl: true }
        },
        category: {
          select: { id: true, name: true, slug: true, color: true }
        },
        _count: {
          select: { likesRelation: true }
        }
      }
    });

    res.json(articles);
  } catch (error) {
    console.error('Error fetching popular articles:', error);
    res.status(500).json({ error: 'Error fetching popular articles' });
  }
};

export {
  getKnowledgeCategories,
  createKnowledgeCategory,
  getKnowledgeArticles,
  getKnowledgeArticle,
  createKnowledgeArticle,
  updateKnowledgeArticle,
  deleteKnowledgeArticle,
  likeKnowledgeArticle,
  getFeaturedArticles,
  getPopularArticles
};