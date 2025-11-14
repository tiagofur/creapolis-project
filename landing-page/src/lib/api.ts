import { API_BASE_URL } from '@/config/constants';

interface User {
  id: number;
  email: string;
  name: string;
  role: 'ADMIN' | 'PROJECT_MANAGER' | 'TEAM_MEMBER';
  avatarUrl?: string;
}

interface LoginCredentials {
  email: string;
  password: string;
}

interface RegisterData {
  email: string;
  password: string;
  name: string;
  role?: 'ADMIN' | 'PROJECT_MANAGER' | 'TEAM_MEMBER';
}

interface BlogParams {
  page?: number;
  limit?: number;
  category?: string;
  search?: string;
  status?: string;
}

class ApiService {
  private baseURL: string;

  constructor() {
    this.baseURL = API_BASE_URL;
  }

  private async request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    const url = `${this.baseURL}${endpoint}`;
    const token = typeof window !== 'undefined' ? localStorage.getItem('token') : null;

    const headers: HeadersInit = {
      'Content-Type': 'application/json',
      ...options.headers,
    };

    if (token) {
      headers.Authorization = `Bearer ${token}`;
    }

    try {
      const response = await fetch(url, {
        ...options,
        headers,
      });

      if (!response.ok) {
        if (response.status === 401) {
          // Handle unauthorized access
          if (typeof window !== 'undefined') {
            localStorage.removeItem('token');
            window.location.href = '/auth/login';
          }
        }
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('API request failed:', error);
      throw error;
    }
  }

  // Auth methods
  async login(credentials: LoginCredentials): Promise<{ user: User; token: string }> {
    const response = await this.request<{
      success: boolean;
      data: { user: User; token: string };
      message: string;
    }>('/auth/login', {
      method: 'POST',
      body: JSON.stringify(credentials),
    });

    return response.data;
  }

  async register(userData: RegisterData): Promise<{ user: User; token: string }> {
    const response = await this.request<{
      success: boolean;
      data: { user: User; token: string };
      message: string;
    }>('/auth/register', {
      method: 'POST',
      body: JSON.stringify(userData),
    });

    return response.data;
  }

  async getProfile(): Promise<User> {
    const response = await this.request<{
      success: boolean;
      data: User;
      message: string;
    }>('/auth/profile', {
      method: 'GET',
    });

    return response.data;
  }

  // User role checking methods
  isAdmin(user: User): boolean {
    return user.role === 'ADMIN';
  }

  isProjectManager(user: User): boolean {
    return user.role === 'PROJECT_MANAGER';
  }

  isTeamMember(user: User): boolean {
    return user.role === 'TEAM_MEMBER';
  }

  hasAdminAccess(user: User): boolean {
    return this.isAdmin(user) || this.isProjectManager(user);
  }

  // Blog API Methods
  async getBlogArticles(params?: BlogParams): Promise<any> {
    const queryParams = new URLSearchParams();
    if (params?.page) queryParams.append('page', params.page.toString());
    if (params?.limit) queryParams.append('limit', params.limit.toString());
    if (params?.category) queryParams.append('category', params.category);
    if (params?.search) queryParams.append('search', params.search);
    if (params?.status) queryParams.append('status', params.status);

    const response = await this.request<{
      success: boolean;
      data: any;
      message: string;
    }>(`/blog/articles?${queryParams.toString()}`, {
      method: 'GET',
    });

    return response.data;
  }

  async getBlogArticle(slug: string): Promise<any> {
    const response = await this.request<{
      success: boolean;
      data: any;
      message: string;
    }>(`/blog/articles/${slug}`, {
      method: 'GET',
    });

    return response.data;
  }

  async createBlogArticle(article: {
    title: string;
    content: string;
    excerpt: string;
    coverImage?: string;
    category: string;
    tags: string[];
    status?: string;
  }): Promise<any> {
    const response = await this.request<{
      success: boolean;
      data: any;
      message: string;
    }>('/blog/articles', {
      method: 'POST',
      body: JSON.stringify(article),
    });

    return response.data;
  }

  async updateBlogArticle(slug: string, article: any): Promise<any> {
    const response = await this.request<{
      success: boolean;
      data: any;
      message: string;
    }>(`/blog/articles/${slug}`, {
      method: 'PUT',
      body: JSON.stringify(article),
    });

    return response.data;
  }

  async deleteBlogArticle(slug: string): Promise<any> {
    const response = await this.request<{
      success: boolean;
      data: any;
      message: string;
    }>(`/blog/articles/${slug}`, {
      method: 'DELETE',
    });

    return response.data;
  }

  async getBlogCategories(): Promise<any> {
    const response = await this.request<{
      success: boolean;
      data: any;
      message: string;
    }>('/blog/categories', {
      method: 'GET',
    });

    return response.data;
  }

  async createBlogComment(articleId: string, content: string): Promise<any> {
    const response = await this.request<{
      success: boolean;
      data: any;
      message: string;
    }>('/blog/comments', {
      method: 'POST',
      body: JSON.stringify({ articleId, content }),
    });

    return response.data;
  }

  async getBlogComments(articleId: string): Promise<any> {
    const response = await this.request<{
      success: boolean;
      data: any;
      message: string;
    }>(`/blog/comments/article/${articleId}`, {
      method: 'GET',
    });

    return response.data;
  }

  async likeBlogArticle(articleId: string): Promise<any> {
    const response = await this.request<{
      success: boolean;
      data: any;
      message: string;
    }>('/blog/likes', {
      method: 'POST',
      body: JSON.stringify({ articleId }),
    });

    return response.data;
  }

  async unlikeBlogArticle(articleId: string): Promise<any> {
    const response = await this.request<{
      success: boolean;
      data: any;
      message: string;
    }>(`/blog/likes/${articleId}`, {
      method: 'DELETE',
    });

    return response.data;
  }

  // Forum API Methods
  async getForumCategories(): Promise<any> {
    const response = await this.request<{
      success: boolean;
      data: any;
      message: string;
    }>('/forum/categories', {
      method: 'GET',
    });

    return response.data;
  }

  async getForumThreads(params?: {
    categoryId?: string;
    page?: number;
    limit?: number;
    sortBy?: string;
  }): Promise<any> {
    const queryParams = new URLSearchParams();
    if (params?.categoryId) queryParams.append('categoryId', params.categoryId);
    if (params?.page) queryParams.append('page', params.page.toString());
    if (params?.limit) queryParams.append('limit', params.limit.toString());
    if (params?.sortBy) queryParams.append('sortBy', params.sortBy);

    const response = await this.request<{
      success: boolean;
      data: any;
      message: string;
    }>(`/forum/threads?${queryParams.toString()}`, {
      method: 'GET',
    });

    return response.data;
  }

  async getForumThread(slug: string): Promise<any> {
    const response = await this.request<{
      success: boolean;
      data: any;
      message: string;
    }>(`/forum/threads/${slug}`, {
      method: 'GET',
    });

    return response.data;
  }

  async createForumThread(thread: {
    title: string;
    content: string;
    categoryId: string;
  }): Promise<any> {
    const response = await this.request<{
      success: boolean;
      data: any;
      message: string;
    }>('/forum/threads', {
      method: 'POST',
      body: JSON.stringify(thread),
    });

    return response.data;
  }

  async getForumPosts(params: {
    threadId: string;
    page?: number;
    limit?: number;
  }): Promise<any> {
    const queryParams = new URLSearchParams();
    queryParams.append('threadId', params.threadId);
    if (params?.page) queryParams.append('page', params.page.toString());
    if (params?.limit) queryParams.append('limit', params.limit.toString());

    const response = await this.request<{
      success: boolean;
      data: any;
      message: string;
    }>(`/forum/posts?${queryParams.toString()}`, {
      method: 'GET',
    });

    return response.data;
  }

  async createForumPost(post: {
    content: string;
    threadId: string;
    parentId?: string;
  }): Promise<any> {
    const response = await this.request<{
      success: boolean;
      data: any;
      message: string;
    }>('/forum/posts', {
      method: 'POST',
      body: JSON.stringify(post),
    });

    return response.data;
  }

  async likeForumPost(postId: string): Promise<any> {
    const response = await this.request<{
      success: boolean;
      data: any;
      message: string;
    }>('/forum/posts/like', {
      method: 'POST',
      body: JSON.stringify({ postId }),
    });

    return response.data;
  }

  // Knowledge Base API Methods
  async getKnowledgeCategories(): Promise<any> {
    const response = await this.request<{
      success: boolean;
      data: any;
      message: string;
    }>('/knowledge/categories', {
      method: 'GET',
    });

    return response.data;
  }

  async getKnowledgeArticles(params?: {
    categoryId?: string;
    difficulty?: string;
    page?: number;
    limit?: number;
    search?: string;
    sortBy?: string;
    featured?: boolean;
  }): Promise<any> {
    const queryParams = new URLSearchParams();
    if (params?.categoryId) queryParams.append('categoryId', params.categoryId);
    if (params?.difficulty) queryParams.append('difficulty', params.difficulty);
    if (params?.page) queryParams.append('page', params.page.toString());
    if (params?.limit) queryParams.append('limit', params.limit.toString());
    if (params?.search) queryParams.append('search', params.search);
    if (params?.sortBy) queryParams.append('sortBy', params.sortBy);
    if (params?.featured) queryParams.append('featured', params.featured.toString());

    const response = await this.request<{
      success: boolean;
      data: any;
      message: string;
    }>(`/knowledge/articles?${queryParams.toString()}`, {
      method: 'GET',
    });

    return response.data;
  }

  async getKnowledgeArticle(slug: string): Promise<any> {
    const response = await this.request<{
      success: boolean;
      data: any;
      message: string;
    }>(`/knowledge/articles/${slug}`, {
      method: 'GET',
    });

    return response.data;
  }

  async getFeaturedKnowledgeArticles(limit?: number): Promise<any> {
    const queryParams = new URLSearchParams();
    if (limit) queryParams.append('limit', limit.toString());

    const response = await this.request<{
      success: boolean;
      data: any;
      message: string;
    }>(`/knowledge/articles/featured?${queryParams.toString()}`, {
      method: 'GET',
    });

    return response.data;
  }

  async getPopularKnowledgeArticles(limit?: number): Promise<any> {
    const queryParams = new URLSearchParams();
    if (limit) queryParams.append('limit', limit.toString());

    const response = await this.request<{
      success: boolean;
      data: any;
      message: string;
    }>(`/knowledge/articles/popular?${queryParams.toString()}`, {
      method: 'GET',
    });

    return response.data;
  }

  async createKnowledgeArticle(article: {
    title: string;
    content: string;
    excerpt?: string;
    categoryId?: string;
    tags?: string[];
    difficulty?: string;
    readingTime?: number;
    featuredImage?: string;
  }): Promise<any> {
    const response = await this.request<{
      success: boolean;
      data: any;
      message: string;
    }>('/knowledge/articles', {
      method: 'POST',
      body: JSON.stringify(article),
    });

    return response.data;
  }

  async likeKnowledgeArticle(articleId: string): Promise<any> {
    const response = await this.request<{
      success: boolean;
      data: any;
      message: string;
    }>('/knowledge/articles/like', {
      method: 'POST',
      body: JSON.stringify({ articleId }),
    });

    return response.data;
  }
}

export const apiService = new ApiService();
export default apiService;