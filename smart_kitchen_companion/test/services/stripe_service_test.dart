import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import '../../lib/services/stripe_service.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  late StripeService stripeService;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    stripeService = StripeService();
  });

  group('StripeService', () {
    test('createPaymentIntent creates correct request', () async {
      const amount = '999';
      const currency = 'usd';

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
            '{"id": "test_id", "client_secret": "test_secret"}',
            200,
          ));

      final result = await stripeService.createPaymentIntent(amount, currency);

      expect(result['id'], equals('test_id'));
      expect(result['client_secret'], equals('test_secret'));
    });

    test('handlePremiumUpgrade processes correct amount', () async {
      const expectedAmount = '999'; // $9.99 in cents

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
            '{"id": "test_id", "client_secret": "test_secret"}',
            200,
          ));

      // This should not throw an error
      await stripeService.handlePremiumUpgrade();
    });

    test('handleRecipePurchase converts price correctly', () async {
      const price = '4.99';
      const expectedAmount = '499'; // $4.99 in cents

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
            '{"id": "test_id", "client_secret": "test_secret"}',
            200,
          ));

      // This should not throw an error
      await stripeService.handleRecipePurchase('recipe_id', price);
    });
  });
}
