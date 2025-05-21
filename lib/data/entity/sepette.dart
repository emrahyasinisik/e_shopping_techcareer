class Sepette {
  final int sepetId;
  final String ad;
  final String resim;
  final String kategori;
  final int fiyat;
  final String marka;
  final String kullaniciAdi;
  final int siparisAdeti;

  Sepette({
    required this.sepetId,
    required this.ad,
    required this.resim,
    required this.kategori,
    required this.fiyat,
    required this.marka,
    required this.kullaniciAdi,
    this.siparisAdeti = 1,
  });

  factory Sepette.fromJson(Map<String, dynamic> json) {
    try {
      return Sepette(
        sepetId: json['sepetId'] as int,
        ad: json['ad'] as String,
        resim: json['resim'] as String,
        kategori: json['kategori'] as String,
        fiyat: json['fiyat'] as int,
        marka: json['marka'] as String,
        kullaniciAdi: json['kullaniciAdi'] as String,
        siparisAdeti: json['siparisAdeti'] as int,
      );
    } catch (e) {
      print('Sepette.fromJson hatası: $e');
      print('Hatalı JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'sepetId': sepetId,
      'ad': ad,
      'resim': resim,
      'kategori': kategori,
      'fiyat': fiyat,
      'marka': marka,
      'kullaniciAdi': kullaniciAdi,
      'siparisAdeti': siparisAdeti,
    };
  }
}
