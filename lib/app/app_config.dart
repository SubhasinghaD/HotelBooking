class AppConfig {
  // Backend API Configuration
  static const String backendUrl = 'http://localhost:8080';
  
  // Feature Flags
  static const bool useFirebase = true;
  static const bool enablePayments = true;
  
  // Google Maps Configuration
  static const String mapsApiKey = 'AIzaSyCNMN2GKLscQUJ4C68pCruzM6pAGoSkRdA';
  
  // Stripe Configuration
  static const String stripePublishableKey = 'pk_test_51SrXRwQFHx4VIZZKke4WpollAo8cC5ukCN1jHVHlLktgtYvDtuWV9CqTfhPlC7ZeMGiXAwfDdgpKHf7aA3HCsGA400fNW70Rrz';

  // Firebase Web Configuration (required for web authentication)
  static const String firebaseWebApiKey = 'AIzaSyB_NiQGefZpLUWOfN7MOncNfqyM8ZpruRA';
  static const String firebaseWebAuthDomain = 'hotelbookingapp-ebb89.firebaseapp.com';
  static const String firebaseWebProjectId = 'hotelbookingapp-ebb89';
  static const String firebaseWebStorageBucket = 'hotelbookingapp-ebb89.firebasestorage.app';
  static const String firebaseWebMessagingSenderId = '917502929168';
  static const String firebaseWebAppId = '1:917502929168:web:e6a3613253a63d23739d95';
}
