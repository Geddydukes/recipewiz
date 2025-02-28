
import { ArrowRight, Rocket } from "lucide-react";
import { useState } from "react";
import { useToast } from "@/hooks/use-toast";

const BetaTester = () => {
  const [email, setEmail] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const { toast } = useToast();

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    
    // Simulate API call
    setTimeout(() => {
      setSubmitting(false);
      setSubmitted(true);
      setEmail("");
      
      toast({
        title: "Application received!",
        description: "Thank you for applying to be a beta tester. We'll be in touch soon!",
        variant: "default",
      });
    }, 1500);
  };

  return (
    <section id="beta-tester" className="section bg-primary/5">
      <div className="container-custom">
        {/* Section Header */}
        <div className="text-center max-w-3xl mx-auto mb-12 animate-fade-in">
          <div className="inline-block px-4 py-1.5 mb-6 text-xs font-medium tracking-wide text-primary bg-primary/10 rounded-full">
            Join Our Beta
          </div>
          <h2 className="text-3xl md:text-4xl font-bold mb-6">
            Become a Beta Tester
          </h2>
          <p className="text-gray-600">
            Help us shape the future of cooking and meal planning. Join our exclusive beta program and be among the first to experience Smart Recipe.
          </p>
        </div>

        {/* Beta Tester Application */}
        <div className="max-w-3xl mx-auto">
          <div className="bg-white rounded-2xl shadow-xl p-8 md:p-12">
            <div className="flex flex-col md:flex-row gap-10 items-center">
              {/* Left Column - Image/Icon */}
              <div className="w-full md:w-1/3 flex justify-center">
                <div className="relative w-40 h-40 bg-primary/10 rounded-full flex items-center justify-center">
                  <Rocket className="w-20 h-20 text-primary" />
                  <div className="absolute inset-0 border-4 border-primary/20 rounded-full animate-pulse"></div>
                </div>
              </div>
              
              {/* Right Column - Form */}
              <div className="w-full md:w-2/3">
                {submitted ? (
                  <div className="text-center space-y-4 py-4">
                    <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-green-100">
                      <svg className="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                      </svg>
                    </div>
                    <h3 className="text-xl font-bold">Thank You!</h3>
                    <p className="text-gray-600">Your application has been received. We'll review it and get back to you soon.</p>
                    <button 
                      onClick={() => setSubmitted(false)}
                      className="btn-secondary mt-4"
                    >
                      Submit Another Application
                    </button>
                  </div>
                ) : (
                  <form onSubmit={handleSubmit} className="space-y-4">
                    <h3 className="text-xl font-bold mb-4">Apply Now</h3>
                    
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div>
                        <label htmlFor="fullName" className="block text-sm font-medium text-gray-700 mb-1">
                          Full Name
                        </label>
                        <input 
                          type="text" 
                          id="fullName"
                          className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-primary/50 focus:border-primary focus:outline-none transition-colors"
                          placeholder="Your name"
                          required
                        />
                      </div>
                      
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
                    </div>
                    
                    <div>
                      <label htmlFor="experience" className="block text-sm font-medium text-gray-700 mb-1">
                        Cooking Experience
                      </label>
                      <select 
                        id="experience"
                        className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-primary/50 focus:border-primary focus:outline-none transition-colors"
                        required
                      >
                        <option value="">Select your experience level</option>
                        <option value="beginner">Beginner - I'm learning to cook</option>
                        <option value="intermediate">Intermediate - I cook regularly</option>
                        <option value="advanced">Advanced - I'm an experienced home cook</option>
                        <option value="professional">Professional - I have culinary training</option>
                      </select>
                    </div>
                    
                    <div>
                      <label htmlFor="reason" className="block text-sm font-medium text-gray-700 mb-1">
                        Why do you want to join our beta?
                      </label>
                      <textarea 
                        id="reason"
                        rows={3}
                        className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-primary/50 focus:border-primary focus:outline-none transition-colors"
                        placeholder="Tell us why you're interested in our app..."
                        required
                      ></textarea>
                    </div>
                    
                    <button 
                      type="submit" 
                      className="btn-primary w-full flex items-center justify-center gap-2"
                      disabled={submitting}
                    >
                      {submitting ? (
                        <span>Submitting...</span>
                      ) : (
                        <>
                          Apply to be a Beta Tester <ArrowRight size={16} />
                        </>
                      )}
                    </button>
                  </form>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default BetaTester;
