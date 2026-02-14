class Helpers {
  Helpers._();

  static double calculateCommission({
    required double orderTotal,
    double commissionRate = 0.10,
  }) {
    return orderTotal * commissionRate;
  }
}
