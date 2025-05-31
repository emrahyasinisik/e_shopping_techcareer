import 'package:e_shopping_techcareer/ui/screens/product_detail_screen.dart';
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
  // ignore: unused_field
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

  Map<String, List<Sepette>> groupCartItems(List<Sepette> items) { //buraya bak map ne idi tablo mu yoksa liste mi 
    //Sepette'leri adlarına göre gruplayan fonksiyon
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
    return items.fold(0, (sum, item) => sum + item.siparisAdeti); //fold nedir 
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
                    return GestureDetector(
                      onTap: () {
                        final urun = Urunler(
                          id: firstItem.sepetId,
                          ad: firstItem.ad,
                          resim: firstItem.resim,
                          kategori: firstItem.kategori,
                          fiyat: firstItem.fiyat,
                          marka: firstItem.marka,
                        );
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled:
                              true, // Klavye açıldığında modal yukarı kalksın diye
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder:
                              (context) => ProductDetailContent(urun: urun),
                        );
                      },
                      child: Card(
                        color: Colors.blueGrey[70],
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
                                          MainAxisAlignment.spaceBetween,
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
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
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
                                            color: Colors.white,
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
                                                          resim:
                                                              firstItem.resim,
                                                          kategori:
                                                              firstItem
                                                                  .kategori,
                                                          fiyat:
                                                              firstItem.fiyat,
                                                          marka:
                                                              firstItem.marka,
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
                                                          resim:
                                                              firstItem.resim,
                                                          fiyat:
                                                              firstItem.fiyat,
                                                          kategori:
                                                              firstItem
                                                                  .kategori,
                                                          marka:
                                                              firstItem.marka,
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
                                          '$totalItemPrice TL',
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
                      color: Colors.grey,
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        late AnimationController _controller;
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              content: Lottie.asset(
                                'images/cart_added.json',
                                width: MediaQuery.of(context).size.width * 0.25,
                                height:
                                    MediaQuery.of(context).size.height * 0.25,
                                repeat: false,
                                controller:
                                    _controller = AnimationController(
                                      vsync: this,
                                    ),
                                onLoaded: (composition) {
                                  _controller.duration = composition.duration;
                                  _controller.forward();
                                  _controller.addStatusListener((status) {
                                    if (status == AnimationStatus.completed) {
                                      Navigator.of(context).pop();
                                      context.read<CartCubit>().sepetiBosalt(
                                        "emrah_isik",
                                      );
                                    }
                                  });
                                },
                              ),
                            );
                          },
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
