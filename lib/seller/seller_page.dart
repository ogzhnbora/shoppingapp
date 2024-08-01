import 'package:finalproject/seller/seller_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'seller_nav_bar.dart';
import 'product_list_page.dart';
import 'product_form_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'seller_order_page.dart';
import 'seller_home_page.dart'; // SellerHomePage import edildi

class SellerPage extends StatefulWidget {
  @override
  _SellerPageState createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  int _selectedIndex = 0; // Default olarak "Panelim" seçili
  String? userID;
  List<Widget> _widgetOptions = [];
  int orderCount = 0;

  @override
  void initState() {
    super.initState();
    fetchUserID().then((id) {
      setState(() {
        userID = id;
        _widgetOptions = [
          SellerHomePage(sellerId: userID!), // SellerHomePage eklenmiş
          ProductListPage(userID: userID!), // userID ile güncellenmiş
          SellerOrderPage(
            sellerId: userID!,
            onOrderCountUpdated: _updateOrderCount, // Sipariş sayısını güncelleme fonksiyonunu ekle
          ), // SellerOrderPage eklenmiş
          SellerProfilePage()
        ];
      });
    });
  }

  Future<String> fetchUserID() async {
    String userId = FirebaseAuth.instance.currentUser!.uid; // Kullanıcının UID'sini al
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>; // Veriyi Map'e çevir
      return userData['userID']; // userID bilgisini çek
    } else {
      throw Exception('User not found');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _updateOrderCount(int count) {
    setState(() {
      orderCount = count;
    });
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/user_page');
    } catch (e) {
      print('Çıkış yapılamadı: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.length > _selectedIndex
            ? _widgetOptions.elementAt(_selectedIndex)
            : CircularProgressIndicator(), // Listeyi yüklerken bekleme göstergesi
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        orderCount: orderCount, // Sipariş sayısını iletin
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductFormPage()),
                );
              },
              tooltip: 'Ürün Ekle',
              child: Icon(Icons.add),
            )
          : null, // Diğer sayfalarda FAB gösterme
    );
  }
}
