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

  Future<CartResponse> addToCart(String username, Cart item) async {
    try {
      final response = await _dio.post(
        "sepeteUrunEkle.php",
        data: item.toJson(),
      );
      print(response.data);
      if (response.statusCode == 200) {
        return CartResponse.fromJson(response.data);
      }
      return CartResponse(
        success: false,
        message: "Failed to add item to cart",
      );
    } catch (e) {
      return CartResponse(success: false, message: e.toString());
    }
  }

  Future<CartResponse> removeFromCart(
    String username,
    int productId, {
    int count = 1,
  }) async {
    try {
      final response = await _dio.post(
        "sepettenUrunSil.php",
        data: {
          "kullaniciAdi": username,
          "urun_id": productId.toString(),
          "adet": count.toString(), // API bunu destekliyorsa
        },
      );

      if (response.statusCode == 200) {
        return CartResponse.fromJson(response.data);
      }
      return CartResponse(
        success: false,
        message: "Failed to remove item from cart",
      );
    } catch (e) {
      return CartResponse(success: false, message: e.toString());
    }
  }
  
}
