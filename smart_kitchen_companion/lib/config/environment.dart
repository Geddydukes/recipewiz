enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static Environment _environment = Environment.development;
  static bool _isTestMode = false;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static void setTestMode(bool isTest) {
    _isTestMode = isTest;
  }

  static Environment get environment => _environment;
  static bool get isTestMode => _isTestMode;
  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;

  // Feature flags for testing
  static bool get useTestStripeKeys => isDevelopment || isTestMode;
  static bool get skipPaymentInTest => isTestMode;
  static bool get useEmulators => isDevelopment || isTestMode;
}
