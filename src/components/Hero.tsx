
import { ArrowRight } from "lucide-react";

const Hero = () => {
  return (
    <section className="pt-32 pb-16 md:pt-40 md:pb-24 overflow-hidden">
      <div className="container-custom relative">
        <div className="absolute top-0 right-0 -z-10 w-72 h-72 bg-secondary/50 rounded-full blur-3xl"></div>
        <div className="absolute bottom-0 left-0 -z-10 w-72 h-72 bg-primary/30 rounded-full blur-3xl"></div>
        
        {/* Hero Content */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          {/* Text Content */}
          <div className="space-y-8 animate-fade-in">
            <div>
              <div className="inline-block px-4 py-1.5 mb-6 text-xs font-medium tracking-wide text-primary bg-primary/10 rounded-full">
                Revolutionizing your kitchen experience
              </div>
              <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold leading-tight">
                Transform Your <span className="text-primary">Cooking Experience</span>
              </h1>
              <p className="mt-6 text-lg text-gray-600 md:text-xl max-w-lg">
                Discover a smarter way to manage recipes, plan meals, and shop for groceries with our AI-powered assistant.
              </p>
            </div>
            
            {/* CTA Buttons */}
            <div className="flex flex-col sm:flex-row gap-4">
              <a href="#download" className="btn-primary flex items-center justify-center gap-2">
                Get Started <ArrowRight size={16} />
              </a>
              <a href="#how-it-works" className="btn-secondary flex items-center justify-center">
                Learn More
              </a>
            </div>
            
            {/* Stats */}
            <div className="flex flex-wrap gap-x-8 gap-y-4 pt-4">
              <div>
                <p className="text-3xl font-bold text-primary">15K+</p>
                <p className="text-sm text-gray-500">Active Users</p>
              </div>
              <div>
                <p className="text-3xl font-bold text-primary">50K+</p>
                <p className="text-sm text-gray-500">Recipes Saved</p>
              </div>
              <div>
                <p className="text-3xl font-bold text-primary">4.8/5</p>
                <p className="text-sm text-gray-500">App Rating</p>
              </div>
            </div>
          </div>
          
          {/* Hero Image */}
          <div className="relative h-full animate-fade-in">
            <div className="relative z-10 aspect-square max-w-md mx-auto">
              <div className="absolute inset-0 rounded-full bg-secondary/20 blur-3xl"></div>
              <img 
                src="https://images.unsplash.com/photo-1606787366850-de6330128bfc?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80" 
                alt="Smart Recipe App" 
                className="relative z-20 rounded-2xl shadow-xl object-cover w-full h-full border-8 border-white" 
              />
              
              {/* Floating Elements */}
              <div className="absolute top-10 -left-16 z-30 glass p-4 rounded-2xl shadow-lg animate-float max-w-[180px] hidden md:block">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-primary/30 rounded-full flex items-center justify-center">
                    <span className="text-primary font-semibold">520</span>
                  </div>
                  <div>
                    <p className="text-sm font-medium">Calories</p>
                    <p className="text-xs text-gray-500">Per Serving</p>
                  </div>
                </div>
              </div>
              
              <div className="absolute -bottom-10 -right-10 z-30 glass p-4 rounded-2xl shadow-lg animate-float max-w-[200px] hidden md:block">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-accent/50 rounded-full flex items-center justify-center">
                    <span className="text-accent-foreground font-semibold">$12</span>
                  </div>
                  <div>
                    <p className="text-sm font-medium">Estimated Cost</p>
                    <p className="text-xs text-gray-500">For 4 Servings</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Hero;
