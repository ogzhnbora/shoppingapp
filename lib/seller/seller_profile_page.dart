import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SellerProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
     
    return Scaffold(
      appBar: AppBar(
        title: Text('Profilim'),
                automaticallyImplyLeading: false,),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profil içeriği buraya eklenebilir
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _signOut(context),
        child: Icon(Icons.logout, color: Colors.black),
        tooltip: 'Çıkış Yap ',
 // Çıkış simgesi
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login_page');
    } catch (e) {
      print('Çıkış yapılamadı: $e');
    }
  }
}
