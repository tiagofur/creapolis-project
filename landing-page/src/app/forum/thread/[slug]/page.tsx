'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import Link from 'next/link';
import { forumService } from '@/lib/forum-api';
import { useAuth } from '@/hooks/useAuth';
import { formatDistanceToNow } from 'date-fns';
import { es } from 'date-fns/locale';
import { MessageCircle, Heart, Reply, User, Clock, ArrowLeft, Send } from 'lucide-react';

interface ForumThread {
  id: number;
  title: string;
  slug: string;
  content: string;
  author: {
    id: number;
    name: string;
    avatarUrl?: string;
  };
  category: {
    id: number;
    name: string;
    slug: string;
  };
  isPinned: boolean;
  isLocked: boolean;
  views: number;
  replies: number;
  lastReplyAt?: string;
  createdAt: string;
}

interface ForumPost {
  id: number;
  content: string;
  author: {
    id: number;
    name: string;
    avatarUrl?: string;
    createdAt: string;
  };
  parentId?: number;
  isEdited: boolean;
  editedAt?: string;
  createdAt: string;
  _count?: {
    likes: number;
  };
  replies?: ForumPost[];
}

export default function ForumThreadPage() {
  const { user, isAuthenticated } = useAuth();
  const router = useRouter();
  const params = useParams();
  const slug = params?.slug as string;
  
  const [thread, setThread] = useState<ForumThread | null>(null);
  const [posts, setPosts] = useState<ForumPost[]>([]);
  const [loading, setLoading] = useState(true);
  const [replyContent, setReplyContent] = useState('');
  const [replyingTo, setReplyingTo] = useState<number | null>(null);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  useEffect(() => {
    if (slug) {
      fetchThread();
      fetchPosts();
    }
  }, [slug, page]);

  const fetchThread = async () => {
    try {
      const data = await forumService.getForumThread(slug);
      setThread(data);
    } catch (error) {
      console.error('Error fetching thread:', error);
      router.push('/forum');
    }
  };

  const fetchPosts = async () => {
    try {
      setLoading(true);
      const response = await forumService.getForumPosts(slug, {
        page,
        limit: 20,
      });
      setPosts(response.posts);
      setTotalPages(response.pagination.pages);
    } catch (error) {
      console.error('Error fetching posts:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleReply = async () => {
    if (!replyContent.trim()) return;

    try {
      await forumService.createForumPost({
        content: replyContent,
        threadId: thread?.id.toString() || '',
        parentId: replyingTo?.toString(),
      });
      
      setReplyContent('');
      setReplyingTo(null);
      fetchPosts();
    } catch (error) {
      console.error('Error creating post:', error);
    }
  };

  const handleLikePost = async (postId: number) => {
    try {
      await forumService.likeForumPost(postId.toString());
      fetchPosts();
    } catch (error) {
      console.error('Error liking post:', error);
    }
  };

  if (!thread) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-500">Cargando tema...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Header */}
        <div className="mb-6">
          <Link
            href="/forum"
            className="inline-flex items-center text-sm text-gray-600 hover:text-gray-900 mb-4"
          >
            <ArrowLeft className="h-4 w-4 mr-1" />
            Volver al foro
          </Link>

          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center mb-4">
              {thread.isPinned && (
                <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800 mr-2">
                  📌 Fijado
                </span>
              )}
              {thread.isLocked && (
                <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-red-100 text-red-800 mr-2">
                  🔒 Cerrado
                </span>
              )}
              <span
                className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium text-white"
                style={{ backgroundColor: '#6B7280' }}
              >
                {thread.category.name}
              </span>
            </div>

            <h1 className="text-2xl font-bold text-gray-900 mb-4">{thread.title}</h1>
            
            <div className="flex items-center text-sm text-gray-500 space-x-4 mb-6">
              <div className="flex items-center">
                <div className="w-8 h-8 rounded-full bg-gray-300 mr-2"></div>
                <span>{thread.author.name}</span>
              </div>
              
              <div className="flex items-center">
                <Clock className="h-4 w-4 mr-1" />
                <span>
                  {formatDistanceToNow(new Date(thread.createdAt), { locale: es, addSuffix: true })}
                </span>
              </div>
              
              <div className="flex items-center">
                <MessageCircle className="h-4 w-4 mr-1" />
                <span>{thread.replies} respuestas</span>
              </div>
              
              <div className="flex items-center">
                <User className="h-4 w-4 mr-1" />
                <span>{thread.views} vistas</span>
              </div>
            </div>

            <div className="prose max-w-none">
              <p className="text-gray-700 whitespace-pre-wrap">{thread.content}</p>
            </div>
          </div>
        </div>

        {/* Posts */}
        <div className="mb-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            {thread.replies} Respuestas
          </h2>

          {loading ? (
            <div className="bg-white rounded-lg shadow p-8 text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
              <p className="mt-4 text-gray-500">Cargando respuestas...</p>
            </div>
          ) : posts.length === 0 ? (
            <div className="bg-white rounded-lg shadow p-8 text-center">
              <MessageCircle className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">Aún no hay respuestas</h3>
              <p className="text-gray-500">Sé el primero en responder</p>
            </div>
          ) : (
            <div className="space-y-4">
              {posts.map(post => (
                <div key={post.id} className="bg-white rounded-lg shadow p-6">
                  <div className="flex items-start justify-between mb-4">
                    <div className="flex items-center">
                      <div className="w-10 h-10 rounded-full bg-gray-300 mr-3"></div>
                      <div>
                        <h4 className="font-medium text-gray-900">{post.author.name}</h4>
                        <p className="text-sm text-gray-500">
                          {formatDistanceToNow(new Date(post.createdAt), { locale: es, addSuffix: true })}
                        </p>
                        {post.isEdited && post.editedAt && (
                          <p className="text-xs text-gray-400">
                            Editado {formatDistanceToNow(new Date(post.editedAt), { locale: es, addSuffix: true })}
                          </p>
                        )}
                      </div>
                    </div>
                    
                    <div className="flex items-center space-x-2">
                      <button
                        onClick={() => setReplyingTo(post.id)}
                        className="text-gray-500 hover:text-gray-700"
                      >
                        <Reply className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => handleLikePost(post.id)}
                        className="flex items-center space-x-1 text-gray-500 hover:text-red-500"
                      >
                        <Heart className="h-4 w-4" />
                        <span className="text-sm">{post._count?.likes || 0}</span>
                      </button>
                    </div>
                  </div>

                  <div className="prose max-w-none mb-4">
                    <p className="text-gray-700 whitespace-pre-wrap">{post.content}</p>
                  </div>

                  {/* Replies */}
                  {post.replies && post.replies.length > 0 && (
                    <div className="ml-8 mt-4 space-y-3">
                      {post.replies.map(reply => (
                        <div key={reply.id} className="bg-gray-50 rounded-lg p-4">
                          <div className="flex items-center justify-between mb-2">
                            <div className="flex items-center">
                              <div className="w-6 h-6 rounded-full bg-gray-300 mr-2"></div>
                              <span className="font-medium text-sm text-gray-900">{reply.author.name}</span>
                              <span className="text-xs text-gray-500 ml-2">
                                {formatDistanceToNow(new Date(reply.createdAt), { locale: es, addSuffix: true })}
                              </span>
                            </div>
                          </div>
                          <p className="text-sm text-gray-700">{reply.content}</p>
                        </div>
                      ))}
                    </div>
                  )}

                  {/* Reply Form */}
                  {replyingTo === post.id && (
                    <div className="mt-4 p-4 bg-gray-50 rounded-lg">
                      <textarea
                        value={replyContent}
                        onChange={(e) => setReplyContent(e.target.value)}
                        placeholder="Escribe tu respuesta..."
                        className="w-full p-3 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
                        rows={3}
                      />
                      <div className="flex justify-end space-x-2 mt-2">
                        <button
                          onClick={() => setReplyingTo(null)}
                          className="px-3 py-2 text-sm text-gray-600 hover:text-gray-800"
                        >
                          Cancelar
                        </button>
                        <button
                          onClick={handleReply}
                          disabled={!replyContent.trim()}
                          className="px-4 py-2 text-sm bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                          Responder
                        </button>
                      </div>
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Reply Form */}
        {!thread.isLocked && isAuthenticated && (
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-lg font-medium text-gray-900 mb-4">Responder al tema</h3>
            <textarea
              value={replyContent}
              onChange={(e) => setReplyContent(e.target.value)}
              placeholder="Escribe tu respuesta..."
              className="w-full p-3 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
              rows={4}
            />
            <div className="flex justify-end mt-4">
              <button
                onClick={handleReply}
                disabled={!replyContent.trim()}
                className="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <Send className="h-4 w-4 mr-2" />
                Publicar respuesta
              </button>
            </div>
          </div>
        )}

        {!isAuthenticated && !thread.isLocked && (
          <div className="bg-white rounded-lg shadow p-6 text-center">
            <h3 className="text-lg font-medium text-gray-900 mb-2">Inicia sesión para responder</h3>
            <p className="text-gray-600 mb-4">Debes estar autenticado para participar en el foro</p>
            <Link
              href={`/auth/login?redirect=/forum/${thread.slug}`}
              className="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
            >
              Iniciar sesión
            </Link>
          </div>
        )}

        {thread.isLocked && (
          <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-6 text-center">
            <h3 className="text-lg font-medium text-yellow-800 mb-2">Tema cerrado</h3>
            <p className="text-yellow-700">Este tema ha sido cerrado y no se pueden agregar nuevas respuestas</p>
          </div>
        )}
      </div>
    </div>
  );
}