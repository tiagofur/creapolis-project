import Link from 'next/link'
import { Menu, X, User, LogOut } from 'lucide-react'
import { useState } from 'react'
import { useAuth } from '@/contexts/AuthContext'

export default function Navigation() {
  const [isMenuOpen, setIsMenuOpen] = useState(false)
  const { user, logout, isAuthenticated } = useAuth()

  const navigation = [
    { name: 'Inicio', href: '/' },
    { name: 'Blog', href: '/blog' },
    { name: 'Foro', href: '/forum' },
    { name: 'Ayuda', href: '/support' },
    { name: 'Precios', href: '/pricing' },
  ]

  return (
    <nav className="fixed top-0 w-full bg-white/95 backdrop-blur-sm z-50 border-b border-gray-200">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          {/* Logo */}
          <Link href="/" className="flex items-center space-x-2">
            <div className="w-8 h-8 bg-gradient-to-r from-blue-600 to-orange-500 rounded-lg flex items-center justify-center">
              <span className="text-white font-bold text-sm">C</span>
            </div>
            <span className="text-xl font-bold text-gray-900">Creapolis</span>
          </Link>

          {/* Desktop Navigation */}
          <div className="hidden md:flex items-center space-x-8">
            {navigation.map((item) => (
              <Link
                key={item.name}
                href={item.href}
                className="text-gray-600 hover:text-gray-900 font-medium transition-colors"
              >
                {item.name}
              </Link>
            ))}
          </div>

          {/* CTA Buttons */}
          <div className="hidden md:flex items-center space-x-4">
            {isAuthenticated ? (
              <>
                {user?.role === 'ADMIN' && (
                  <Link
                    href="/admin/blog"
                    className="flex items-center space-x-2 text-gray-600 hover:text-gray-900 font-medium transition-colors"
                  >
                    <span>Admin</span>
                  </Link>
                )}
                <Link
                  href="/dashboard"
                  className="flex items-center space-x-2 text-gray-600 hover:text-gray-900 font-medium transition-colors"
                >
                  <User size={18} />
                  <span>{user?.name}</span>
                </Link>
                <button
                  onClick={logout}
                  className="flex items-center space-x-2 text-gray-600 hover:text-gray-900 font-medium transition-colors"
                >
                  <LogOut size={18} />
                  <span>Salir</span>
                </button>
              </>
            ) : (
              <>
                <Link
                  href="/auth/login"
                  className="text-gray-600 hover:text-gray-900 font-medium transition-colors"
                >
                  Iniciar Sesión
                </Link>
                <Link
                  href="/auth/register"
                  className="btn btn-primary"
                >
                  Empezar Gratis
                </Link>
              </>
            )}
          </div>

          {/* Mobile menu button */}
          <div className="md:hidden">
            <button
              onClick={() => setIsMenuOpen(!isMenuOpen)}
              className="text-gray-600 hover:text-gray-900 p-2"
            >
              {isMenuOpen ? <X size={24} /> : <Menu size={24} />}
            </button>
          </div>
        </div>

        {/* Mobile Navigation */}
        {isMenuOpen && (
          <div className="md:hidden bg-white border-t border-gray-200">
            <div className="px-2 pt-2 pb-3 space-y-1">
              {navigation.map((item) => (
                <Link
                  key={item.name}
                  href={item.href}
                  className="block px-3 py-2 text-gray-600 hover:text-gray-900 font-medium transition-colors"
                  onClick={() => setIsMenuOpen(false)}
                >
                  {item.name}
                </Link>
              ))}
              <div className="border-t border-gray-200 pt-4 pb-3">
                {isAuthenticated ? (
                  <>
                    {user?.role === 'ADMIN' && (
                      <Link
                        href="/admin/blog"
                        className="block px-3 py-2 text-gray-600 hover:text-gray-900 font-medium transition-colors"
                        onClick={() => setIsMenuOpen(false)}
                      >
                        Admin Blog
                      </Link>
                    )}
                    <Link
                      href="/dashboard"
                      className="block px-3 py-2 text-gray-600 hover:text-gray-900 font-medium transition-colors"
                      onClick={() => setIsMenuOpen(false)}
                    >
                      Mi Perfil ({user?.name})
                    </Link>
                    <button
                      onClick={() => {
                        logout();
                        setIsMenuOpen(false);
                      }}
                      className="block w-full text-left px-3 py-2 text-gray-600 hover:text-gray-900 font-medium transition-colors"
                    >
                      Salir
                    </button>
                  </>
                ) : (
                  <>
                    <Link
                      href="/auth/login"
                      className="block px-3 py-2 text-gray-600 hover:text-gray-900 font-medium transition-colors"
                      onClick={() => setIsMenuOpen(false)}
                    >
                      Iniciar Sesión
                    </Link>
                    <Link
                      href="/auth/register"
                      className="block px-3 py-2 mt-2 btn btn-primary text-center"
                      onClick={() => setIsMenuOpen(false)}
                    >
                      Empezar Gratis
                    </Link>
                  </>
                )}
              </div>
            </div>
          </div>
        )}
      </div>
    </nav>
  )
}