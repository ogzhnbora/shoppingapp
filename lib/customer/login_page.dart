import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalproject/customer/nav_bar.dart'; // MyBottomNavBar dosyasının yolu doğru olduğundan emin olun
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Kullanıcı bilgilerini Firestore'dan al
      DocumentSnapshot<Map<String, dynamic>> userInfo = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();
      String userType = userInfo['userType'];

      // Giriş başarılı, kullanıcıyı uygun sayfaya yönlendir.
      if (userType == "UserType.seller") {
        Navigator.pushReplacementNamed(context, '/seller_page');
      } else {
        Navigator.pushReplacementNamed(context, '/user_page');
      }
    } catch (e) {
      // Giriş başarısız, hata mesajı göster.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giriş yapılamadı. Hata: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giriş Yap'),
        automaticallyImplyLeading: false, // Geri butonunu kaldır
        centerTitle: true, // Başlık ortalanacak
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'ArtisanModa',
              style: GoogleFonts.lobster(
                textStyle: const TextStyle(
                  color: Color.fromARGB(255, 197, 130, 137)  ,
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'E-posta',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Şifre',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _signInWithEmailAndPassword(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                minimumSize: Size(double.infinity, 50.0),
                backgroundColor: Color.fromARGB(255, 95, 39, 42), // Butonun arka plan rengi
              ).copyWith(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Metin rengini beyaz yapar
              ),
              child: Text('Giriş Yap'),
            ),
            SizedBox(height: 20.0),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/register_page');
              },
              child: Text('Hesabınız yok mu? Kayıt olun'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MyBottomNavBar(
        selectedIndex: 3, // Giriş sayfasındayken 3. sıradaki seçeneği aktif hale getir
        onTabChange: (index) {
          // Alt gezinme çubuğunda seçilen endeksi güncellemek için
          // Navigator kullanmadığımız için bu fonksiyon şu an boş kalacak
          // Ancak ileride sayfa değişikliği yapılacaksa buraya gerekli kodlar eklenebilir
        },
      ),
    );
  }
}
