import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { AuthProvider } from "@/contexts/AuthContext";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
});

export const metadata: Metadata = {
  title: "Creapolis - Sistema de Gestión de Proyectos Inteligente",
  description: "Optimiza tu productividad, previene el burnout y alcanza el equilibrio trabajo-vida con nuestra plataforma de gestión de proyectos adaptativa e inteligente.",
  keywords: "gestión de proyectos, productividad, prevención de burnout, trabajo en equipo, planificación de proyectos",
  authors: [{ name: "Creapolis Team" }],
  openGraph: {
    title: "Creapolis - Gestión de Proyectos Inteligente",
    description: "Transforma tu forma de trabajar con planificación automática y prevención de burnout",
    type: "website",
    locale: "es_ES",
  },
  twitter: {
    card: "summary_large_image",
    title: "Creapolis - Gestión de Proyectos Inteligente",
    description: "Optimiza tu productividad y previene el burnout",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="es">
      <body className={`${inter.variable} font-sans antialiased`}>
        <AuthProvider>
          <Navigation />
          <main className="pt-16">{children}</main>
          <Footer />
        </AuthProvider>
      </body>
    </html>
  );
}
