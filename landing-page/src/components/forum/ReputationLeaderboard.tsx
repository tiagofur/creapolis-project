'use client';

import { useState, useEffect } from 'react';
import { Trophy, Medal, Award, Star } from 'lucide-react';
import { forumService } from '@/lib/forum-api';

interface LeaderboardUser {
  id: number;
  name: string;
  avatarUrl?: string;
  reputation: number;
  _count: {
    forumThreads: number;
    forumPosts: number;
  };
}

interface ReputationLeaderboardProps {
  limit?: number;
  timeframe?: 'week' | 'month' | 'year' | 'all';
}

export function ReputationLeaderboard({ limit = 10, timeframe = 'all' }: ReputationLeaderboardProps) {
  const [leaderboard, setLeaderboard] = useState<LeaderboardUser[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchLeaderboard();
  }, [limit, timeframe]);

  const fetchLeaderboard = async () => {
    try {
      setLoading(true);
      const data = await forumService.getReputationLeaderboard(limit, timeframe);
      if (data) {
        setLeaderboard(data);
      }
    } catch (error) {
      console.error('Error fetching leaderboard:', error);
    } finally {
      setLoading(false);
    }
  };

  const getRankIcon = (index: number) => {
    switch (index) {
      case 0:
        return <Trophy className="h-5 w-5 text-yellow-500" />;
      case 1:
        return <Medal className="h-5 w-5 text-gray-400" />;
      case 2:
        return <Award className="h-5 w-5 text-orange-600" />;
      default:
        return <Star className="h-4 w-4 text-gray-400" />;
    }
  };

  const getRankColor = (index: number) => {
    switch (index) {
      case 0:
        return 'bg-yellow-50 border-yellow-200';
      case 1:
        return 'bg-gray-50 border-gray-200';
      case 2:
        return 'bg-orange-50 border-orange-200';
      default:
        return 'bg-white border-gray-200';
    }
  };

  if (loading) {
    return (
      <div className="bg-white rounded-lg shadow p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
          <Trophy className="h-5 w-5 mr-2 text-yellow-500" />
          Tabla de Líderes
        </h3>
        <div className="animate-pulse">
          {[...Array(5)].map((_, i) => (
            <div key={i} className="flex items-center space-x-3 mb-4">
              <div className="w-8 h-8 bg-gray-200 rounded-full"></div>
              <div className="flex-1">
                <div className="h-4 bg-gray-200 rounded w-1/3 mb-1"></div>
                <div className="h-3 bg-gray-200 rounded w-1/4"></div>
              </div>
              <div className="w-12 h-4 bg-gray-200 rounded"></div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  if (leaderboard.length === 0) {
    return (
      <div className="bg-white rounded-lg shadow p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
          <Trophy className="h-5 w-5 mr-2 text-yellow-500" />
          Tabla de Líderes
        </h3>
        <p className="text-gray-500 text-center py-8">
          Aún no hay usuarios en la tabla de líderes
        </p>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-lg shadow">
      <div className="p-6 border-b border-gray-200">
        <h3 className="text-lg font-semibold text-gray-900 flex items-center">
          <Trophy className="h-5 w-5 mr-2 text-yellow-500" />
          Tabla de Líderes de Reputación
        </h3>
        <p className="text-sm text-gray-600 mt-1">
          {timeframe === 'all' ? 'Todos los tiempos' : 
           timeframe === 'week' ? 'Esta semana' :
           timeframe === 'month' ? 'Este mes' : 'Este año'}
        </p>
      </div>
      
      <div className="p-6">
        <div className="space-y-3">
          {leaderboard.map((user, index) => (
            <div
              key={user.id}
              className={`flex items-center space-x-3 p-3 rounded-lg border ${getRankColor(index)}`}
            >
              <div className="flex items-center justify-center w-8 h-8">
                {getRankIcon(index)}
              </div>
              
              <div className="w-8 h-8 rounded-full bg-gradient-to-br from-blue-400 to-purple-500 flex items-center justify-center text-white font-semibold text-sm">
                {user.avatarUrl ? (
                  <img src={user.avatarUrl} alt={user.name} className="w-full h-full rounded-full object-cover" />
                ) : (
                  user.name.charAt(0).toUpperCase()
                )}
              </div>
              
              <div className="flex-1">
                <h4 className="font-medium text-gray-900">{user.name}</h4>
                <div className="flex items-center space-x-3 text-xs text-gray-500">
                  <span>{user._count.forumThreads} temas</span>
                  <span>•</span>
                  <span>{user._count.forumPosts} posts</span>
                </div>
              </div>
              
              <div className="text-right">
                <div className="text-lg font-bold text-gray-900">
                  {user.reputation.toLocaleString()}
                </div>
                <div className="text-xs text-gray-500">puntos</div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}