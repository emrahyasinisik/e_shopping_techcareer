import 'package:flutter/material.dart';
import '../../data/models/cart.dart';
import '../../data/services/cart_service.dart';

class CartView extends StatefulWidget {
  final String username;

  const CartView({Key? key, required this.username}) : super(key: key);

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final CartService _cartService = CartService();
  List<Cart> _cartItems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _cartService.getCartItems(widget.username);
      if (response.success) {
        setState(() {
          _cartItems = response.items ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _removeItem(int productId) async {
    final response = await _cartService.removeFromCart(
      widget.username,
      productId,
    );
    if (response.success) {
      _loadCartItems();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_cartItems.isEmpty) {
      return const Center(child: Text('Sepetiniz boş'));
    }

    return ListView.builder(
      itemCount: _cartItems.length,
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: Image.network(
              "http://kasimadalan.pe.hu/urunler/resimler/${item.image}",
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(item.productName),
            subtitle: Text('${item.price} TL - ${item.quantity} adet'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeItem(item.id),
            ),
          ),
        );
      },
    );
  }
}
