import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalproject/customer/firebase_service.dart';  // FirebaseService import edildi

class OrderDetailsPage extends StatefulWidget {
  final List<Map<String, dynamic>> orders;

  const OrderDetailsPage({required this.orders, Key? key}) : super(key: key);

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late String orderStatus;
  DateTime? shippedAt;

  @override
  void initState() {
    super.initState();
    if (widget.orders.isNotEmpty) {
      orderStatus = widget.orders.first['order']['status'];
      if (widget.orders.first['order']['shippedAt'] != null) {
        shippedAt = (widget.orders.first['order']['shippedAt'] as Timestamp).toDate();
      }
    }
  }

  Future<void> _markAsShipped(BuildContext context) async {
    final FirebaseService _firebaseService = FirebaseService();
    for (var order in widget.orders) {
      await _firebaseService.updateOrderStatus(order['order']['orderId'], 'shipped');
    }

    setState(() {
      orderStatus = 'shipped';
      shippedAt = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tüm siparişler kargoya verildi.')),
    );
  }

  Map<String, Map<String, dynamic>> _groupProducts(List<Map<String, dynamic>> orders) {
    Map<String, Map<String, dynamic>> groupedProducts = {};

    for (var order in orders) {
      var productId = order['product']['productId'];
      if (!groupedProducts.containsKey(productId)) {
        groupedProducts[productId] = {
          'product': order['product'],
          'quantity': order['order']['quantity'],
        };
      } else {
        groupedProducts[productId]!['quantity'] += order['order']['quantity'];
      }
    }

    return groupedProducts;
  }

  @override
  Widget build(BuildContext context) {
    var groupedProducts = _groupProducts(widget.orders);

    return Scaffold(
      appBar: AppBar(
        title: Text('Sipariş Detayları'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...groupedProducts.entries.map((entry) {
              var product = entry.value['product'];
              var quantity = entry.value['quantity'];
              DateTime orderDate = (widget.orders.first['order']['orderDate'] as Timestamp).toDate();
              DateTime shippingDeadline = orderDate.add(Duration(days: 1));
              Map<String, dynamic> userAddress = widget.orders.first['order']['userAddress'];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ürün Adı: ${product['name']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Image.network(product['imageUrl']),
                  SizedBox(height: 10),
                  Text('Fiyat: ₺${product['price'].toStringAsFixed(2)}', style: TextStyle(fontSize: 18, color: Colors.green)),
                  SizedBox(height: 10),
                  Text('Adet: $quantity', style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('Sipariş Tarihi: ${orderDate.toLocal().toString().split(' ')[0]} ${orderDate.toLocal().toString().split(' ')[1].split('.')[0]}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text('Kargoya Vermek için Son Tarih: ${shippingDeadline.toLocal().toString().split(' ')[0]} ${shippingDeadline.toLocal().toString().split(' ')[1].split('.')[0]}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  if (entry == groupedProducts.entries.first)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Müşteri Adresi:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('${userAddress['name']} ${userAddress['surname']}', style: TextStyle(fontSize: 16)),
                        Text('${userAddress['phone']}', style: TextStyle(fontSize: 16)),
                        Text('${userAddress['street']}, No: ${userAddress['buildingNo']}, Daire: ${userAddress['apartmentNo']}', style: TextStyle(fontSize: 16)),
                        Text('${userAddress['neighborhood']}, ${userAddress['district']}', style: TextStyle(fontSize: 16)),
                        Text('${userAddress['city']}', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 20),
                      ],
                    ),
                ],
              );
            }).toList(),
            Center(
              child: Column(
                children: [
                  if (orderStatus == 'shipped' && shippedAt != null)
                    Column(
                      children: [
                        Text(
                          'Kargoda',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Kargoya Verme Tarihi: ${shippedAt!.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Kargoya Verme Saati: ${shippedAt!.toLocal().toString().split(' ')[1].split('.')[0]}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    )
                  else
                    ElevatedButton(
                      onPressed: () => _markAsShipped(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text('Kargoya Verdim', style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
