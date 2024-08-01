import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'orders_page.dart'; // OrdersPage import edin
import 'nav_bar.dart'; // NavBar import edin
import 'addresses_page.dart'; // AddressesPage import edin

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profilim'),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.all(10.0),
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  leading: Icon(Icons.shopping_bag, color: Colors.black),
                  title: Text('Siparişlerim', style: TextStyle(fontSize: 18, color: Colors.black)),
                  trailing: Icon(Icons.chevron_right, color: Colors.black),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrdersPage()), // OrdersPage sayfasına yönlendirilecek
                    );
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  leading: Icon(Icons.location_on, color: Colors.black),
                  title: Text('Adreslerim', style: TextStyle(fontSize: 18, color: Colors.black)),
                  trailing: Icon(Icons.chevron_right, color: Colors.black),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddressesPage()), // AddressesPage sayfasına yönlendirilecek
                    );
                  },
                ),
              ),
              // Diğer butonlar burada eklenebilir
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () => _signOut(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(20.0),
                backgroundColor: Color.fromARGB(255, 143, 24, 15),
                shape: CircleBorder(),
              ),
              child: Icon(Icons.logout, color: Colors.white),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyBottomNavBar(
        selectedIndex: 3, // Profil sayfasında 3. sıradaki seçeneği aktif hale getir
        onTabChange: (index) {
          // Alt gezinme çubuğunda seçilen endeksi güncellemek için
          // Navigator kullanmadığımız için bu fonksiyon şu an boş kalacak
          // Ancak ileride sayfa değişikliği yapılacaksa buraya gerekli kodlar eklenebilir
        },
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
