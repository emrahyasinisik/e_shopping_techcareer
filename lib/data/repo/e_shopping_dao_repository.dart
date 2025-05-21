import 'package:e_shopping_techcareer/data/entity/sepette.dart';
import 'package:e_shopping_techcareer/data/entity/urunler.dart';
import 'package:e_shopping_techcareer/data/services/api_services.dart';

class ShoppingDaoRepository {
  final ApiService _apiService = ApiService();

  Future<List<Urunler>> tumUrunleriGetir() async {
    try {
      final urunler = await _apiService.tumUrunleriGetir();
      return urunler;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Sepette>> sepeteUrunEkle(
    String kullaniciAdi,
    Urunler urun,
  ) async {
    try {
      final sepette = await _apiService.SepetteUrunEkle(kullaniciAdi, urun);
      return sepette;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> sepettenUrunSil(String kullaniciAdi, int urunId) async {
    try {
      final success = await _apiService.sepettenUrunSil(kullaniciAdi, urunId);
      return success;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Sepette>> sepetUrunleriniGetir(String kullaniciAdi) async {
    try {
      final sepette = await _apiService.sepetUrunleriniGetir(kullaniciAdi);
      return sepette;
    } catch (e) {
      rethrow;
    }
  }
}
