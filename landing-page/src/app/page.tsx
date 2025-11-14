import HeroSection from '@/components/HeroSection'
import FeaturesShowcase from '@/components/FeaturesShowcase'
import TestimonialsSection from '@/components/TestimonialsSection'

export default function Home() {
  return (
    <div className="min-h-screen">
      <HeroSection />
      <FeaturesShowcase />
      <TestimonialsSection />
    </div>
  )
}
