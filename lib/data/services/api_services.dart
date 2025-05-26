import 'package:dio/dio.dart';
import 'package:e_shopping_techcareer/data/entity/sepette.dart';
import 'package:e_shopping_techcareer/data/entity/urunler.dart';
import 'dart:convert';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://kasimadalan.pe.hu/urunler/",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // 1. Tüm Ürünleri Getir
  Future<List<Urunler>> tumUrunleriGetir() async {
    final response = await _dio.get(
      "http://kasimadalan.pe.hu/urunler/tumUrunleriGetir.php",
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.data);
      final List<dynamic> urunlerJson = jsonResponse['urunler'];
      return urunlerJson.map((e) => Urunler.fromJson(e)).toList();
    } else {
      throw Exception("Ürünler alınamadı.");
    }
  }

  Future<void> urunGuncelle({
    required int id,
    required String ad,
    required String resim,
    required String kategori,
    required int fiyat,
    required String marka,
  }) async {
    final response = await _dio.post(
      "urunGuncelle.php",
      data: {
        "id": id,
        "ad": ad,
        "resim": resim,
        "kategori": kategori,
        "fiyat": fiyat,
        "marka": marka,
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Ürün güncellenemedi.");
    }
  }

  Future<void> urunSil(int id) async {
    final response = await _dio.post("urunSil.php", data: {"id": id});

    if (response.statusCode != 200) {
      throw Exception("Ürün silinemedi.");
    }
  }

  Future<List<Urunler>> urunAra(String aramaKelimesi) async {
    final response = await _dio.post(
      "urunAra.php",
      data: {"arama_kelimesi": aramaKelimesi},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.data);
      final List<dynamic> urunlerJson = jsonResponse['urunler'];
      return urunlerJson.map((e) => Urunler.fromJson(e)).toList();
    } else {
      throw Exception("Arama yapılamadı.");
    }
  }

  Future<List<Urunler>> kategoriyeGoreUrunleriGetir(String kategori) async {
    final response = await _dio.post(
      "kategoriyeGoreUrunleriGetir.php",
      data: {"kategori": kategori},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.data);
      final List<dynamic> urunlerJson = jsonResponse['urunler'];
      return urunlerJson.map((e) => Urunler.fromJson(e)).toList();
    } else {
      throw Exception("Kategori ürünleri alınamadı.");
    }
  }

  Future<List<Urunler>> fiyataGoreSirala(String siralama) async {
    final response = await _dio.post(
      "fiyataGoreSirala.php",
      data: {"siralama": siralama},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.data);
      final List<dynamic> urunlerJson = jsonResponse['urunler'];
      return urunlerJson.map((e) => Urunler.fromJson(e)).toList();
    } else {
      throw Exception("Ürünler sıralanamadı.");
    }
  }

  // 7. Resim URL'si (Sabit Base URL ile resme ulaşma)
  String getUrunResimUrl(String resimAdi) {
    return "http://kasimadalan.pe.hu/urunler/resimler/$resimAdi";
  }

  Future<List<Sepette>> sepetteUrunEkle(
    String kullaniciAdi,
    Urunler urun,
  ) async {
    try {
      print(
        'Sepete ürün ekleniyor - Kullanıcı: $kullaniciAdi, Ürün: ${urun.ad}',
      );

      final response = await _dio.post(
        "sepeteUrunEkle.php",
        data: {
          "ad": urun.ad,
          "resim": urun.resim,
          "kategori": urun.kategori,
          "fiyat": urun.fiyat.toString(),
          "marka": urun.marka,
          "siparisAdeti": "1",
          "kullaniciAdi": kullaniciAdi,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
          },
        ),
      );

      print('API Yanıtı: ${response.data}');
      print('Status Code: ${response.statusCode}');

      final jsonResponse =
          response.data is String ? json.decode(response.data) : response.data;

      if (response.statusCode == 200) {
        if (jsonResponse['success'] == 1) {
          // Ürün eklendikten sonra güncel sepeti getir
          return await sepetUrunleriniGetir(kullaniciAdi);
        } else {
          print('API Hata Mesajı: ${jsonResponse['message']}');
          return [];
        }
      }
      return [];
    } catch (e) {
      print('Sepete ürün ekleme hatası: $e');
      return [];
    }
  }

  Future<List<Sepette>> sepetUrunleriniGetir(String kullaniciAdi) async {
    try {
      print('Sepet ürünleri getiriliyor - Kullanıcı: $kullaniciAdi');

      final response = await _dio.post(
        "sepettekiUrunleriGetir.php",
        data: {"kullaniciAdi": kullaniciAdi},
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
          },
        ),
      );

      print('API Yanıtı: ${response.data}');
      print('Status Code: ${response.statusCode}');

      final jsonResponse =
          response.data is String ? json.decode(response.data) : response.data;

      if (response.statusCode == 200) {
        if (jsonResponse['success'] == 1) {
          if (jsonResponse['urunler_sepeti'] != null) {
            final List<dynamic> urunlerJson = jsonResponse['urunler_sepeti'];
            print('Ürünler JSON: $urunlerJson');

            try {
              final urunler =
                  urunlerJson.map((e) {
                    print('Dönüştürülen ürün: $e');
                    return Sepette.fromJson(e);
                  }).toList();

              print(
                '${kullaniciAdi} kullanıcısının sepetindeki ürün sayısı: ${urunler.length}',
              );
              return urunler;
            } catch (e) {
              print('Ürün dönüştürme hatası: $e');
              return [];
            }
          } else {
            print('Sepet boş');
            return [];
          }
        } else {
          print('API Hata Mesajı: ${jsonResponse['message']}');
          return [];
        }
      }
      return [];
    } on DioException catch (e) {
      print('Sepet ürünleri getirilirken Dio hatası: ${e.message}');
      print('Hata Detayı: ${e.error}');
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> sepettenUrunSil(String kullaniciAdi, int urunId) async {
    try {
      final response = await _dio.post(
        "sepettenUrunSil.php",
        data: {"kullaniciAdi": kullaniciAdi, "sepetId": urunId.toString()},
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
          },
        ),
      );

      print('Silme Yanıtı: ${response.data}');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse =
            response.data is String
                ? json.decode(response.data)
                : response.data;
        return jsonResponse['success'] == 1;
      }
      return false;
    } on DioException catch (e) {
      print('Sepetten ürün silme hatası: ${e.message}');
      print('Hata Detayı: ${e.error}');
      return false;
    } catch (e) {
      print('Sepetten ürün silme hatası: $e');
      return false;
    }
  }


  
}
