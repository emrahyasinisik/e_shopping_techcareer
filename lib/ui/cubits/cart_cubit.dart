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

  Future<void> sepettenUrunSil(String kullaniciAdi, int urunId) async {
    try {
      final success = await _repository.sepettenUrunSil(kullaniciAdi, urunId);
      if (success) {
        // Başarılı silme işleminden sonra sepeti güncelle
        final yeniSepet =
            state.where((item) => item.sepetId != urunId).toList();
        emit(yeniSepet);
      }
    } catch (e) {
      print('Sepetten ürün silme hatası: $e');
      emit(state);
    }
  }
}
