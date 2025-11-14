import { apiService } from './api';

// Knowledge Base Methods
export const knowledgeService = {
  async getKnowledgeCategories(): Promise<any> {
    const response = await apiService.request<{
      success: boolean;
      data: any[];
      message: string;
    }>('/knowledge/categories', {
      method: 'GET',
    });
    return response.data;
  },

  async getKnowledgeArticles(params?: {
    categoryId?: string;
    difficulty?: string;
    page?: number;
    limit?: number;
    search?: string;
    sortBy?: 'publishedAt' | 'views' | 'likes';
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

    const response = await apiService.request<{
      success: boolean;
      articles: any[];
      pagination: any;
      message: string;
    }>(`/knowledge/articles?${queryParams.toString()}`, {
      method: 'GET',
    });

    return response;
  },

  async getKnowledgeArticle(slug: string): Promise<any> {
    const response = await apiService.request<{
      success: boolean;
      data: any;
      message: string;
    }>(`/knowledge/articles/${slug}`, {
      method: 'GET',
    });
    return response.data;
  },

  async createKnowledgeArticle(article: {
    title: string;
    content: string;
    excerpt?: string;
    categoryId?: string;
    tags?: string[];
    difficulty?: 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED' | 'EXPERT';
    readingTime?: number;
    featuredImage?: string;
  }): Promise<any> {
    const response = await apiService.request<{
      success: boolean;
      data: any;
      message: string;
    }>('/knowledge/articles', {
      method: 'POST',
      body: JSON.stringify(article),
    });
    return response.data;
  },

  async updateKnowledgeArticle(slug: string, article: {
    title?: string;
    content?: string;
    excerpt?: string;
    categoryId?: string;
    tags?: string[];
    difficulty?: 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED' | 'EXPERT';
    readingTime?: number;
    featuredImage?: string;
    status?: 'DRAFT' | 'PUBLISHED' | 'ARCHIVED';
  }): Promise<any> {
    const response = await apiService.request<{
      success: boolean;
      data: any;
      message: string;
    }>(`/knowledge/articles/${slug}`, {
      method: 'PUT',
      body: JSON.stringify(article),
    });
    return response.data;
  },

  async deleteKnowledgeArticle(slug: string): Promise<any> {
    const response = await apiService.request<{
      success: boolean;
      message: string;
    }>(`/knowledge/articles/${slug}`, {
      method: 'DELETE',
    });
    return response;
  },

  async likeKnowledgeArticle(slug: string): Promise<any> {
    const response = await apiService.request<{
      success: boolean;
      liked: boolean;
      message: string;
    }>(`/knowledge/articles/${slug}/like`, {
      method: 'POST',
    });
    return response;
  },

  async getFeaturedArticles(): Promise<any> {
    const response = await apiService.request<{
      success: boolean;
      data: any[];
      message: string;
    }>('/knowledge/articles/featured', {
      method: 'GET',
    });
    return response.data;
  },

  async getPopularArticles(): Promise<any> {
    const response = await apiService.request<{
      success: boolean;
      data: any[];
      message: string;
    }>('/knowledge/articles/popular', {
      method: 'GET',
    });
    return response.data;
  },

  async createKnowledgeCategory(category: {
    name: string;
    description?: string;
    color?: string;
    icon?: string;
    parentId?: string;
    sortOrder?: number;
  }): Promise<any> {
    const response = await apiService.request<{
      success: boolean;
      data: any;
      message: string;
    }>('/knowledge/categories', {
      method: 'POST',
      body: JSON.stringify(category),
    });
    return response.data;
  },
};

export default knowledgeService;