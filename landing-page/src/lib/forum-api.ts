import { apiService } from './api';

// Forum Methods
export const forumService = {
  async getForumCategories(): Promise<any> {
    const response = await apiService.request<{
      success: boolean;
      data: any[];
      message: string;
    }>('/forum/categories', {
      method: 'GET',
    });

    return response.data;
  },

  async getForumThreads(params?: {
    categoryId?: string;
    page?: number;
    limit?: number;
    sortBy?: 'lastReplyAt' | 'createdAt';
  }): Promise<any> {
    const queryParams = new URLSearchParams();
    if (params?.categoryId) queryParams.append('categoryId', params.categoryId);
    if (params?.page) queryParams.append('page', params.page.toString());
    if (params?.limit) queryParams.append('limit', params.limit.toString());
    if (params?.sortBy) queryParams.append('sortBy', params.sortBy);

    const response = await apiService.request<{
      success: boolean;
      threads: any[];
      pagination: any;
      message: string;
    }>(`/forum/threads?${queryParams.toString()}`, {
      method: 'GET',
    });

    return response;
  },

  async getForumThread(slug: string): Promise<any> {
    const response = await apiService.request<{
      success: boolean;
      data: any;
      message: string;
    }>(`/forum/threads/${slug}`, {
      method: 'GET',
    });

    return response.data;
  },

  async createForumThread(thread: {
    title: string;
    content: string;
    categoryId: string;
  }): Promise<any> {
    const response = await apiService.request<{
      success: boolean;
      data: any;
      message: string;
    }>('/forum/threads', {
      method: 'POST',
      body: JSON.stringify(thread),
    });

    return response.data;
  },

  async getForumPosts(threadId: string, params?: {
    page?: number;
    limit?: number;
  }): Promise<any> {
    const queryParams = new URLSearchParams();
    queryParams.append('threadId', threadId);
    if (params?.page) queryParams.append('page', params.page.toString());
    if (params?.limit) queryParams.append('limit', params.limit.toString());

    const response = await apiService.request<{
      success: boolean;
      posts: any[];
      pagination: any;
      message: string;
    }>(`/forum/posts?${queryParams.toString()}`, {
      method: 'GET',
    });

    return response;
  },

  async createForumPost(post: {
    content: string;
    threadId: string;
    parentId?: string;
  }): Promise<any> {
    const response = await apiService.request<{
      success: boolean;
      data: any;
      message: string;
    }>('/forum/posts', {
      method: 'POST',
      body: JSON.stringify(post),
    });

    return response.data;
  },

  async likeForumPost(postId: string): Promise<any> {
    const response = await apiService.request<{
      success: boolean;
      liked: boolean;
      message: string;
    }>('/forum/posts/like', {
      method: 'POST',
      body: JSON.stringify({ postId }),
    });

    return response;
  },

  async voteOnPost(postId: string, voteType: 'UPVOTE' | 'DOWNVOTE'): Promise<any> {
    const response = await apiService.request<{
      success: boolean;
      data: any;
      message: string;
    }>(`/votes/posts/${postId}/vote`, {
      method: 'POST',
      body: JSON.stringify({ voteType }),
    });
    return response.data;
  },

  async getPostVotes(postId: string): Promise<any> {
    const response = await apiService.request<{
      success: boolean;
      data: any;
      message: string;
    }>(`/votes/posts/${postId}/votes`, {
      method: 'GET',
    });
    return response.data;
  },

  async getUserReputation(userId: number): Promise<any> {
    const response = await apiService.request<{
      success: boolean;
      data: any;
      message: string;
    }>(`/votes/users/${userId}/reputation`, {
      method: 'GET',
    });
    return response.data;
  },

  async getReputationLeaderboard(limit: number = 10, timeframe: string = 'all'): Promise<any> {
    const params = new URLSearchParams({
      limit: limit.toString(),
      timeframe,
    });
    
    const response = await apiService.request<{
      success: boolean;
      data: any;
      message: string;
    }>(`/votes/leaderboard?${params}`, {
      method: 'GET',
    });
    return response.data;
  },
};

export default forumService;