import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_shopping_techcareer/data/entity/urunler.dart';
import 'package:e_shopping_techcareer/data/entity/sepette.dart';
import 'package:e_shopping_techcareer/data/repo/e_shopping_dao_repository.dart';

class CartCubit extends Cubit<List<Sepette>> {
  
  final ShoppingDaoRepository _repository = ShoppingDaoRepository();

  CartCubit() : super([]);

  Future<void> getCartItems(String kullaniciAdi) async {
    try {
      final sepette = await _repository.sepetUrunleriniGetir(kullaniciAdi);
      emit(sepette);
    } catch (e) {
      print('Sepet ürünleri getirme hatası: $e');
      emit(state);
    }
  }

  Future<void> sepeteUrunEkle(String kullaniciAdi, Urunler urun) async {
    try {
      final sepette = await _repository.sepeteUrunEkle(kullaniciAdi, urun);
      emit(sepette);
    } catch (e) {
      print('Sepete ürün ekleme hatası: $e');
      emit(state);
    }
  }

  Future<void> sepettenUrunSil(String kullaniciAdi, Urunler urun) async {
    try {
      // Önce ürünün sepetId'sini bul
      final cartItem = state.firstWhere(
        (item) => item.ad == urun.ad,
        orElse:
            () => Sepette(
              sepetId: -1,
              ad: '',
              resim: '',
              kategori: '',
              fiyat: 0,
              marka: '',
              kullaniciAdi: '',
              siparisAdeti: 0,
            ),
      );

      if (cartItem.sepetId != -1) {
        final success = await _repository.sepettenUrunSil(
          kullaniciAdi,
          cartItem.sepetId,
        );
        if (success) {
          // Başarılı silme işleminden sonra güncel sepeti getir
          final yeniSepet = await _repository.sepetUrunleriniGetir(
            kullaniciAdi,
          );
          emit(yeniSepet);
        }
      }
    } catch (e) {
      print('Sepetten ürün silme hatası: $e');
      emit(state);
    }
  }

  bool isProductInCart(Urunler urun) {
    return state.any((item) => item.ad == urun.ad);
  }

  int getProductQuantity(Urunler urun) {
    // Aynı üründen olan tüm miktarları topla
    return state
        .where((item) => item.ad == urun.ad)
        .fold(0, (total, item) => total + item.siparisAdeti);
  }

  Future<void> sepetiBosalt(String kullaniciAdi) async {
    try {
      for (var item in List<Sepette>.from(state)) {
        await sepettenUrunSil(
          kullaniciAdi,
          Urunler(
            id: item.sepetId,
            ad: item.ad,
            resim: item.resim,
            kategori: item.kategori,
            fiyat: item.fiyat,
            marka: item.marka,
          ),
        );
      }
      await getCartItems(kullaniciAdi);
    } catch (e) {
      print('Sepeti boşaltırken hata: $e');
    }
  }

  Future<void> tumUrunuSepettenSil(String kullaniciAdi, Urunler urun) async {
    try {
      // Aynı üründen sepettekilerin tümünü bul
      final cartItems = state.where((item) => item.ad == urun.ad).toList();

      for (var cartItem in cartItems) {
        final success = await _repository.sepettenUrunSil(
          kullaniciAdi,
          cartItem.sepetId,
        );
        if (!success) {
          print('Ürün silinemedi: ${cartItem.sepetId}');
        }
      }

      // Silme işlemlerinden sonra güncel sepeti getir
      final yeniSepet = await _repository.sepetUrunleriniGetir(kullaniciAdi);
      emit(yeniSepet);
    } catch (e) {
      print('Tüm ürünü sepetten silme hatası: $e');
      emit(state);
    }
  }
}
