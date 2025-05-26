import 'package:e_shopping_techcareer/data/entity/sepette.dart';
import 'package:flutter/material.dart';
import 'package:e_shopping_techcareer/data/entity/urunler.dart';
import 'package:e_shopping_techcareer/ui/cubits/cart_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDetailContent extends StatefulWidget {
  final Urunler urun;

  const ProductDetailContent({super.key, required this.urun});

  @override
  State<ProductDetailContent> createState() => _ProductDetailContentState();
}

class _ProductDetailContentState extends State<ProductDetailContent> {
  Future<void> sepettenCikar(Urunler urun) async {
    await context.read<CartCubit>().sepettenUrunSil("emrah_isik", urun);
    await context.read<CartCubit>().getCartItems("emrah_isik");
  }

  Future<void> sepeteEkle() async {
    await context.read<CartCubit>().sepeteUrunEkle("emrah_isik", widget.urun);
  }

  @override
  Widget build(BuildContext context) {
    final urun = widget.urun;

    return Padding(
      padding:
          MediaQuery.of(
            context,
          ).viewInsets, // Klavye varsa modal yukarı kalksın
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width * 0.02,
          vertical: MediaQuery.sizeOf(context).height * 0.015,
        ),
        // Modal'da yüksekliği içeriğe göre ayarla
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.95,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Küçük sürükleme barı
              Center(
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.sizeOf(context).height * 0.02,
                  ),
                  width: MediaQuery.sizeOf(context).width * 0.15,
                  height: MediaQuery.sizeOf(context).width * 0.018,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Ürün resmi
              Container(
                height: MediaQuery.sizeOf(context).height * 0.4,
                width: double.infinity,
                color: Colors.grey[100],
                child: Image.network(
                  "http://kasimadalan.pe.hu/urunler/resimler/${urun.resim}",
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),

              // Marka
              Text(
                urun.marka,
                style: TextStyle(
                  fontSize: MediaQuery.sizeOf(context).height * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),

              // Kategori
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  urun.kategori,
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Ürün Detayları başlığı
              const Text(
                "Ürün Detayları",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                urun.ad,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 20),

              // Alt bar - Sepete ekle + miktar kontrolü
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.sizeOf(context).height * 0.01,
                ),
                child: BlocBuilder<CartCubit, List<Sepette>>(
                  builder: (context, cartState) {
                    final isInCart = context.read<CartCubit>().isProductInCart(
                      urun,
                    );
                    final quantity =
                        isInCart
                            ? context.read<CartCubit>().getProductQuantity(urun)
                            : 0;

                    if (isInCart) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Fiyat : ${urun.fiyat * quantity} TL",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 20),
                                onPressed: () async {
                                  await sepettenCikar(urun);
                                  if (mounted) {
                                    context.read<CartCubit>().getCartItems(
                                      "emrah_isik",
                                    );
                                  }
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  quantity.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 20),
                                onPressed: () async {
                                  await sepeteEkle();
                                  if (mounted) {
                                    context.read<CartCubit>().getCartItems(
                                      "emrah_isik",
                                    );
                                  }
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: sepeteEkle,
                        child: const Text(
                          'Sepete Ekle',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
