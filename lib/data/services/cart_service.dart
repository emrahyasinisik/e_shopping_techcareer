import 'package:dio/dio.dart';

import '../models/cart.dart';
import '../models/cart_response.dart';

class CartService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://kasimadalan.pe.hu/urunler/",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<CartResponse> getCartItems(String username) async {
    try {
      final response = await _dio.post(
        "sepettekiUrunleriGetir.php",
        data: {"kullaniciAdi": username},
      );

      if (response.statusCode == 200) {
        return CartResponse.fromJson(response.data);
      }
      return CartResponse(
        success: false,
        message: "Failed to fetch cart items",
      );
    } catch (e) {
      return CartResponse(success: false, message: e.toString());
    }
  }
}
