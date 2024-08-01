import 'package:flutter/material.dart';
import 'package:flutter_badged/flutter_badge.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final int orderCount;

  CustomBottomNavigationBar({
    required this.selectedIndex,
    required this.onItemTapped,
    required this.orderCount,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Ana Sayfa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Panelim',
        ),
        BottomNavigationBarItem(
          icon: FlutterBadge(
            icon: Icon(Icons.shopping_cart),
            itemCount: orderCount,
            badgeColor: Colors.red,
            hideZeroCount: true,
          ),
          label: 'Siparişlerim',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profilim',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Color.fromARGB(255, 92, 96, 101),
      unselectedItemColor: Color.fromARGB(255, 92, 96, 101),
      onTap: onItemTapped,
    );
  }
}
