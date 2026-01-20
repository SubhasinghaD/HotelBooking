import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../app/app_config.dart';

class PaymentApi {
  static Future<String> createPaymentIntent({
    required int amount,
    required String currency,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.backendUrl}/payments/create-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'metadata': metadata,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['clientSecret'];
      } else {
        throw Exception('Failed to create payment intent: ${response.body}');
      }
    } catch (e) {
      throw Exception('Payment error: $e');
    }
  }
}
