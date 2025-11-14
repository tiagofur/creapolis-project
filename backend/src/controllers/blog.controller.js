import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

// Helper function to generate slug from title
const generateSlug = (title) => {
  return title
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
};

// Helper function to ensure unique slug
const ensureUniqueSlug = async (slug, excludeId = null) => {
  let uniqueSlug = slug;
  let counter = 1;
  
  while (true) {
    const existing = await prisma.blogArticle.findFirst({
      where: {
        slug: uniqueSlug,
        ...(excludeId && { id: { not: excludeId } })
      }
    });
    
    if (!existing) break;
    
    uniqueSlug = `${slug}-${counter}`;
    counter++;
  }
  
  return uniqueSlug;
};

// Get all blog articles with pagination and filtering
const getBlogArticles = async (req, res) => {
  try {
    const {
      page = 1,
      limit = 10,
      status = 'PUBLISHED',
      category,
      authorId,
      search,
      sortBy = 'publishedAt',
      sortOrder = 'desc'
    } = req.query;

    const skip = (page - 1) * limit;
    const where = {};

    // Filter by status
    if (status !== 'ALL') {
      where.status = status;
    }

    // Filter by category
    if (category) {
      where.category = category;
    }

    // Filter by author
    if (authorId) {
      where.authorId = parseInt(authorId);
    }

    // Search in title and content
    if (search) {
      where.OR = [
        { title: { contains: search, mode: 'insensitive' } },
        { content: { contains: search, mode: 'insensitive' } },
        { excerpt: { contains: search, mode: 'insensitive' } }
      ];
    }

    const [articles, total] = await Promise.all([
      prisma.blogArticle.findMany({
        where,
        skip: parseInt(skip),
        take: parseInt(limit),
        include: {
          author: {
            select: {
              id: true,
              name: true,
              email: true,
              avatarUrl: true
            }
          },
          blogCategory: true,
          _count: {
            select: {
              comments: true,
              likesRelation: true
            }
          }
        },
        orderBy: {
          [sortBy]: sortOrder
        }
      }),
      prisma.blogArticle.count({ where })
    ]);

    res.json({
      articles,
      pagination: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error fetching blog articles:', error);
    res.status(500).json({ error: 'Error fetching blog articles' });
  }
};

// Get a single blog article by slug or ID
const getBlogArticle = async (req, res) => {
  try {
    const { slug } = req.params;
    
    const where = isNaN(slug) ? { slug } : { id: parseInt(slug) };
    
    const article = await prisma.blogArticle.findFirst({
      where,
      include: {
        author: {
          select: {
            id: true,
            name: true,
            email: true,
            avatarUrl: true
          }
        },
        blogCategory: true,
        comments: {
          where: { isApproved: true },
          include: {
            author: {
              select: {
                id: true,
                name: true,
                email: true,
                avatarUrl: true
              }
            },
            replies: {
              where: { isApproved: true },
              include: {
                author: {
                  select: {
                    id: true,
                    name: true,
                    email: true,
                    avatarUrl: true
                  }
                }
              }
            }
          },
          orderBy: { createdAt: 'desc' }
        },
        _count: {
          select: {
            comments: true,
            likesRelation: true
          }
        }
      }
    });

    if (!article) {
      return res.status(404).json({ error: 'Article not found' });
    }

    // Increment view count
    await prisma.blogArticle.update({
      where: { id: article.id },
      data: { views: { increment: 1 } }
    });

    res.json(article);
  } catch (error) {
    console.error('Error fetching blog article:', error);
    res.status(500).json({ error: 'Error fetching blog article' });
  }
};

// Create a new blog article (requires authentication)
const createBlogArticle = async (req, res) => {
  try {
    const { title, content, excerpt, featuredImage, category, tags, status } = req.body;
    
    if (!title || !content) {
      return res.status(400).json({ error: 'Title and content are required' });
    }

    // Generate slug from title
    let slug = generateSlug(title);
    slug = await ensureUniqueSlug(slug);

    const article = await prisma.blogArticle.create({
      data: {
        title,
        slug,
        content,
        excerpt,
        featuredImage,
        category: category || 'GENERAL',
        tags: tags || [],
        status: status || 'DRAFT',
        authorId: req.user.id,
        publishedAt: status === 'PUBLISHED' ? new Date() : null
      },
      include: {
        author: {
          select: {
            id: true,
            name: true,
            email: true,
            avatarUrl: true
          }
        },
        blogCategory: true
      }
    });

    res.status(201).json(article);
  } catch (error) {
    console.error('Error creating blog article:', error);
    res.status(500).json({ error: 'Error creating blog article' });
  }
};

// Update a blog article (requires authentication)
const updateBlogArticle = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, content, excerpt, featuredImage, category, tags, status } = req.body;
    
    // Check if article exists and user is the author or admin
    const existingArticle = await prisma.blogArticle.findFirst({
      where: { id: parseInt(id) }
    });

    if (!existingArticle) {
      return res.status(404).json({ error: 'Article not found' });
    }

    // Check permissions
    if (req.user.role !== 'ADMIN' && existingArticle.authorId !== req.user.id) {
      return res.status(403).json({ error: 'You can only edit your own articles' });
    }

    // Generate new slug if title changed
    let slug = existingArticle.slug;
    if (title && title !== existingArticle.title) {
      const newSlug = generateSlug(title);
      slug = await ensureUniqueSlug(newSlug, parseInt(id));
    }

    const article = await prisma.blogArticle.update({
      where: { id: parseInt(id) },
      data: {
        title: title || existingArticle.title,
        slug,
        content: content || existingArticle.content,
        excerpt: excerpt !== undefined ? excerpt : existingArticle.excerpt,
        featuredImage: featuredImage !== undefined ? featuredImage : existingArticle.featuredImage,
        category: category || existingArticle.category,
        tags: tags !== undefined ? tags : existingArticle.tags,
        status: status || existingArticle.status,
        publishedAt: status === 'PUBLISHED' && existingArticle.status !== 'PUBLISHED' 
          ? new Date() 
          : existingArticle.publishedAt,
        updatedAt: new Date()
      },
      include: {
        author: {
          select: {
            id: true,
            name: true,
            email: true,
            avatarUrl: true
          }
        },
        blogCategory: true
      }
    });

    res.json(article);
  } catch (error) {
    console.error('Error updating blog article:', error);
    res.status(500).json({ error: 'Error updating blog article' });
  }
};

// Delete a blog article (requires authentication)
const deleteBlogArticle = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Check if article exists and user is the author or admin
    const existingArticle = await prisma.blogArticle.findFirst({
      where: { id: parseInt(id) }
    });

    if (!existingArticle) {
      return res.status(404).json({ error: 'Article not found' });
    }

    // Check permissions
    if (req.user.role !== 'ADMIN' && existingArticle.authorId !== req.user.id) {
      return res.status(403).json({ error: 'You can only delete your own articles' });
    }

    await prisma.blogArticle.delete({
      where: { id: parseInt(id) }
    });

    res.json({ message: 'Article deleted successfully' });
  } catch (error) {
    console.error('Error deleting blog article:', error);
    res.status(500).json({ error: 'Error deleting blog article' });
  }
};

// Like/unlike a blog article
const toggleLike = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    // Check if article exists
    const article = await prisma.blogArticle.findFirst({
      where: { id: parseInt(id) }
    });

    if (!article) {
      return res.status(404).json({ error: 'Article not found' });
    }

    // Check if user already liked the article
    const existingLike = await prisma.blogArticleLike.findFirst({
      where: {
        articleId: parseInt(id),
        userId: userId
      }
    });

    if (existingLike) {
      // Unlike the article
      await prisma.blogArticleLike.delete({
        where: { id: existingLike.id }
      });

      // Decrement like count
      await prisma.blogArticle.update({
        where: { id: parseInt(id) },
        data: { likes: { decrement: 1 } }
      });

      res.json({ liked: false, likes: article.likes - 1 });
    } else {
      // Like the article
      await prisma.blogArticleLike.create({
        data: {
          articleId: parseInt(id),
          userId: userId
        }
      });

      // Increment like count
      await prisma.blogArticle.update({
        where: { id: parseInt(id) },
        data: { likes: { increment: 1 } }
      });

      res.json({ liked: true, likes: article.likes + 1 });
    }
  } catch (error) {
    console.error('Error toggling like:', error);
    res.status(500).json({ error: 'Error toggling like' });
  }
};

// Add a comment to a blog article
const addComment = async (req, res) => {
  try {
    const { id } = req.params;
    const { content, parentId } = req.body;
    
    if (!content) {
      return res.status(400).json({ error: 'Content is required' });
    }

    // Check if article exists
    const article = await prisma.blogArticle.findFirst({
      where: { id: parseInt(id) }
    });

    if (!article) {
      return res.status(404).json({ error: 'Article not found' });
    }

    // Check if parent comment exists if parentId is provided
    if (parentId) {
      const parentComment = await prisma.blogComment.findFirst({
        where: { id: parseInt(parentId), articleId: parseInt(id) }
      });

      if (!parentComment) {
        return res.status(404).json({ error: 'Parent comment not found' });
      }
    }

    const comment = await prisma.blogComment.create({
      data: {
        content,
        articleId: parseInt(id),
        authorId: req.user.id,
        parentId: parentId ? parseInt(parentId) : null,
        isApproved: req.user.role === 'ADMIN' // Auto-approve admin comments
      },
      include: {
        author: {
          select: {
            id: true,
            name: true,
            email: true,
            avatarUrl: true
          }
        }
      }
    });

    res.status(201).json(comment);
  } catch (error) {
    console.error('Error adding comment:', error);
    res.status(500).json({ error: 'Error adding comment' });
  }
};

// Get blog categories
const getBlogCategories = async (req, res) => {
  try {
    const categories = await prisma.blogCategory.findMany({
      where: { isActive: true },
      include: {
        _count: {
          select: { articles: true }
        }
      },
      orderBy: [
        { sortOrder: 'asc' },
        { name: 'asc' }
      ]
    });

    res.json(categories);
  } catch (error) {
    console.error('Error fetching blog categories:', error);
    res.status(500).json({ error: 'Error fetching blog categories' });
  }
};

// Create a blog category (admin only)
const createBlogCategory = async (req, res) => {
  try {
    const { name, description, color, image, parentId } = req.body;
    
    if (!name) {
      return res.status(400).json({ error: 'Name is required' });
    }

    // Generate slug from name
    const slug = generateSlug(name);

    const category = await prisma.blogCategory.create({
      data: {
        name,
        slug,
        description,
        color,
        image,
        parentId: parentId ? parseInt(parentId) : null
      }
    });

    res.status(201).json(category);
  } catch (error) {
    console.error('Error creating blog category:', error);
    res.status(500).json({ error: 'Error creating blog category' });
  }
};

export {
  getBlogArticles,
  getBlogArticle,
  createBlogArticle,
  updateBlogArticle,
  deleteBlogArticle,
  toggleLike,
  addComment,
  getBlogCategories,
  createBlogCategory
};