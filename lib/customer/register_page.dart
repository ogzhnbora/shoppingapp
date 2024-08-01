import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

enum UserType { customer, seller }

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController taxNumberController = TextEditingController();
  final TextEditingController taxOfficeController = TextEditingController();

  UserType userType = UserType.customer; // Default olarak müşteri olarak başlasın

  String generateUserID() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(10, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<void> _registerWithEmailAndPassword(BuildContext context) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String userID = generateUserID(); // Benzersiz kullanıcı kimliği oluştur

      // Kullanıcı bilgilerini Firestore'e kaydet
      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set({
        'email': emailController.text.trim(),
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'birthDate': userType == UserType.customer ? birthDateController.text.trim() : null,
        'userType': userType.toString(),
        'userID': userID, // Kullanıcı kimliğini kaydet
        if (userType == UserType.seller) 'company': companyController.text.trim(),
        if (userType == UserType.seller) 'taxNumber': taxNumberController.text.trim(),
        if (userType == UserType.seller) 'taxOffice': taxOfficeController.text.trim(),
      });

      // Kayıt başarılı, uygun sayfaya yönlendir.
      if (userType == UserType.customer) {
        Navigator.pushReplacementNamed(context, '/user_page');
      } else {
        Navigator.pushReplacementNamed(context, '/seller_page');
      }
    } catch (e) {
      // Kayıt başarısız, hata mesajı göster.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt oluşturulamadı. Hata: $e')),
      );
    }
  }

  void _birthDateFormatter() {
    final text = birthDateController.text.replaceAll(RegExp(r'\D'), ''); // Sadece sayıları al
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(text[i]);
    }
    birthDateController.value = TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }

  @override
  void initState() {
    super.initState();
    birthDateController.addListener(_birthDateFormatter);
  }

  @override
  void dispose() {
    birthDateController.removeListener(_birthDateFormatter);
    birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/login_page');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Kayıt Ol'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  UserTypeSelector(
                    title: 'Müşteri',
                    isSelected: userType == UserType.customer,
                    onTap: () {
                      setState(() {
                        userType = UserType.customer;
                      });
                    },
                  ),
                  UserTypeSelector(
                    title: 'Satıcı',
                    isSelected: userType == UserType.seller,
                    onTap: () {
                      setState(() {
                        userType = UserType.seller;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 30),
              buildUserTypeFields(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUserTypeFields() {
    List<Widget> fields = [
      CustomTextField(
        controller: firstNameController,
        labelText: userType == UserType.customer ? 'İsim' : 'Yetkili İsim',
        icon: Icons.person,
      ),
      CustomTextField(
        controller: lastNameController,
        labelText: userType == UserType.customer ? 'Soyisim' : 'Yetkili Soyisim',
        icon: Icons.person_outline,
      ),
    ];

    if (userType == UserType.customer) {
      fields.add(CustomTextField(
        controller: birthDateController,
        labelText: 'Doğum Tarihi',
        icon: Icons.date_range,
        keyboardType: TextInputType.number,
      ));
    } else if (userType == UserType.seller) {
      fields.addAll([
        CustomTextField(
          controller: companyController,
          labelText: 'Şirket İsmi',
          icon: Icons.business,
        ),
        CustomTextField(
          controller: taxNumberController,
          labelText: 'Vergi Numarası',
          icon: Icons.money_off,
        ),
        CustomTextField(
          controller: taxOfficeController,
          labelText: 'Vergi Dairesi',
          icon: Icons.location_city,
        ),
      ]);
    }

    fields.addAll([
      CustomTextField(
        controller: emailController,
        labelText: 'E-posta',
        icon: Icons.email,
      ),
      CustomTextField(
        controller: passwordController,
        labelText: 'Şifre',
        icon: Icons.lock,
        obscureText: true,
      ),
      SizedBox(height: 20),
      ElevatedButton(
        onPressed: () => _registerWithEmailAndPassword(context),
        child: Text('Kayıt Ol'),
      ),
    ]);

    return Column(children: fields);
  }

  Widget UserTypeSelector({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
            height: 2,
            width: 175,
            color: isSelected ? Colors.blue : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget CustomTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
      ),
    );
  }
}
