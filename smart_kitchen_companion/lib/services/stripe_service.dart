import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_keys.dart';

class StripeService {
  static const String _baseUrl = 'https://api.stripe.com/v1';
  static const String _paymentIntentsEndpoint = '/payment_intents';

  Future<void> initialize() async {
    Stripe.publishableKey = STRIPE_PUBLISHABLE_KEY;
    await Stripe.instance.applySettings();
  }

  Future<Map<String, dynamic>> createPaymentIntent(
    String amount,
    String currency,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl$_paymentIntentsEndpoint');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $STRIPE_SECRET_KEY',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount,
          'currency': currency,
          'payment_method_types[]': 'card',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to create payment intent: $e');
    }
  }

  Future<void> processPayment(String amount) async {
    try {
      // Create payment intent
      final paymentIntent = await createPaymentIntent(
        amount, // Amount in cents
        'usd',
      );

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Smart Kitchen Companion',
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Colors.green,
            ),
          ),
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (e) {
      throw Exception('Payment failed: ${e.error.localizedMessage}');
    } catch (e) {
      throw Exception('Payment failed: $e');
    }
  }

  Future<void> handlePremiumUpgrade() async {
    try {
      // Premium subscription price in cents (e.g., $9.99)
      await processPayment('999');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> handleRecipePurchase(String recipeId, String price) async {
    try {
      // Convert price to cents
      final cents = (double.parse(price) * 100).round().toString();
      await processPayment(cents);
    } catch (e) {
      rethrow;
    }
  }
}
