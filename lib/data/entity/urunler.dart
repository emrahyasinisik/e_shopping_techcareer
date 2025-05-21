class Urunler {
  final int id;
  final String ad;
  final String resim;
  final String kategori;
  final int fiyat;
  final String marka;

  Urunler({
    required this.id,
    required this.ad,
    required this.resim,
    required this.kategori,
    required this.fiyat,
    required this.marka,
  });

  factory Urunler.fromJson(Map<String, dynamic> json) {
    try {
      return Urunler(
        id:
            json['id'] is int
                ? json['id']
                : int.tryParse(json['id'].toString()) ?? 0,
        ad: json['ad']?.toString() ?? '',
        resim: json['resim']?.toString() ?? '',
        kategori: json['kategori']?.toString() ?? '',
        fiyat:
            json['fiyat'] is int
                ? json['fiyat']
                : int.tryParse(json['fiyat'].toString()) ?? 0,
        marka: json['marka']?.toString() ?? '',
      );
    } catch (e) {
      print('Urunler.fromJson hatası: $e');
      print('Hatalı JSON: $json');
      rethrow;
    }
  }
}
