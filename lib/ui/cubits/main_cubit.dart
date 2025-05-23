import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_shopping_techcareer/data/entity/urunler.dart';
import 'package:e_shopping_techcareer/data/services/api_services.dart';

class MainCubit extends Cubit<List<Urunler>> {
  final ApiService _apiService = ApiService();
  bool isLoading = false;
  String? selectedCategory;
  List<Urunler> tumUrunler = [];

  MainCubit() : super([]);

  Future<void> urunleriGetir() async {
    isLoading = true;
    emit(state);

    try {
      final urunler = await _apiService.tumUrunleriGetir();
      tumUrunler = urunler;
      emit(urunler);
    } catch (e) {
      // Hata durumunda boş liste emit ediyoruz
      emit([]);
    } finally {
      isLoading = false;
      emit(state);
    }
  }

  void kategoriSec(String? kategori) {
    selectedCategory = kategori;
    if (kategori == null) {
      emit(tumUrunler);
    } else {
      final filtrelenmisUrunler =
          tumUrunler.where((urun) => urun.kategori == kategori).toList();
      emit(filtrelenmisUrunler);
    }
  }

  List<Urunler> getFiltrelenmisUrunler() {
    if (selectedCategory == null) {
      return state;
    }
    return state.where((urun) => urun.kategori == selectedCategory).toList();
  }

  Future<void> searchUrunler(String searchText) async {
    isLoading = true;
    emit(state);

    try {
      final aramaSonucu = await _apiService.urunAra(searchText);
      emit(aramaSonucu);
    } catch (e) {
      emit([]);
    } finally {
      isLoading = false;
      emit(state);
    }
  }
  
}
