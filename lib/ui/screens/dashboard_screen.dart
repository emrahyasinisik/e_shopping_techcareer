import 'package:e_shopping_techcareer/ui/component/group_cart.dart';
import 'package:e_shopping_techcareer/ui/cubits/cart_cubit.dart';
import 'package:e_shopping_techcareer/ui/screens/main_screen.dart';
import 'package:e_shopping_techcareer/ui/screens/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = context.watch<CartCubit>().state;
    final groupedItems = GroupCart.groupCartItems(cartItems);

    int toplamUrunAdedi = groupedItems.values
        .expand((list) => list)
        .fold(0, (sum, item) => sum + item.siparisAdeti);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _selectedIndex == 0
              ? 'E-shopping'
              : _selectedIndex == 1
              ? 'Sepet'
              : '',
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Center(
        child: Padding(padding: const EdgeInsets.all(0), child: _buildBody()),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: Colors.grey,

        backgroundColor: Colors.white,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Container(
              height: MediaQuery.sizeOf(context).height * 0.05,
              width: MediaQuery.sizeOf(context).width * 0.05,
              alignment: Alignment.center,
              child: Icon(Icons.home),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Container(
              height: MediaQuery.sizeOf(context).height * 0.05,
              width: MediaQuery.sizeOf(context).width * 0.05,
              alignment: Alignment.center,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.shopping_cart),
                  if (toplamUrunAdedi > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            '$toplamUrunAdedi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.sizeOf(context).height * 0.015,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            label: 'Cart',
          ),
        ],
        currentIndex: _selectedIndex,

        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const MainScreen();
      case 1:
        return const CartScreen();
      default:
        return const MainScreen();
    }
  }
}
