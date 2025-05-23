import 'package:e_shopping_techcareer/data/entity/sepette.dart';
import 'package:flutter/material.dart';
import 'package:e_shopping_techcareer/data/entity/urunler.dart';
import 'package:e_shopping_techcareer/ui/cubits/cart_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class ProductDetailScreen extends StatefulWidget {
  final Urunler urun;

  const ProductDetailScreen({super.key, required this.urun});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> sepettenCikar(Urunler urun) async {
    try {
      await context.read<CartCubit>().sepettenUrunSil("emrah_isik", urun);
      // Sepeti yenile
      await context.read<CartCubit>().getCartItems("emrah_isik");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ürün sepetten çıkarıldı"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ürün çıkarılırken hata oluştu: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> sepeteEkle() async {
    setState(() {});

    try {
      await context.read<CartCubit>().sepeteUrunEkle("emrah_isik", widget.urun);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${widget.urun.ad} sepete eklendi"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ürün eklenirken hata oluştu: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.urun.ad,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ürün Resmi
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[100],
              child: Image.network(
                "http://kasimadalan.pe.hu/urunler/resimler/${widget.urun.resim}",
                fit: BoxFit.contain,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Marka ve Fiyat
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.urun.marka,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${widget.urun.fiyat} TL",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

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
                      widget.urun.kategori,
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Ürün Adı
                  const Text(
                    "Ürün Detayları",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    widget.urun.ad,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: sepeteEkle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: BlocBuilder<CartCubit, List<Sepette>>(
                  builder: (context, cartState) {
                    final isInCart = context.read<CartCubit>().isProductInCart(
                      widget.urun,
                    );
                    final quantity =
                        isInCart
                            ? context.read<CartCubit>().getProductQuantity(
                              widget.urun,
                            )
                            : 0;

                    if (isInCart) {
                      return Container(
                        margin: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 20),
                                    onPressed: () async {
                                      await sepettenCikar(widget.urun);
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
                            ),
                          ],
                        ),
                      );
                    }
                    return const Text(
                      'Sepete Ekle',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
