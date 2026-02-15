enum PaymentMethod { cashOnDelivery, zainCash, asiaHawala }

abstract class PaymentRepository {
  Future<bool> processPayment({
    required double amount,
    required PaymentMethod method,
    required String orderId,
  });
}
