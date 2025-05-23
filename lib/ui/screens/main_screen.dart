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
                                      margin: const EdgeInsets.only(top: 5),
                                      width: 30,
                                      height: 3,
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
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  kategori,
                                  style: TextStyle(
                                    fontSize: MediaQuery.sizeOf(context).height * 0.06,
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
                                    width: 30,
                                    height: 3,
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
                        1.3,
                  ),
                  itemCount: state.length,
                  itemBuilder: (context, index) {
                    var urun = state[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProductDetailScreen(urun: urun),
                          ),
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
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.all(8),
                                      child: Image.network(
                                        "http://kasimadalan.pe.hu/urunler/resimler/${urun.resim}",
                                        scale: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "${urun.marka}",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontFamily: "Oswald",
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${urun.ad}"),
                                  Text("${urun.fiyat} ₺"),
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
                                        return Container(
                                          margin: const EdgeInsets.only(top: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.remove,
                                                        size: 20,
                                                      ),
                                                      onPressed: () async {
                                                        await sepettenCikar(
                                                          urun,
                                                        );
                                                        if (mounted) {
                                                          context
                                                              .read<CartCubit>()
                                                              .getCartItems(
                                                                "emrah_isik",
                                                              );
                                                        }
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
                                                        quantity.toString(),
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.add,
                                                        size: 20,
                                                      ),
                                                      onPressed: () async {
                                                        await sepeteEkleHizli(
                                                          urun,
                                                        ); // Hızlı ekleme fonksiyonu
                                                      },
                                                      padding: EdgeInsets.zero,
                                                      constraints:
                                                          const BoxConstraints(),
                                                    ),
                                                  ],
                                                ),
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
                                          surfaceTintColor: Colors.transparent,
                                          iconColor: Colors.transparent,
                                          overlayColor: Colors.transparent,
                                          disabledBackgroundColor:
                                              Colors.transparent,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(0),
                                          margin: const EdgeInsets.all(0),
                                          height: 50,
                                          width: 50,
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
