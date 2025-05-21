import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_shopping_techcareer/data/entity/sepette.dart';
import 'package:e_shopping_techcareer/ui/cubits/cart_cubit.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().getCartItems("emrah_isik");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sepetim')),
      body: BlocBuilder<CartCubit, List<Sepette>>(
        builder: (context, state) {
          if (state.isEmpty) {
            return const Center(
              child: Text('Sepetiniz boş', style: TextStyle(fontSize: 18)),
            );
          }

          return ListView.builder(
            itemCount: state.length,
            itemBuilder: (context, index) {
              final item = state[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Image.network(
                    "http://kasimadalan.pe.hu/urunler/resimler/${item.resim}",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(item.ad),
                  subtitle: Text('${item.fiyat} TL'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      context.read<CartCubit>().sepettenUrunSil(
                        "emrah_isik",
                        item.sepetId,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item.ad} sepetten kaldırıldı'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
