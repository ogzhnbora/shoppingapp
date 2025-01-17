import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:finalproject/customer/home_page.dart';
import 'package:finalproject/customer/login_page.dart';
import 'package:finalproject/customer/register_page.dart';
import 'package:finalproject/customer/user_page.dart';
import 'package:finalproject/seller/seller_page.dart';
import 'package:provider/provider.dart';
import 'package:finalproject/customer/cart_model.dart';
import 'package:finalproject/customer/favorites_model.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

enum UserType {
  customer,  // Index 0
  seller     // Index 1
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
    await FirebaseAppCheck.instance.activate();
  

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Color.fromARGB(255, 197, 130, 137);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => FavoritesModel()),
      ],
      child: MaterialApp(
        title: 'ArtisanModa',
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: primaryColor,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.light(
            primary: primaryColor,
            surface: Colors.white,  // Burada background rengini belirtiyoruz
          ),
          textTheme: GoogleFonts.robotoTextTheme(
            Theme.of(context).textTheme,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          buttonTheme: ButtonThemeData(
            buttonColor: primaryColor,
            textTheme: ButtonTextTheme.primary,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.black,
          colorScheme: ColorScheme.dark(
            primary: Colors.black,
            background: Colors.grey[900],  // Burada background rengini belirtiyoruz
          ),
          scaffoldBackgroundColor: Colors.grey[850],
          cardColor: Colors.grey[850],
          hintColor: primaryColor,
          textTheme: GoogleFonts.robotoTextTheme(
            Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey[900],
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        themeMode: ThemeMode.light,
        home: SplashScreen(),  // SplashScreen'i buraya ekliyoruz
        routes: {
          '/login_page': (context) => LoginPage(),
          '/register_page': (context) => RegisterPage(),
          '/user_page': (context) => UserPage(),
          '/seller_page': (context) => SellerPage(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(Duration(milliseconds: 3000), () {});  // Splash screen'in ne kadar süre gösterileceğini belirliyoruz
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => InitialRouteDecider()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 197, 130, 137),
      body: Center(
        child: Text(
          'ArtisanModa',
          style: GoogleFonts.lobster(  // İstediğiniz yazı tipi
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 40,  // Daha büyük font boyutu
              fontWeight: FontWeight.bold,  // Kalın font
              letterSpacing: 1.5,  // Harfler arasına boşluk
            ),
          ),
        ),
      ),
    );
  }
}

class InitialRouteDecider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null && snapshot.data!.exists) {
              var userType = snapshot.data!['userType'];
              if (userType == "UserType.seller") {
                return SellerPage();
              } else {
                return HomePage();
              }
            } else {
              return HomePage();
            }
          } else {
            return Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      );
    } else {
      return HomePage();
    }
  }
}
