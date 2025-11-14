'use client';

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { useRouter } from 'next/navigation';
import apiService, { User, AuthResponse, LoginRequest, RegisterRequest, ApiError } from '@/lib/api';

interface AuthContextType {
  user: User | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  login: (credentials: LoginRequest) => Promise<void>;
  register: (userData: RegisterRequest) => Promise<void>;
  logout: () => void;
  checkAuth: () => Promise<void>;
  error: string | null;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();

  useEffect(() => {
    checkAuth();
  }, []);

  const checkAuth = async () => {
    try {
      setIsLoading(true);
      setError(null);
      
      if (apiService.isAuthenticated()) {
        const userData = await apiService.getProfile();
        setUser(userData);
      }
    } catch (error) {
      const apiError = error as ApiError;
      console.error('Auth check failed:', apiError.message);
      setUser(null);
      apiService.removeToken();
    } finally {
      setIsLoading(false);
    }
  };

  const login = async (credentials: LoginRequest) => {
    try {
      setIsLoading(true);
      setError(null);
      
      const response = await apiService.login(credentials);
      setUser(response.user);
      
      // Redirect based on role
      if (apiService.isAdmin(response.user)) {
        router.push('/admin/dashboard');
      } else {
        router.push('/dashboard');
      }
    } catch (error) {
      const apiError = error as ApiError;
      console.error('Login failed:', apiError.message);
      setError(apiError.message || 'Error al iniciar sesión');
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  const register = async (userData: RegisterRequest) => {
    try {
      setIsLoading(true);
      setError(null);
      
      const response = await apiService.register(userData);
      setUser(response.user);
      
      // Redirect to dashboard after successful registration
      router.push('/dashboard');
    } catch (error) {
      const apiError = error as ApiError;
      console.error('Registration failed:', apiError.message);
      setError(apiError.message || 'Error al registrar usuario');
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  const logout = () => {
    apiService.logout();
    setUser(null);
    router.push('/');
  };

  const value: AuthContextType = {
    user,
    isLoading,
    isAuthenticated: !!user,
    login,
    register,
    logout,
    checkAuth,
    error,
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}

// Role-based hook
export function useRole() {
  const { user } = useAuth();
  
  return {
    isAdmin: user ? apiService.isAdmin(user) : false,
    isProjectManager: user ? apiService.isProjectManager(user) : false,
    isTeamMember: user ? apiService.isTeamMember(user) : false,
    hasRole: (role: string) => user ? apiService.hasRole(user, role) : false,
    hasAnyRole: (roles: string[]) => user ? apiService.hasAnyRole(user, roles) : false,
    hasMinimumRole: (minimumRole: string) => user ? apiService.hasMinimumRole(user, minimumRole) : false,
  };
}