
import { Camera, ShoppingCart, Heart, Share2, Utensils } from "lucide-react";

const Features = () => {
  const features = [
    {
      icon: <Camera className="w-12 h-12 text-primary" />,
      title: "Multi-modal Recipe Input",
      description: "Add recipes via photo, video, or voice. Our AI identifies ingredients and instructions automatically."
    },
    {
      icon: <ShoppingCart className="w-12 h-12 text-primary" />,
      title: "Smart Shopping Lists",
      description: "Generate shopping lists automatically. Organize by store section and find the best prices."
    },
    {
      icon: <Utensils className="w-12 h-12 text-primary" />,
      title: "Nutritional Analysis",
      description: "Get detailed nutritional information for every recipe. Track calories, macros, and dietary preferences."
    },
    {
      icon: <Heart className="w-12 h-12 text-primary" />,
      title: "Personalized Recommendations",
      description: "Discover new recipes based on your preferences, dietary restrictions, and cooking habits."
    },
    {
      icon: <Share2 className="w-12 h-12 text-primary" />,
      title: "Social Sharing",
      description: "Share your culinary creations with friends and family. Discover popular recipes from our community."
    }
  ];

  return (
    <section id="features" className="section bg-secondary/30">
      <div className="container-custom">
        {/* Section Header */}
        <div className="text-center max-w-3xl mx-auto mb-16 animate-fade-in">
          <div className="inline-block px-4 py-1.5 mb-6 text-xs font-medium tracking-wide text-primary bg-primary/10 rounded-full">
            Key Features
          </div>
          <h2 className="text-3xl md:text-4xl font-bold mb-6">
            Everything You Need for Smarter Cooking
          </h2>
          <p className="text-gray-600">
            Our intelligent app simplifies your cooking journey from finding recipes to grocery shopping,
            helping you save time and enjoy delicious meals.
          </p>
        </div>

        {/* Features Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {features.map((feature, index) => (
            <div 
              key={index} 
              className="card p-8 hover-scale"
              style={{ animationDelay: `${index * 0.1}s` }}
            >
              <div className="w-16 h-16 rounded-2xl bg-primary/10 flex items-center justify-center mb-6">
                {feature.icon}
              </div>
              <h3 className="text-xl font-bold mb-3">{feature.title}</h3>
              <p className="text-gray-600">{feature.description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default Features;
