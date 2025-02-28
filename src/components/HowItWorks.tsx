
import { Camera, Utensils, ShoppingCart, Check } from "lucide-react";

const HowItWorks = () => {
  const steps = [
    {
      icon: <Camera className="w-8 h-8 text-white" />,
      title: "Capture Your Recipe",
      description: "Take a photo of a recipe, record a video, or use voice input. Our AI understands and processes the information.",
      bgColor: "bg-primary"
    },
    {
      icon: <Utensils className="w-8 h-8 text-white" />,
      title: "Get Detailed Breakdown",
      description: "View ingredients, instructions, nutritional information, and estimated costs for your recipe.",
      bgColor: "bg-accent-foreground"
    },
    {
      icon: <ShoppingCart className="w-8 h-8 text-white" />,
      title: "Shop Intelligently",
      description: "Generate a smart shopping list organized by store sections with price comparisons and suggestions.",
      bgColor: "bg-secondary-foreground"
    },
    {
      icon: <Check className="w-8 h-8 text-white" />,
      title: "Cook with Confidence",
      description: "Follow step-by-step instructions, set timers, and get helpful tips while you cook your meal.",
      bgColor: "bg-primary"
    }
  ];

  return (
    <section id="how-it-works" className="section">
      <div className="container-custom">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">
          {/* Image Side */}
          <div className="relative">
            <div className="absolute top-0 left-0 -z-10 w-72 h-72 bg-secondary/50 rounded-full blur-3xl"></div>
            
            <div className="relative z-10 rounded-2xl overflow-hidden shadow-xl">
              <img 
                src="https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1980&q=80" 
                alt="Using Smart Recipe App" 
                className="w-full h-auto object-cover" 
              />
              
              {/* Floating Elements */}
              <div className="absolute top-8 right-8 glass p-3 rounded-xl shadow-lg animate-float">
                <div className="flex items-center gap-2">
                  <div className="text-primary">
                    <Utensils className="w-5 h-5" />
                  </div>
                  <p className="text-xs font-medium">Recipe Analyzed</p>
                </div>
              </div>
              
              <div className="absolute bottom-8 left-8 glass p-3 rounded-xl shadow-lg animate-float">
                <div className="flex items-center gap-2">
                  <div className="text-primary">
                    <ShoppingCart className="w-5 h-5" />
                  </div>
                  <p className="text-xs font-medium">Shopping List Ready</p>
                </div>
              </div>
            </div>
          </div>
          
          {/* Content Side */}
          <div className="space-y-8 animate-fade-in">
            <div>
              <div className="inline-block px-4 py-1.5 mb-6 text-xs font-medium tracking-wide text-primary bg-primary/10 rounded-full">
                How It Works
              </div>
              <h2 className="text-3xl md:text-4xl font-bold mb-6">
                Simple Steps to Smarter Cooking
              </h2>
              <p className="text-gray-600">
                Our intuitive app simplifies the entire cooking process from recipe discovery to grocery shopping, 
                making meal preparation easier than ever.
              </p>
            </div>
            
            {/* Steps */}
            <div className="space-y-6">
              {steps.map((step, index) => (
                <div key={index} className="flex gap-4">
                  <div className={`flex-shrink-0 w-12 h-12 ${step.bgColor} rounded-full flex items-center justify-center shadow-lg`}>
                    {step.icon}
                  </div>
                  <div>
                    <h3 className="text-xl font-bold mb-2">{step.title}</h3>
                    <p className="text-gray-600">{step.description}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default HowItWorks;
