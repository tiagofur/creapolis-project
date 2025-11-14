import Link from 'next/link'
import { Facebook, Twitter, Instagram, Linkedin, Mail, Phone, MapPin } from 'lucide-react'

export default function Footer() {
  const currentYear = new Date().getFullYear()

  const footerLinks = {
    product: [
      { name: 'Características', href: '/features' },
      { name: 'Precios', href: '/pricing' },
      { name: 'Demo', href: '/demo' },
      { name: 'Descarga la App', href: '/download' },
    ],
    resources: [
      { name: 'Blog', href: '/blog' },
      { name: 'Centro de Ayuda', href: '/support' },
      { name: 'Base de Conocimientos', href: '/knowledge-base' },
      { name: 'Comunidad', href: '/community' },
    ],
    company: [
      { name: 'Acerca de', href: '/about' },
      { name: 'Carreras', href: '/careers' },
      { name: 'Prensa', href: '/press' },
      { name: 'Contacto', href: '/contact' },
    ],
    legal: [
      { name: 'Privacidad', href: '/privacy' },
      { name: 'Términos', href: '/terms' },
      { name: 'Cookies', href: '/cookies' },
      { name: 'Licencias', href: '/licenses' },
    ],
  }

  const socialLinks = [
    { icon: Facebook, href: 'https://facebook.com/creapolis', label: 'Facebook' },
    { icon: Twitter, href: 'https://twitter.com/creapolis', label: 'Twitter' },
    { icon: Instagram, href: 'https://instagram.com/creapolis', label: 'Instagram' },
    { icon: Linkedin, href: 'https://linkedin.com/company/creapolis', label: 'LinkedIn' },
  ]

  return (
    <footer className="bg-gray-900 text-white">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div className="grid md:grid-cols-2 lg:grid-cols-5 gap-8">
          {/* Brand */}
          <div className="lg:col-span-1">
            <Link href="/" className="flex items-center space-x-2 mb-6">
              <div className="w-8 h-8 bg-gradient-to-r from-blue-600 to-orange-500 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-sm">C</span>
              </div>
              <span className="text-xl font-bold">Creapolis</span>
            </Link>
            
            <p className="text-gray-300 mb-6 leading-relaxed">
              Sistema de gestión de proyectos inteligente que optimiza tu productividad 
              mientras cuida de tu bienestar.
            </p>

            <div className="flex space-x-4">
              {socialLinks.map((social) => (
                <Link
                  key={social.label}
                  href={social.href}
                  aria-label={social.label}
                  className="w-10 h-10 bg-gray-800 rounded-lg flex items-center justify-center hover:bg-blue-600 transition-colors"
                >
                  <social.icon className="h-5 w-5" />
                </Link>
              ))}
            </div>
          </div>

          {/* Product Links */}
          <div>
            <h3 className="font-semibold text-lg mb-4">Producto</h3>
            <ul className="space-y-3">
              {footerLinks.product.map((link) => (
                <li key={link.name}>
                  <Link href={link.href} className="text-gray-300 hover:text-white transition-colors">
                    {link.name}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Resources Links */}
          <div>
            <h3 className="font-semibold text-lg mb-4">Recursos</h3>
            <ul className="space-y-3">
              {footerLinks.resources.map((link) => (
                <li key={link.name}>
                  <Link href={link.href} className="text-gray-300 hover:text-white transition-colors">
                    {link.name}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Company Links */}
          <div>
            <h3 className="font-semibold text-lg mb-4">Empresa</h3>
            <ul className="space-y-3">
              {footerLinks.company.map((link) => (
                <li key={link.name}>
                  <Link href={link.href} className="text-gray-300 hover:text-white transition-colors">
                    {link.name}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Contact Info */}
          <div>
            <h3 className="font-semibold text-lg mb-4">Contacto</h3>
            <ul className="space-y-3">
              <li className="flex items-center space-x-3">
                <Mail className="h-5 w-5 text-gray-400" />
                <span className="text-gray-300">hola@creapolis.com</span>
              </li>
              <li className="flex items-center space-x-3">
                <Phone className="h-5 w-5 text-gray-400" />
                <span className="text-gray-300">+34 912 345 678</span>
              </li>
              <li className="flex items-center space-x-3">
                <MapPin className="h-5 w-5 text-gray-400" />
                <span className="text-gray-300">Madrid, España</span>
              </li>
            </ul>

            <div className="mt-6">
              <h4 className="font-medium mb-2">Legal</h4>
              <ul className="space-y-2">
                {footerLinks.legal.map((link) => (
                  <li key={link.name}>
                    <Link href={link.href} className="text-gray-400 hover:text-white text-sm transition-colors">
                      {link.name}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </div>

        {/* Newsletter Signup */}
        <div className="border-t border-gray-800 mt-12 pt-8">
          <div className="grid md:grid-cols-2 gap-8 items-center">
            <div>
              <h3 className="font-semibold text-lg mb-2">Mantente Informado</h3>
              <p className="text-gray-300">
                Recibe consejos de productividad, actualizaciones y ofertas especiales.
              </p>
            </div>
            <div className="flex flex-col sm:flex-row gap-3">
              <input
                type="email"
                placeholder="Tu correo electrónico"
                className="flex-1 px-4 py-3 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
              <button className="btn btn-primary px-6 py-3 whitespace-nowrap">
                Suscribirse
              </button>
            </div>
          </div>
        </div>

        {/* Bottom Bar */}
        <div className="border-t border-gray-800 mt-8 pt-8 flex flex-col md:flex-row justify-between items-center">
          <p className="text-gray-400 text-sm">
            © {currentYear} Creapolis. Todos los derechos reservados.
          </p>
          <div className="flex items-center space-x-6 mt-4 md:mt-0">
            <span className="text-gray-400 text-sm">Hecho con ❤️ en España</span>
            <div className="flex items-center space-x-2">
              <div className="w-6 h-6 bg-green-500 rounded-full flex items-center justify-center">
                <span className="text-white text-xs font-bold">✓</span>
              </div>
              <span className="text-gray-400 text-sm">Carbon Neutral</span>
            </div>
          </div>
        </div>
      </div>
    </footer>
  )
}