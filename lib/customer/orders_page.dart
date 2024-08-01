import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrdersPage extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .get();

      List<Map<String, dynamic>> orders = ordersSnapshot.docs.map((doc) {
        return {
          'orderId': doc.id,
          'data': doc.data() as Map<String, dynamic>,
        };
      }).toList();

      return orders;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Siparişlerim'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Henüz siparişiniz yok.'));
          } else {
            List<Map<String, dynamic>> orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                var order = orders[index];
                var orderData = order['data'];
                var quantity = orderData['quantity'];
                var price = orderData['price'];
                var totalAmount = price * quantity;

                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text('Sipariş Numarası: ${order['orderId']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Durum: ${orderData['status'] == 'shipped' ? 'Kargoya verildi' : 'Sipariş hazırlanıyor'}'),
                        Text('Tutar: ₺${totalAmount.toStringAsFixed(2)}'),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailsPage(orders: [order]),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class OrderDetailsPage extends StatelessWidget {
  final List<Map<String, dynamic>> orders;

  const OrderDetailsPage({required this.orders, Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _fetchProductDetails(String productId) async {
    DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get();

    if (productSnapshot.exists) {
      return productSnapshot.data() as Map<String, dynamic>;
    } else {
      throw Exception('Product not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    var orderData = orders.first['data'];
    DateTime orderDate = (orderData['orderDate'] as Timestamp).toDate();
    Map<String, dynamic> userAddress = orderData['userAddress'];
    var productId = orderData['productId'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Sipariş Detayları'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchProductDetails(productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Ürün bilgileri alınamadı.'));
          } else {
            var productData = snapshot.data!;
            var productImage = productData['imageUrl'];
            var productName = productData['name'];
            var quantity = orderData['quantity'];
            var price = orderData['price'];
            var totalAmount = price * quantity;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sipariş Numarası: ${orders.first['orderId']}', style: TextStyle(fontSize: 18,)),
                    SizedBox(height: 10),
                    Text('Durum: ${orderData['status'] == 'shipped' ? 'Kargoya verildi' : 'Sipariş hazırlanıyor'}', style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('Sipariş Tarihi: ${orderDate.toLocal().toString().split(' ')[0]}', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 20),
                    Text('Ürünler:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(
                      width: double.infinity,
                      child: Image.network(productImage, fit: BoxFit.cover),
                    ),
                    SizedBox(height: 20),
                     Text('Ürün Adı: $productName', style: TextStyle(fontSize: 20)),
                    Text('Adet: $quantity', style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold)),
                    Text('Fiyat: ₺${price.toStringAsFixed(2)}', style: TextStyle(fontSize: 18,)),
                    SizedBox(height: 20),
                     Text('Müşteri Adresi ve İletişim Bilgileri:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('${userAddress['name']} ${userAddress['surname']}', style: TextStyle(fontSize: 16)),
                    Text('${userAddress['phone']}', style: TextStyle(fontSize: 16)),
                    Text('${userAddress['street']}, No: ${userAddress['buildingNo']}, Daire: ${userAddress['apartmentNo']}', style: TextStyle(fontSize: 16)),
                    Text('${userAddress['neighborhood']}, ${userAddress['district']}', style: TextStyle(fontSize: 16)),
                    Text('${userAddress['city']}', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 20),
                    Text('Toplam Ödenen Tutar: ₺${totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,)),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
