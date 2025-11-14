'use client';

import { useState, useEffect } from 'react';
import { ChevronUp, ChevronDown } from 'lucide-react';
import { forumService } from '@/lib/forum-api';
import { useAuth } from '@/hooks/useAuth';
import { toast } from 'sonner';

interface VoteButtonsProps {
  postId: string;
  initialUpvotes?: number;
  initialDownvotes?: number;
  initialScore?: number;
  initialUserVote?: 'UPVOTE' | 'DOWNVOTE' | null;
  size?: 'sm' | 'md';
}

export function VoteButtons({ 
  postId, 
  initialUpvotes = 0, 
  initialDownvotes = 0, 
  initialScore = 0,
  initialUserVote = null,
  size = 'md'
}: VoteButtonsProps) {
  const { user } = useAuth();
  const [upvotes, setUpvotes] = useState(initialUpvotes);
  const [downvotes, setDownvotes] = useState(initialDownvotes);
  const [score, setScore] = useState(initialScore);
  const [userVote, setUserVote] = useState<'UPVOTE' | 'DOWNVOTE' | null>(initialUserVote);
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    // Fetch current vote status if user is logged in
    if (user) {
      fetchVoteStatus();
    }
  }, [user, postId]);

  const fetchVoteStatus = async () => {
    try {
      const data = await forumService.getPostVotes(postId);
      if (data) {
        setUpvotes(data.upvotes);
        setDownvotes(data.downvotes);
        setScore(data.score);
        setUserVote(data.userVote);
      }
    } catch (error) {
      console.error('Error fetching vote status:', error);
    }
  };

  const handleVote = async (voteType: 'UPVOTE' | 'DOWNVOTE') => {
    if (!user) {
      toast.error('Debes iniciar sesión para votar');
      return;
    }

    if (isLoading) return;

    setIsLoading(true);
    try {
      const result = await forumService.voteOnPost(postId, voteType);
      
      if (result && result.post) {
        setUpvotes(result.post.upvotes);
        setDownvotes(result.post.downvotes);
        setScore(result.post.score);
        
        // Update user vote based on action
        if (result.result.action === 'added') {
          setUserVote(voteType);
        } else if (result.result.action === 'removed') {
          setUserVote(null);
        } else if (result.result.action === 'changed') {
          setUserVote(voteType);
        }
      }
    } catch (error) {
      console.error('Error voting:', error);
      toast.error('Error al procesar tu voto');
    } finally {
      setIsLoading(false);
    }
  };

  const buttonSize = size === 'sm' ? 'w-6 h-6' : 'w-8 h-8';
  const iconSize = size === 'sm' ? 16 : 20;
  const textSize = size === 'sm' ? 'text-xs' : 'text-sm';

  return (
    <div className="flex items-center space-x-1">
      <button
        onClick={() => handleVote('UPVOTE')}
        disabled={isLoading}
        className={`${buttonSize} flex items-center justify-center rounded transition-colors ${
          userVote === 'UPVOTE'
            ? 'bg-green-100 text-green-600 hover:bg-green-200'
            : 'bg-gray-100 text-gray-600 hover:bg-gray-200 hover:text-green-600'
        } ${isLoading ? 'opacity-50 cursor-not-allowed' : ''}`}
        title="Votar positivamente"
      >
        <ChevronUp size={iconSize} />
      </button>
      
      <div className={`${textSize} font-medium text-gray-700 min-w-[2rem] text-center`}>
        {score}
      </div>
      
      <button
        onClick={() => handleVote('DOWNVOTE')}
        disabled={isLoading}
        className={`${buttonSize} flex items-center justify-center rounded transition-colors ${
          userVote === 'DOWNVOTE'
            ? 'bg-red-100 text-red-600 hover:bg-red-200'
            : 'bg-gray-100 text-gray-600 hover:bg-gray-200 hover:text-red-600'
        } ${isLoading ? 'opacity-50 cursor-not-allowed' : ''}`}
        title="Votar negativamente"
      >
        <ChevronDown size={iconSize} />
      </button>
    </div>
  );
}