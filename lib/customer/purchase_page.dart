import 'package:flutter/material.dart';
import 'package:finalproject/customer/cart_model.dart';
import 'package:finalproject/customer/firebase_service.dart';
import 'package:provider/provider.dart';
import 'add_address_page.dart';
import 'addresses_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

    // Ürün bilgilerini ve kullanıcı adresini topla
    List<Map<String, dynamic>> products = cart.items.map((item) {
      return {
        'productId': item.id,
        'quantity': cart.getQuantity(item),
        'price': item.price,
        'isReviewed': false,
      };
    }).toList();

    // Siparişi Firebase'e ekle
    await _firebaseService.addOrder(
      userId: user.uid,
      products: products,
      userAddress: userAddress!, // Seçilen adres
      totalPrice: cart.totalPrice + 20.0, // Toplam fiyat + kargo
      status: 'kargoya verilmesi için bekleniyor',
    );

    cart.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Satın alma işlemi tamamlandı.'),
        backgroundColor: Color.fromARGB(255, 197, 130, 137),
        duration: Duration(seconds: 2),
      ),
    );

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
                    leading: product.imageUrl.isNotEmpty
                        ? Image.network(product.imageUrl)
                        : Icon(Icons.image_not_supported),
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
                          child: Text(address['title'] ?? 'Bilinmeyen Başlık'),
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
                    ..._buildAddressDetails(userAddress!),
                  ],
                ),
              SizedBox(height: 20),
              Text('Kargo Ücreti: ₺${shippingCost.toStringAsFixed(2)}', style: TextStyle(fontSize: 20)),
              SizedBox(height: 10),
              Text('Genel Toplam: ₺${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: userAddress != null
                    ? () async {
                        await _completePurchase(context);
                      }
                    : null,
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

  List<Widget> _buildAddressDetails(Map<String, dynamic> address) {
    return [
      Text('Adres Başlığı: ${address['title']}', style: TextStyle(fontSize: 18)),
      Text('Sokak/Cadde: ${address['street']}', style: TextStyle(fontSize: 18)),
      Text('Apartman No: ${address['buildingNo']}', style: TextStyle(fontSize: 18)),
      Text('Daire No: ${address['apartmentNo']}', style: TextStyle(fontSize: 18)),
      Text('Mahalle: ${address['neighborhood']}', style: TextStyle(fontSize: 18)),
      Text('İl: ${address['city']}', style: TextStyle(fontSize: 18)),
      Text('İlçe: ${address['district']}', style: TextStyle(fontSize: 18)),
      Text('Telefon: ${address['phone']}', style: TextStyle(fontSize: 18)),
      Text('İsim: ${address['name']}', style: TextStyle(fontSize: 18)),
      Text('Soyisim: ${address['surname']}', style: TextStyle(fontSize: 18)),
    ];
  }
}
