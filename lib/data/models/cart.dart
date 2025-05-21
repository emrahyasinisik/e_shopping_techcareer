class Cart {
  final int id;
  final String productName;
  final String image;
  final String category;
  final double price;
  final String brand;
  final int quantity;
  final String username;

  Cart({
    required this.id,
    required this.productName,
    required this.image,
    required this.category,
    required this.price,
    required this.brand,
    required this.quantity,
    required this.username,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: int.parse(json['id']),
      productName: json['ad'],
      image: json['resim'],
      category: json['kategori'],
      price: double.parse(json['fiyat']),
      brand: json['marka'],
      quantity: int.parse(json['siparisAdeti']),
      username: json['kullaniciAdi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'ad': productName,
      'resim': image,
      'kategori': category,
      'fiyat': price.toString(),
      'marka': brand,
      'siparisAdeti': quantity.toString(),
      'kullaniciAdi': username,
    };
  }
}
