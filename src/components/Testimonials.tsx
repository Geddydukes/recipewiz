
import { useState } from "react";
import { ArrowLeft, ArrowRight, Star } from "lucide-react";

const Testimonials = () => {
  const testimonials = [
    {
      quote: "This app has completely transformed my cooking routine. I love how it generates shopping lists automatically and helps me plan my meals for the week.",
      author: "Sarah Johnson",
      role: "Home Cook",
      avatar: "https://randomuser.me/api/portraits/women/44.jpg",
      rating: 5
    },
    {
      quote: "The recipe scanning feature is amazing! I can just take a photo of a recipe from a cookbook, and it captures all the details perfectly. Such a time-saver!",
      author: "Michael Chen",
      role: "Food Enthusiast",
      avatar: "https://randomuser.me/api/portraits/men/32.jpg",
      rating: 5
    },
    {
      quote: "As a nutritionist, I appreciate the detailed nutritional analysis this app provides. It's helping my clients make healthier food choices.",
      author: "Emily Rodriguez",
      role: "Nutritionist",
      avatar: "https://randomuser.me/api/portraits/women/68.jpg",
      rating: 4
    },
    {
      quote: "The cost breakdown feature helps me stay within my grocery budget while still making delicious meals. This app pays for itself!",
      author: "David Wilson",
      role: "Budget-Conscious Cook",
      avatar: "https://randomuser.me/api/portraits/men/75.jpg",
      rating: 5
    }
  ];

  const [currentIndex, setCurrentIndex] = useState(0);

  const nextTestimonial = () => {
    setCurrentIndex((prevIndex) => (prevIndex + 1) % testimonials.length);
  };

  const prevTestimonial = () => {
    setCurrentIndex((prevIndex) => (prevIndex - 1 + testimonials.length) % testimonials.length);
  };

  return (
    <section id="testimonials" className="section bg-primary/5">
      <div className="container-custom">
        {/* Section Header */}
        <div className="text-center max-w-3xl mx-auto mb-16 animate-fade-in">
          <div className="inline-block px-4 py-1.5 mb-6 text-xs font-medium tracking-wide text-primary bg-primary/10 rounded-full">
            Testimonials
          </div>
          <h2 className="text-3xl md:text-4xl font-bold mb-6">
            What Our Users Are Saying
          </h2>
          <p className="text-gray-600">
            Discover how Smart Recipe is helping people transform their cooking experience and simplify meal planning.
          </p>
        </div>

        {/* Testimonials Carousel */}
        <div className="max-w-4xl mx-auto">
          <div className="relative overflow-hidden rounded-2xl bg-white shadow-xl p-8 md:p-12">
            <div 
              className="transition-all duration-500 ease-in-out"
              style={{ transform: `translateX(-${currentIndex * 100}%)` }}
            >
              <div className="flex w-full snap-x">
                {testimonials.map((testimonial, index) => (
                  <div 
                    key={index} 
                    className="w-full flex-shrink-0 snap-center px-4"
                    style={{ display: index === currentIndex ? 'block' : 'none' }}
                  >
                    <div className="flex flex-col items-center text-center">
                      <div className="w-20 h-20 mb-6 overflow-hidden rounded-full border-4 border-primary/20">
                        <img 
                          src={testimonial.avatar} 
                          alt={testimonial.author} 
                          className="w-full h-full object-cover"
                        />
                      </div>
                      
                      {/* Rating */}
                      <div className="flex mb-6">
                        {[...Array(5)].map((_, i) => (
                          <Star 
                            key={i} 
                            className={`w-5 h-5 ${i < testimonial.rating ? 'text-yellow-400 fill-yellow-400' : 'text-gray-300'}`} 
                          />
                        ))}
                      </div>
                      
                      {/* Quote */}
                      <blockquote className="text-xl font-medium mb-6 text-balance">
                        "{testimonial.quote}"
                      </blockquote>
                      
                      <div>
                        <p className="font-bold">{testimonial.author}</p>
                        <p className="text-sm text-gray-500">{testimonial.role}</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
            
            {/* Navigation Buttons */}
            <div className="flex justify-between mt-8">
              <button 
                onClick={prevTestimonial}
                className="p-2 rounded-full bg-white shadow-md hover:bg-primary/5 transition-colors"
                aria-label="Previous testimonial"
              >
                <ArrowLeft className="w-5 h-5 text-gray-600" />
              </button>
              
              {/* Indicators */}
              <div className="flex space-x-2">
                {testimonials.map((_, index) => (
                  <button
                    key={index}
                    onClick={() => setCurrentIndex(index)}
                    className={`w-2.5 h-2.5 rounded-full transition-colors ${
                      index === currentIndex ? 'bg-primary' : 'bg-gray-300'
                    }`}
                    aria-label={`Go to testimonial ${index + 1}`}
                  />
                ))}
              </div>
              
              <button 
                onClick={nextTestimonial}
                className="p-2 rounded-full bg-white shadow-md hover:bg-primary/5 transition-colors"
                aria-label="Next testimonial"
              >
                <ArrowRight className="w-5 h-5 text-gray-600" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Testimonials;
