import 'package:flutter/material.dart';
import 'package:finalproject/customer/cart_model.dart';
import 'package:finalproject/customer/firebase_service.dart';
import 'package:provider/provider.dart';
import 'add_address_page.dart';
import 'addresses_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  _PurchasePageState createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, dynamic>? userAddress;
  List<Map<String, dynamic>>? userAddresses;

  @override
  void initState() {
    super.initState();
    _loadUserAddress();
  }

  Future<void> _loadUserAddress() async {
    List<Map<String, dynamic>>? addresses = await _firebaseService.getUserAddresses();
    setState(() {
      userAddresses = addresses;
      if (addresses != null && addresses.isNotEmpty) {
        userAddress = addresses[0];
      }
    });
  }

  Future<void> _completePurchase(BuildContext context) async {
    final cart = Provider.of<CartModel>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Satın almak için lütfen giriş yapınız.')),
      );
      return;
    }

    for (var item in cart.items) {
      String sellerId = item.userID;
      String productId = item.id; // Ürün oluşturulurken kullanılan productId
      double price = item.price; // Ürünün fiyatı
      int quantity = cart.getQuantity(item); // Ürünün miktarı
      Map<String, dynamic> orderData = {
        'userId': user.uid,
        'userAddress': userAddress,
        'productId': productId,
        'sellerId': sellerId,
        'price': price * quantity, // Toplam fiyat
        'quantity': quantity, // Ürün miktarı
        'orderDate': Timestamp.now(),
        'status': 'kargoya verilmesi için bekleniyor',
      };
      await FirebaseFirestore.instance.collection('orders').add(orderData);
    }

    cart.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Satın alma işlemi tamamlandı.'),
      backgroundColor: Color.fromARGB(255, 197, 130, 137), // Arka plan rengini değiştirdik
                                  duration: Duration(seconds: 1),
    ));

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);
    double shippingCost = 20.0;
    double total = cart.totalPrice + shippingCost;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Satın Alma'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  var product = cart.items[index];
                  var quantity = cart.getQuantity(product);
                  return ListTile(
                    leading: Image.network(product.imageUrl),
                    title: Text(product.name),
                    subtitle: Text('₺${(product.price * quantity).toStringAsFixed(2)} (Adet: $quantity)'),
                  );
                },
              ),
              SizedBox(height: 20),
              if (userAddress == null)
                ElevatedButton(
                  onPressed: () async {
                    final address = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddAddressPage()),
                    );
                    if (address != null) {
                      setState(() {
                        userAddress = address;
                      });
                    }
                  },
                  child: Text('Adres Ekle'),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<Map<String, dynamic>>(
                      isExpanded: true,
                      value: userAddress,
                      items: userAddresses!.map((address) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: address,
                          child: Text(address['title']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          userAddress = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddressesPage()),
                        ).then((_) {
                          _loadUserAddress();
                        });
                      },
                      child: Text('Tüm Adreslerim'),
                    ),
                    SizedBox(height: 20),
                    Text('Adres Başlığı: ${userAddress!['title']}', style: TextStyle(fontSize: 18)),
                    Text('Sokak/Cadde: ${userAddress!['street']}', style: TextStyle(fontSize: 18)),
                    Text('Apartman No: ${userAddress!['buildingNo']}', style: TextStyle(fontSize: 18)),
                    Text('Daire No: ${userAddress!['apartmentNo']}', style: TextStyle(fontSize: 18)),
                    Text('Mahalle: ${userAddress!['neighborhood']}', style: TextStyle(fontSize: 18)),
                    Text('İl: ${userAddress!['city']}', style: TextStyle(fontSize: 18)),
                    Text('İlçe: ${userAddress!['district']}', style: TextStyle(fontSize: 18)),
                    Text('Telefon: ${userAddress!['phone']}', style: TextStyle(fontSize: 18)),
                    Text('İsim: ${userAddress!['name']}', style: TextStyle(fontSize: 18)),
                    Text('Soyisim: ${userAddress!['surname']}', style: TextStyle(fontSize: 18)),
                  ],
                ),
              SizedBox(height: 20),
              Text('Kargo Ücreti: ₺${shippingCost.toStringAsFixed(2)}', style: TextStyle(fontSize: 20)),
              SizedBox(height: 10),
              Text('Genel Toplam: ₺${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: userAddress != null ? () async {
                  await _completePurchase(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                    (Route<dynamic> route) => false,
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 27, 10, 95),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  'Tamamla',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
