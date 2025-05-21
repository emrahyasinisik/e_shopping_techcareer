import 'cart.dart';

class CartResponse {
  final bool success;
  final String message;
  final List<Cart>? items;

  CartResponse({required this.success, required this.message, this.items});

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      success: json['success'] == 1,
      message: json['message'] ?? '',
      items:
          json['urunler'] != null
              ? List<Cart>.from(json['urunler'].map((x) => Cart.fromJson(x)))
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success ? 1 : 0,
      'message': message,
      'urunler': items?.map((x) => x.toJson()).toList(),
    };
  }
}
