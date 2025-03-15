// Copy this file to api_keys.dart and replace with your actual API keys
const String GEMINI_API_KEY = 'YOUR_API_KEY_HERE';

// Function to validate API key is set
bool isGeminiApiKeyConfigured() {
  return GEMINI_API_KEY != 'YOUR_API_KEY_HERE' && GEMINI_API_KEY.isNotEmpty;
}
