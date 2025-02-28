
import { useState, useEffect } from "react";
import { Menu, X } from "lucide-react";

const Navbar = () => {
  const [isOpen, setIsOpen] = useState(false);
  const [isScrolled, setIsScrolled] = useState(false);

  // Handle scroll event to add background to navbar
  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 10);
    };
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  // Handle window resize to close mobile menu
  useEffect(() => {
    const handleResize = () => {
      if (window.innerWidth > 768 && isOpen) {
        setIsOpen(false);
      }
    };
    window.addEventListener("resize", handleResize);
    return () => window.removeEventListener("resize", handleResize);
  }, [isOpen]);

  return (
    <header 
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
        isScrolled ? "bg-white/90 backdrop-blur-md shadow-sm" : "bg-transparent"
      }`}
    >
      <div className="container-custom flex items-center justify-between py-4">
        {/* Logo */}
        <div className="flex items-center">
          <a 
            href="#" 
            className="text-xl font-heading font-semibold tracking-tight"
          >
            <span className="text-primary">Smart</span>Recipe
          </a>
        </div>

        {/* Desktop Navigation */}
        <nav className="hidden md:flex items-center space-x-8">
          <a 
            href="#features" 
            className="text-sm font-medium text-gray-700 hover:text-primary transition-colors link-hover"
          >
            Features
          </a>
          <a 
            href="#how-it-works" 
            className="text-sm font-medium text-gray-700 hover:text-primary transition-colors link-hover"
          >
            How It Works
          </a>
          <a 
            href="#testimonials" 
            className="text-sm font-medium text-gray-700 hover:text-primary transition-colors link-hover"
          >
            Testimonials
          </a>
          <a 
            href="#download" 
            className="btn-primary"
          >
            Download App
          </a>
        </nav>

        {/* Mobile Menu Button */}
        <button
          className="md:hidden text-gray-700 hover:text-primary"
          onClick={() => setIsOpen(!isOpen)}
          aria-label="Toggle menu"
        >
          {isOpen ? <X size={24} /> : <Menu size={24} />}
        </button>
      </div>

      {/* Mobile Navigation */}
      <div 
        className={`md:hidden absolute top-full left-0 right-0 bg-white shadow-md transition-all duration-300 ease-in-out transform ${
          isOpen ? "translate-y-0 opacity-100" : "-translate-y-10 opacity-0 pointer-events-none"
        }`}
      >
        <div className="container-custom py-4 flex flex-col space-y-4">
          <a 
            href="#features"
            className="text-sm font-medium text-gray-700 hover:text-primary transition-colors py-2"
            onClick={() => setIsOpen(false)}
          >
            Features
          </a>
          <a 
            href="#how-it-works"
            className="text-sm font-medium text-gray-700 hover:text-primary transition-colors py-2"
            onClick={() => setIsOpen(false)}
          >
            How It Works
          </a>
          <a 
            href="#testimonials"
            className="text-sm font-medium text-gray-700 hover:text-primary transition-colors py-2"
            onClick={() => setIsOpen(false)}
          >
            Testimonials
          </a>
          <a 
            href="#download"
            className="btn-primary text-center"
            onClick={() => setIsOpen(false)}
          >
            Download App
          </a>
        </div>
      </div>
    </header>
  );
};

export default Navbar;
