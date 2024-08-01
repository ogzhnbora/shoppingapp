import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final Function(String) onSelectGender;

  AppDrawer({required this.onSelectGender});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 100,  // Pembe kısmın yüksekliğini küçültün
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 197, 130, 137),
              ),
              child: Text(
                'Kategoriler',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          ListTile(
            title: Text('Kadın'),
            onTap: () {
              Navigator.pop(context);
              onSelectGender('Kadın'); // Kadın kategorisi tıklanınca yapılacak işlemler
            },
          ),
          ListTile(
            title: Text('Erkek'),
            onTap: () {
              Navigator.pop(context);
              onSelectGender('Erkek'); // Erkek kategorisi tıklanınca yapılacak işlemler
            },
          ),
        ],
      ),
    );
  }
}
