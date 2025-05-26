import 'package:e_shopping_techcareer/data/entity/urunler.dart';
import 'package:e_shopping_techcareer/data/entity/sepette.dart';
import 'package:e_shopping_techcareer/ui/cubits/main_cubit.dart';
import 'package:e_shopping_techcareer/ui/cubits/cart_cubit.dart';
import 'package:e_shopping_techcareer/ui/screens/product_detail_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  bool isCompleted = false;
  Map<String, bool> loadingStates = {};
  Map<String, AnimationController> animationControllers = {};
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    context.read<MainCubit>().urunleriGetir();
    context.read<CartCubit>().getCartItems("emrah_isik");
  }

  @override
  void dispose() {
    // Dispose all controllers when widget is disposed
    for (var controller in animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> sepettenCikar(Urunler urun) async {
    await context.read<CartCubit>().sepettenUrunSil("emrah_isik", urun);
    await context.read<CartCubit>().getCartItems("emrah_isik");
  }

  Future<void> sepeteEkle(Urunler urun) async {
    setState(() {
      loadingStates[urun.id.toString()] = true;
      if (!animationControllers.containsKey(urun.id.toString())) {
        animationControllers[urun.id.toString()] = AnimationController(
          vsync: this,
          duration: const Duration(seconds: 2),
        );
      }
      animationControllers[urun.id.toString()]?.stop();
      animationControllers[urun.id.toString()]?.reset();
      animationControllers[urun.id.toString()]?.forward();
    });

    try {
      await context.read<CartCubit>().sepeteUrunEkle("emrah_isik", urun);

      if (mounted) {
        print('Ürün sepete eklendi: ${urun.ad}');
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
    }

    // Animasyon süresi kadar bekle
    await Future.delayed(const Duration(seconds: 2));

    // Animasyon bittikten sonra sepeti yenile ve durumu güncelle
    if (mounted) {
      await context.read<CartCubit>().getCartItems("emrah_isik");
      setState(() {
        loadingStates[urun.id.toString()] = false;
        animationControllers[urun.id.toString()]?.stop();
        animationControllers[urun.id.toString()]?.reset();
      });
    }
  }

  // Sepetteki ürün miktarını artırma (animasyonsuz)
  Future<void> sepeteEkleHizli(Urunler urun) async {
    try {
      await context.read<CartCubit>().sepeteUrunEkle("emrah_isik", urun);
      await context.read<CartCubit>().getCartItems("emrah_isik");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${urun.ad} sepete eklendi"),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BlocBuilder<MainCubit, List<Urunler>>(
            builder: (context, state) {
              if (context.read<MainCubit>().isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.isEmpty) {
                return const Center(child: Text("Ürün bulunamadı"));
              }
              return Column(
                children: [
                  Container(
                    height: MediaQuery.sizeOf(context).height * 0.06,
                    width: double.infinity,
                    color: Colors.white,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount:
                          context
                              .read<MainCubit>()
                              .tumUrunler
                              .map((urun) => urun.kategori)
                              .toSet()
                              .length +
                          1,
                      itemBuilder: (BuildContext context, int index) {
                        final kategoriler =
                            context
                                .read<MainCubit>()
                                .tumUrunler
                                .map((urun) => urun.kategori)
                                .toSet()
                                .toList();

                        if (index == 0) {
                          return GestureDetector(
                            onTap: () {
                              context.read<MainCubit>().kategoriSec(null);
                            },
                            child: Container(
                              height: 60,
                              margin: const EdgeInsets.all(5),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Tüm Ürünler",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          context
                                                      .watch<MainCubit>()
                                                      .selectedCategory ==
                                                  null
                                              ? Colors.blue
                                              : Colors.black,
                                    ),
                                  ),
                                  if (context
                                          .watch<MainCubit>()
                                          .selectedCategory ==
                                      null)
                                    Container(
                                      margin: EdgeInsets.only(
                                        top:
                                            MediaQuery.sizeOf(context).height *
                                            0.003,
                                      ),
                                      width:
                                          MediaQuery.sizeOf(context).width *
                                          0.2,
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                          0.003,
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }

                        final kategori = kategoriler[index - 1];

                        return GestureDetector(
                          onTap: () {
                            context.read<MainCubit>().kategoriSec(kategori);
                          },
                          child: Container(
                            height: MediaQuery.sizeOf(context).height * 0.06,
                            margin: const EdgeInsets.all(5),
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.sizeOf(context).width * 0.003,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  kategori,
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.sizeOf(context).height *
                                        0.02,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        context
                                                    .watch<MainCubit>()
                                                    .selectedCategory ==
                                                kategori
                                            ? Colors.blue
                                            : Colors.black,
                                  ),
                                ),
                                if (context
                                        .watch<MainCubit>()
                                        .selectedCategory ==
                                    kategori)
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    width:
                                        MediaQuery.sizeOf(context).width *
                                        0.003,
                                    height:
                                        MediaQuery.sizeOf(context).width *
                                        0.003,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          Expanded(
            child: BlocBuilder<MainCubit, List<Urunler>>(
              builder: (context, state) {
                return GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio:
                        MediaQuery.sizeOf(context).width *
                        1 /
                        MediaQuery.sizeOf(context).height *
                        1.46,
                  ),
                  itemCount: state.length,
                  itemBuilder: (context, index) {
                    var urun = state[index];
                    return GestureDetector(
                      onTap: () {
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
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.5,
                        height: MediaQuery.sizeOf(context).height * 0.3,
                        child: Card(
                          color:
                              urun.ad == "Bilgisayar"
                                  ? Colors.red[100]
                                  : urun.ad == "Gözlük"
                                  ? Colors.green[100]
                                  : urun.ad == "Kulaklık"
                                  ? Colors.blue[100]
                                  : urun.ad == "Parfüm"
                                  ? Colors.yellow[100]
                                  : urun.ad == "Saat"
                                  ? Colors.purple[100]
                                  : urun.ad == "Telefon"
                                  ? Colors.orange[100]
                                  : urun.ad == "Deodorant"
                                  ? Colors.pink[100]
                                  : urun.ad == "Ruj"
                                  ? Colors.brown[100]
                                  : urun.ad == "Krem"
                                  ? Colors.teal[100]
                                  : urun.ad == "Şapka"
                                  ? Colors.grey[100]
                                  : urun.ad == "Kemer"
                                  ? Colors.cyan[100]
                                  : Colors.grey[100],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                          0.22,
                                      padding: EdgeInsets.all(0),
                                      margin: EdgeInsets.all(
                                        MediaQuery.sizeOf(context).width * 0,
                                      ),
                                      child: Image.network(
                                        fit: BoxFit.fill,
                                        "http://kasimadalan.pe.hu/urunler/resimler/${urun.resim}",
                                        // scale:
                                        //     MediaQuery.sizeOf(context).width *
                                        //     0.004,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.sizeOf(context).width * 0.01,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${urun.marka}",
                                          style: TextStyle(
                                            fontSize:
                                                MediaQuery.sizeOf(
                                                  context,
                                                ).width *
                                                0.05,
                                            fontFamily: "Oswald",
                                          ),
                                        ),
                                        Text('${urun.ad}'),
                                        Text(
                                          "${urun.fiyat} ₺ ",
                                          style: TextStyle(
                                            fontSize:
                                                MediaQuery.sizeOf(
                                                  context,
                                                ).width *
                                                0.04,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    BlocBuilder<CartCubit, List<Sepette>>(
                                      builder: (context, cartState) {
                                        final isInCart = context
                                            .read<CartCubit>()
                                            .isProductInCart(urun);
                                        final quantity =
                                            isInCart
                                                ? context
                                                    .read<CartCubit>()
                                                    .getProductQuantity(urun)
                                                : 0;
                                        final isLoading =
                                            loadingStates[urun.id.toString()] ==
                                            true;
                                        // Eğer loading durumunda değilse ve sepette varsa + - göster
                                        if (!isLoading && isInCart) {
                                          return SizedBox(
                                            height:
                                                MediaQuery.sizeOf(
                                                  context,
                                                ).height *
                                                0.082,

                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height:
                                                      MediaQuery.sizeOf(
                                                        context,
                                                      ).height *
                                                      0.015,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.all(
                                                        0,
                                                      ),
                                                      margin: EdgeInsets.all(0),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          IconButton(
                                                            icon: Icon(
                                                              Icons.remove,
                                                            ),
                                                            onPressed: () async {
                                                              await sepettenCikar(
                                                                urun,
                                                              );
                                                              if (mounted) {
                                                                context
                                                                    .read<
                                                                      CartCubit
                                                                    >()
                                                                    .getCartItems(
                                                                      "emrah_isik",
                                                                    );
                                                              }
                                                            },
                                                            padding:
                                                                EdgeInsets.zero,
                                                          ),
                                                          Text(
                                                            quantity.toString(),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  MediaQuery.sizeOf(
                                                                    context,
                                                                  ).width *
                                                                  0.04,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          IconButton(
                                                            icon: Icon(
                                                              Icons.add,
                                                              size:
                                                                  MediaQuery.sizeOf(
                                                                    context,
                                                                  ).width *
                                                                  0.04,
                                                            ),
                                                            onPressed: () async {
                                                              await sepeteEkleHizli(
                                                                urun,
                                                              ); // Hızlı ekleme fonksiyonu
                                                            },
                                                            padding:
                                                                EdgeInsets.zero,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        }

                                        // Loading durumunda veya sepette yoksa animasyon butonunu göster
                                        return ElevatedButton(
                                          onPressed:
                                              isLoading
                                                  ? null
                                                  : () => sepeteEkle(urun),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.all(0),
                                            backgroundColor: Colors.transparent,
                                            foregroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            surfaceTintColor:
                                                Colors.transparent,
                                            iconColor: Colors.transparent,
                                            overlayColor: Colors.transparent,
                                            disabledBackgroundColor:
                                                Colors.transparent,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(0),
                                            margin: const EdgeInsets.all(0),
                                            height:
                                                MediaQuery.sizeOf(
                                                  context,
                                                ).width *
                                                0.15,
                                            width:
                                                MediaQuery.sizeOf(
                                                  context,
                                                ).width *
                                                0.15,
                                            child: Lottie.asset(
                                              'images/addcart1.json',
                                              repeat: false,
                                              animate: isLoading,
                                              frameRate: FrameRate.max,
                                              controller:
                                                  animationControllers[urun.id
                                                      .toString()],
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.sizeOf(context).height * 0.001,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
