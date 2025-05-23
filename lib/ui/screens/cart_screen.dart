import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_shopping_techcareer/data/entity/sepette.dart';
import 'package:e_shopping_techcareer/data/entity/urunler.dart';
import 'package:e_shopping_techcareer/ui/cubits/cart_cubit.dart';
import 'package:lottie/lottie.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showEmptyMessage = false;

  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().getCartItems("emrah_isik");
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showEmptyMessage = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Map<String, List<Sepette>> groupCartItems(List<Sepette> items) {
    Map<String, List<Sepette>> groupedItems = {};
    for (var item in items) {
      if (!groupedItems.containsKey(item.ad)) {
        groupedItems[item.ad] = [];
      }
      groupedItems[item.ad]!.add(item);
    }
    return groupedItems;
  }

  int getTotalQuantity(List<Sepette> items) {
    return items.fold(0, (sum, item) => sum + item.siparisAdeti);
  }

  int getTotalPrice(List<Sepette> items) {
    return items.fold(0, (sum, item) => sum + (item.fiyat * item.siparisAdeti));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<CartCubit, List<Sepette>>(
        builder: (context, state) {
          if (state.isEmpty) {
            _animationController.forward();
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'images/emptyCart.json',
                    repeat: true,
                    reverse: true,
                    animate: true,
                    frameRate: FrameRate.max,
                    controller: _animationController,
                    fit: BoxFit.contain,
                    width: 200,
                    height: 200,
                  ),
                ],
              ),
            );
          }

          _showEmptyMessage = false;
          _animationController.reset();

          final groupedItems = groupCartItems(state);
          final totalPrice = state.fold(
            0,
            (sum, item) => sum + (item.fiyat * item.siparisAdeti),
          );

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: groupedItems.length,
                  itemBuilder: (context, index) {
                    final productName = groupedItems.keys.elementAt(index);
                    final items = groupedItems[productName]!;
                    final firstItem = items.first;
                    final totalQuantity = getTotalQuantity(items);
                    final totalItemPrice = getTotalPrice(items);

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Image.network(
                              "http://kasimadalan.pe.hu/urunler/resimler/${firstItem.resim}",
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        firstItem.ad,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          await context
                                              .read<CartCubit>()
                                              .tumUrunuSepettenSil(
                                                "emrah_isik",
                                                Urunler(
                                                  id: items.first.sepetId,
                                                  ad: items.first.ad,
                                                  resim: items.first.resim,
                                                  kategori:
                                                      items.first.kategori,
                                                  fiyat: items.first.fiyat,
                                                  marka: items.first.marka,
                                                ),
                                              );
                                        },
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.red[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${firstItem.fiyat} TL',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove,
                                                size: 20,
                                              ),
                                              onPressed: () async {
                                                await context
                                                    .read<CartCubit>()
                                                    .sepettenUrunSil(
                                                      "emrah_isik",
                                                      Urunler(
                                                        id: firstItem.sepetId,
                                                        ad: firstItem.ad,
                                                        resim: firstItem.resim,
                                                        kategori:
                                                            firstItem.kategori,
                                                        fiyat: firstItem.fiyat,
                                                        marka: firstItem.marka,
                                                      ),
                                                    );
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              child: Text(
                                                totalQuantity.toString(),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.add,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                context
                                                    .read<CartCubit>()
                                                    .sepeteUrunEkle(
                                                      "emrah_isik",
                                                      Urunler(
                                                        id: firstItem.sepetId,
                                                        ad: firstItem.ad,
                                                        resim: firstItem.resim,
                                                        fiyat: firstItem.fiyat,
                                                        kategori:
                                                            firstItem.kategori,
                                                        marka: firstItem.marka,
                                                      ),
                                                    );
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${totalItemPrice} TL',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Toplam: $totalPrice TL',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Lottie.asset(
                                      'images/success.json', // Onay animasyonun varsa buraya ekle
                                      width: 120,
                                      height: 120,
                                      repeat: false,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Siparişiniz başarıyla alındı!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      context.read<CartCubit>().sepetiBosalt(
                                        "emrah_isik",
                                      );
                                    },
                                    child: const Text('Kapat'),
                                  ),
                                ],
                              ),
                        );
                      },
                      child: const Text('Sipariş Ver'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
