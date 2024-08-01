import 'package:finalproject/customer/home_page.dart';
import 'package:finalproject/customer/login_page.dart';
import 'package:finalproject/customer/user_page.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:finalproject/customer/favourites_page.dart';
import 'package:finalproject/customer/cart_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:finalproject/customer/cart_model.dart';

class MyBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChange;

  const MyBottomNavBar({
    required this.selectedIndex,
    required this.onTabChange,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Güncellenmiş arka plan rengi
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
          child: GNav(
            backgroundColor: Colors.white, // Tab bar arka plan rengi
            color: Colors.grey[800], // İkonların pasif haldeki rengi
            activeColor: Color.fromARGB(255, 197, 130, 137), // İkonların aktif haldeki rengi
            tabBackgroundColor: Colors.teal.withOpacity(0.1), // Aktif tab'ın arka plan rengi
            gap: 8,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            selectedIndex: selectedIndex,
            tabs: [
              const GButton(
                icon: Icons.home,
                text: "Ana Sayfa",
              ),
              GButton(
                icon: Icons.shopping_cart,
                text: "Sepetim",
                leading: Stack(
                  children: [
                    const Icon(Icons.shopping_cart),
                    if (cart.totalItems > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 143, 24, 15),
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            '${cart.totalItems}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const GButton(
                icon: Icons.favorite,
                text: "Favorilerim",
              ),
              const GButton(
                icon: Icons.person,
                text: "Profil",
              ),
            ],
            onTabChange: (index) {
              onTabChange(index);
              _navigateToPage(context, index);
            },
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const CartPage();
        break;
      case 2:
        page = const FavoritesPage();
        break;
      case 3:
        if (FirebaseAuth.instance.currentUser != null) {
          page = UserPage();
        } else {
          page = LoginPage();
        }
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration(seconds: 0),
      ),
    );
  }
}
