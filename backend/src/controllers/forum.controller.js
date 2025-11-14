import { PrismaClient } from '@prisma/client';
import { updateUserReputation, getReputationByAction } from '../utils/reputation.js';
const prisma = new PrismaClient();

// Forum Categories
const getForumCategories = async (req, res) => {
  try {
    const categories = await prisma.forumCategory.findMany({
      where: { isActive: true },
      orderBy: { sortOrder: 'asc' },
      include: {
        _count: {
          select: { threads: true }
        }
      }
    });

    res.json(categories);
  } catch (error) {
    console.error('Error fetching forum categories:', error);
    res.status(500).json({ error: 'Error fetching forum categories' });
  }
};

const createForumCategory = async (req, res) => {
  try {
    const { name, description, color, icon, sortOrder } = req.body;
    
    const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
    
    const category = await prisma.forumCategory.create({
      data: {
        name,
        slug,
        description,
        color,
        icon,
        sortOrder: sortOrder || 0
      }
    });

    res.json(category);
  } catch (error) {
    console.error('Error creating forum category:', error);
    res.status(500).json({ error: 'Error creating forum category' });
  }
};

// Forum Threads
const getForumThreads = async (req, res) => {
  try {
    const { categoryId, page = 1, limit = 20, sortBy = 'lastReplyAt' } = req.query;
    const skip = (page - 1) * limit;

    const where = categoryId ? { categoryId: parseInt(categoryId) } : {};

    const threads = await prisma.forumThread.findMany({
      where,
      skip: parseInt(skip),
      take: parseInt(limit),
      orderBy: [
        { isPinned: 'desc' },
        sortBy === 'lastReplyAt' ? { lastReplyAt: 'desc' } : { createdAt: 'desc' }
      ],
      include: {
        author: {
          select: { id: true, name: true, avatarUrl: true }
        },
        category: {
          select: { id: true, name: true, slug: true, color: true }
        },
        _count: {
          select: { posts: true }
        }
      }
    });

    const total = await prisma.forumThread.count({ where });

    res.json({
      threads,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error fetching forum threads:', error);
    res.status(500).json({ error: 'Error fetching forum threads' });
  }
};

const getForumThread = async (req, res) => {
  try {
    const { slug } = req.params;

    const thread = await prisma.forumThread.findUnique({
      where: { slug },
      include: {
        author: {
          select: { id: true, name: true, avatarUrl: true, createdAt: true }
        },
        category: {
          select: { id: true, name: true, slug: true }
        },
        _count: {
          select: { posts: true }
        }
      }
    });

    if (!thread) {
      return res.status(404).json({ error: 'Thread not found' });
    }

    // Increment view count
    await prisma.forumThread.update({
      where: { id: thread.id },
      data: { views: { increment: 1 } }
    });

    res.json(thread);
  } catch (error) {
    console.error('Error fetching forum thread:', error);
    res.status(500).json({ error: 'Error fetching forum thread' });
  }
};

const createForumThread = async (req, res) => {
  try {
    const { title, content, categoryId } = req.body;
    const authorId = req.user.id;

    // Generate unique slug
    let slug = title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
    let counter = 1;
    let uniqueSlug = slug;

    while (await prisma.forumThread.findUnique({ where: { slug: uniqueSlug } })) {
      uniqueSlug = `${slug}-${counter}`;
      counter++;
    }

    const thread = await prisma.forumThread.create({
      data: {
        title,
        slug: uniqueSlug,
        content,
        authorId,
        categoryId: parseInt(categoryId),
        lastReplyAt: new Date()
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

    // Otorgar reputación por crear un tema
    await updateUserReputation(authorId, getReputationByAction('THREAD_CREATED'), 'THREAD_CREATED', 'ForumThread', thread.id);

    res.json(thread);
  } catch (error) {
    console.error('Error creating forum thread:', error);
    res.status(500).json({ error: 'Error creating forum thread' });
  }
};

const updateForumThread = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, content, isPinned, isLocked } = req.body;
    const userId = req.user.id;

    // Check if user is admin or thread author
    const existingThread = await prisma.forumThread.findUnique({
      where: { id: parseInt(id) }
    });

    if (!existingThread) {
      return res.status(404).json({ error: 'Thread not found' });
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { role: true }
    });

    if (existingThread.authorId !== userId && user.role !== 'ADMIN') {
      return res.status(403).json({ error: 'Not authorized to update this thread' });
    }

    const updateData = {};
    if (title) updateData.title = title;
    if (content) updateData.content = content;
    if (typeof isPinned === 'boolean') updateData.isPinned = isPinned;
    if (typeof isLocked === 'boolean') updateData.isLocked = isLocked;

    const thread = await prisma.forumThread.update({
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

    res.json(thread);
  } catch (error) {
    console.error('Error updating forum thread:', error);
    res.status(500).json({ error: 'Error updating forum thread' });
  }
};

const deleteForumThread = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    // Check if user is admin or thread author
    const existingThread = await prisma.forumThread.findUnique({
      where: { id: parseInt(id) }
    });

    if (!existingThread) {
      return res.status(404).json({ error: 'Thread not found' });
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { role: true }
    });

    if (existingThread.authorId !== userId && user.role !== 'ADMIN') {
      return res.status(403).json({ error: 'Not authorized to delete this thread' });
    }

    await prisma.forumThread.delete({
      where: { id: parseInt(id) }
    });

    res.json({ message: 'Thread deleted successfully' });
  } catch (error) {
    console.error('Error deleting forum thread:', error);
    res.status(500).json({ error: 'Error deleting forum thread' });
  }
};

// Forum Posts
const getForumPosts = async (req, res) => {
  try {
    const { threadId, page = 1, limit = 20 } = req.query;
    const skip = (page - 1) * limit;

    const posts = await prisma.forumPost.findMany({
      where: { threadId: parseInt(threadId), parentId: null },
      skip: parseInt(skip),
      take: parseInt(limit),
      orderBy: { createdAt: 'asc' },
      include: {
        author: {
          select: { id: true, name: true, avatarUrl: true, createdAt: true }
        },
        _count: {
          select: { replies: true, likes: true }
        },
        replies: {
          take: 5,
          orderBy: { createdAt: 'asc' },
          include: {
            author: {
              select: { id: true, name: true, avatarUrl: true }
            },
            _count: {
              select: { likes: true }
            }
          }
        }
      }
    });

    const total = await prisma.forumPost.count({
      where: { threadId: parseInt(threadId), parentId: null }
    });

    res.json({
      posts,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error fetching forum posts:', error);
    res.status(500).json({ error: 'Error fetching forum posts' });
  }
};

const createForumPost = async (req, res) => {
  try {
    const { content, threadId, parentId } = req.body;
    const authorId = req.user.id;

    // Check if thread is locked
    const thread = await prisma.forumThread.findUnique({
      where: { id: parseInt(threadId) }
    });

    if (!thread) {
      return res.status(404).json({ error: 'Thread not found' });
    }

    if (thread.isLocked) {
      return res.status(403).json({ error: 'Thread is locked' });
    }

    const post = await prisma.forumPost.create({
      data: {
        content,
        threadId: parseInt(threadId),
        authorId,
        parentId: parentId ? parseInt(parentId) : null
      },
      include: {
        author: {
          select: { id: true, name: true, avatarUrl: true }
        },
        _count: {
          select: { likes: true }
        }
      }
    });

    // Update thread statistics
    await prisma.forumThread.update({
      where: { id: parseInt(threadId) },
      data: {
        replies: { increment: 1 },
        lastReplyAt: new Date()
      }
    });

    // Otorgar reputación por crear un post
    await updateUserReputation(authorId, getReputationByAction('POST_CREATED'), 'POST_CREATED', 'ForumPost', post.id);

    res.json(post);
  } catch (error) {
    console.error('Error creating forum post:', error);
    res.status(500).json({ error: 'Error creating forum post' });
  }
};

const updateForumPost = async (req, res) => {
  try {
    const { id } = req.params;
    const { content } = req.body;
    const userId = req.user.id;

    const existingPost = await prisma.forumPost.findUnique({
      where: { id: parseInt(id) }
    });

    if (!existingPost) {
      return res.status(404).json({ error: 'Post not found' });
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { role: true }
    });

    if (existingPost.authorId !== userId && user.role !== 'ADMIN') {
      return res.status(403).json({ error: 'Not authorized to update this post' });
    }

    const post = await prisma.forumPost.update({
      where: { id: parseInt(id) },
      data: {
        content,
        isEdited: true,
        editedAt: new Date()
      },
      include: {
        author: {
          select: { id: true, name: true, avatarUrl: true }
        },
        _count: {
          select: { likes: true }
        }
      }
    });

    res.json(post);
  } catch (error) {
    console.error('Error updating forum post:', error);
    res.status(500).json({ error: 'Error updating forum post' });
  }
};

const deleteForumPost = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const existingPost = await prisma.forumPost.findUnique({
      where: { id: parseInt(id) }
    });

    if (!existingPost) {
      return res.status(404).json({ error: 'Post not found' });
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { role: true }
    });

    if (existingPost.authorId !== userId && user.role !== 'ADMIN') {
      return res.status(403).json({ error: 'Not authorized to delete this post' });
    }

    await prisma.forumPost.delete({
      where: { id: parseInt(id) }
    });

    // Update thread statistics
    await prisma.forumThread.update({
      where: { id: existingPost.threadId },
      data: {
        replies: { decrement: 1 }
      }
    });

    res.json({ message: 'Post deleted successfully' });
  } catch (error) {
    console.error('Error deleting forum post:', error);
    res.status(500).json({ error: 'Error deleting forum post' });
  }
};

// Forum Post Likes
const likeForumPost = async (req, res) => {
  try {
    const { postId } = req.body;
    const userId = req.user.id;

    const existingLike = await prisma.forumPostLike.findUnique({
      where: {
        postId_userId: {
          postId: parseInt(postId),
          userId: userId
        }
      }
    });

    if (existingLike) {
      await prisma.forumPostLike.delete({
        where: { id: existingLike.id }
      });
      return res.json({ liked: false });
    } else {
      await prisma.forumPostLike.create({
        data: {
          postId: parseInt(postId),
          userId: userId
        }
      });
      return res.json({ liked: true });
    }
  } catch (error) {
    console.error('Error liking forum post:', error);
    res.status(500).json({ error: 'Error liking forum post' });
  }
};

export {
  getForumCategories,
  createForumCategory,
  getForumThreads,
  getForumThread,
  createForumThread,
  updateForumThread,
  deleteForumThread,
  getForumPosts,
  createForumPost,
  updateForumPost,
  deleteForumPost,
  likeForumPost
};