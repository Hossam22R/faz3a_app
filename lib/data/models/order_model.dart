class OrderModel {
  final String orderId;
  final String productId;
  final int quantity;
  final double price;

  OrderModel({required this.orderId, required this.productId, required this.quantity, required this.price});

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'],
      productId: json['productId'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'productId': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}