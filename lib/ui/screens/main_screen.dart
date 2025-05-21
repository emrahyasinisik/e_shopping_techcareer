import 'package:e_shopping_techcareer/data/entity/urunler.dart';
import 'package:e_shopping_techcareer/ui/cubits/main_cubit.dart';
import 'package:e_shopping_techcareer/ui/cubits/cart_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Map<String, bool> loadingStates = {};

  @override
  void initState() {
    super.initState();
    context.read<MainCubit>().urunleriGetir();
  }

  Future<void> sepeteEkle(Urunler urun) async {
    setState(() {
      loadingStates[urun.id.toString()] = true;
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
    } finally {
      if (mounted) {
        setState(() {
          loadingStates[urun.id.toString()] = false;
        });
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
                    height: 60,
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
                            height: 60,
                            margin: const EdgeInsets.all(5),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  kategori,
                                  style: TextStyle(
                                    fontSize: 18,
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: state.length,
                  itemBuilder: (context, index) {
                    var urun = state[index];
                    return GestureDetector(
                      onTap: () {},
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
                                  Text("Fiyat: ${urun.fiyat} ₺"),
                                  ElevatedButton(
                                    onPressed:
                                        loadingStates[urun.id.toString()] ==
                                                true
                                            ? null
                                            : () => sepeteEkle(urun),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child:
                                        loadingStates[urun.id.toString()] ==
                                                true
                                            ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                            : const Text(
                                              "Sepete Ekle",
                                              style: TextStyle(fontSize: 16),
                                            ),
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
