
import { useState } from "react";
import { ArrowRight, Check } from "lucide-react";
import { useToast } from "@/hooks/use-toast";

const Newsletter = () => {
  const [email, setEmail] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSubscribed, setIsSubscribed] = useState(false);
  const { toast } = useToast();

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    
    // Simulate API call
    setTimeout(() => {
      setIsSubmitting(false);
      setIsSubscribed(true);
      setEmail("");
      
      toast({
        title: "Successfully subscribed!",
        description: "You'll now receive our latest updates and exclusive offers.",
        variant: "default",
      });
    }, 1500);
  };

  return (
    <section id="download" className="section bg-primary/10">
      <div className="container-custom">
        <div className="max-w-4xl mx-auto bg-white rounded-2xl shadow-xl overflow-hidden">
          <div className="grid grid-cols-1 md:grid-cols-2">
            {/* Image */}
            <div className="relative h-64 md:h-full">
              <img 
                src="https://images.unsplash.com/photo-1498837167922-ddd27525d352?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80" 
                alt="Delicious Food" 
                className="w-full h-full object-cover" 
              />
              <div className="absolute inset-0 bg-gradient-to-t from-primary/60 to-transparent"></div>
              <div className="absolute bottom-0 left-0 p-8 text-white">
                <h3 className="text-2xl font-bold mb-2">Get Early Access</h3>
                <p className="text-white/90">
                  Join our beta program and be among the first to experience the future of cooking.
                </p>
              </div>
            </div>
            
            {/* Form */}
            <div className="p-8 md:p-12">
              <div className="mb-8">
                <div className="inline-block px-4 py-1.5 mb-6 text-xs font-medium tracking-wide text-primary bg-primary/10 rounded-full">
                  Coming Soon
                </div>
                <h2 className="text-3xl font-bold mb-4">
                  Stay Updated
                </h2>
                <p className="text-gray-600">
                  Subscribe to our newsletter to receive the latest updates about our app launch, 
                  exclusive early access, and cooking tips.
                </p>
              </div>
              
              {isSubscribed ? (
                <div className="flex items-center gap-3 text-primary p-4 bg-primary/10 rounded-lg">
                  <Check className="w-5 h-5" />
                  <p className="font-medium">Thanks for subscribing!</p>
                </div>
              ) : (
                <form onSubmit={handleSubmit} className="space-y-4">
                  <div>
                    <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-1">
                      Email Address
                    </label>
                    <input 
                      type="email" 
                      id="email"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-primary/50 focus:border-primary focus:outline-none transition-colors"
                      placeholder="you@example.com"
                      required
                    />
                  </div>
                  <button 
                    type="submit" 
                    className="btn-primary w-full flex items-center justify-center gap-2"
                    disabled={isSubmitting}
                  >
                    {isSubmitting ? (
                      <span>Subscribing...</span>
                    ) : (
                      <>
                        Subscribe <ArrowRight size={16} />
                      </>
                    )}
                  </button>
                  <p className="text-xs text-gray-500 text-center">
                    We respect your privacy. Unsubscribe at any time.
                  </p>
                </form>
              )}
              
              {/* Download Buttons */}
              <div className="mt-8">
                <p className="text-sm font-medium text-gray-700 mb-4">
                  Download our app:
                </p>
                <div className="flex flex-col sm:flex-row gap-4">
                  <a 
                    href="#" 
                    className="flex-1 flex items-center justify-center gap-2 bg-gray-900 text-white rounded-lg px-4 py-3 hover:bg-gray-800 transition-colors"
                  >
                    <svg className="w-6 h-6" viewBox="0 0 24 24" fill="currentColor">
                      <path d="M17.5,12.5A5.51,5.51,0,0,1,16,16.5a5.41,5.41,0,0,1-4,2,5.5,5.5,0,0,1,0-11,5.41,5.41,0,0,1,4,2A5.51,5.51,0,0,1,17.5,12.5Z"/>
                      <path d="M12,2A10,10,0,1,0,22,12,10,10,0,0,0,12,2Zm0,18a8,8,0,1,1,8-8A8,8,0,0,1,12,20Z"/>
                    </svg>
                    <div className="text-left">
                      <p className="text-xs">Download on the</p>
                      <p className="text-sm font-semibold">App Store</p>
                    </div>
                  </a>
                  <a 
                    href="#" 
                    className="flex-1 flex items-center justify-center gap-2 bg-gray-900 text-white rounded-lg px-4 py-3 hover:bg-gray-800 transition-colors"
                  >
                    <svg className="w-6 h-6" viewBox="0 0 24 24" fill="currentColor">
                      <path d="M3.5,20.5a1,1,0,0,1-.5-.87V4.37a1,1,0,0,1,.5-.87l9-5a1,1,0,0,1,1,0l9,5a1,1,0,0,1,.5.87V19.63a1,1,0,0,1-.5.87l-9,5a1,1,0,0,1-1,0Z"/>
                    </svg>
                    <div className="text-left">
                      <p className="text-xs">GET IT ON</p>
                      <p className="text-sm font-semibold">Google Play</p>
                    </div>
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Newsletter;
