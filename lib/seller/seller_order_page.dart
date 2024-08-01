import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_detail_page.dart'; // OrderDetailsPage import edin
import 'package:intl/intl.dart'; // Tarih formatlama için

class SellerOrderPage extends StatefulWidget {
  final String sellerId;
  final ValueChanged<int> onOrderCountUpdated; // Sipariş sayısını güncelleme fonksiyonu

  const SellerOrderPage({required this.sellerId, required this.onOrderCountUpdated, Key? key}) : super(key: key);

  @override
  _SellerOrderPageState createState() => _SellerOrderPageState();
}

class _SellerOrderPageState extends State<SellerOrderPage> {
  List<Map<String, dynamic>>? orders;
  int orderCount = 0;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('sellerId', isEqualTo: widget.sellerId)
        .orderBy('orderDate') // Siparişleri tarihe göre sıralayın
        .get();

    Map<String, List<Map<String, dynamic>>> groupedOrders = {};

    for (var doc in snapshot.docs) {
      Map<String, dynamic> orderData = doc.data() as Map<String, dynamic>;
      String productId = orderData['productId'];
      String userId = orderData['userId'];
      Timestamp orderDate = orderData['orderDate'];

      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (productSnapshot.exists) {
        Map<String, dynamic> productData = productSnapshot.data() as Map<String, dynamic>;
        productData['productId'] = productSnapshot.id;
        orderData['orderId'] = doc.id;

        // Her siparişi müşteri ve tarih kombinasyonuna göre gruplandırın
        String groupKey = '$userId-${orderDate.toDate().toIso8601String()}';
        if (!groupedOrders.containsKey(groupKey)) {
          groupedOrders[groupKey] = [];
        }
        groupedOrders[groupKey]!.add({
          'order': orderData,
          'product': productData,
        });
      } else {
        print('Product not found for ID: $productId');
      }
    }

    if (mounted) {
      setState(() {
        orders = groupedOrders.entries.map((entry) => {'groupKey': entry.key, 'orders': entry.value}).toList();
        orderCount = groupedOrders.values
            .expand((orderList) => orderList)
            .where((order) => order['order']['status'] != 'shipped')
            .length;
      });

      widget.onOrderCountUpdated(orderCount); // Sipariş sayısını geri bildirin
    }
  }

  String formatDateTime(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Siparişlerim'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders, // Refresh yapıldığında çağrılacak fonksiyon
        child: orders == null
            ? Center(child: CircularProgressIndicator())
            : orders!.isEmpty
                ? ListView(
                    children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height / 3), // Ekranın ortasına yerleştir
                              Text('Siparişiniz bulunmamaktadır.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: orders!.length,
                    itemBuilder: (context, index) {
                      var userOrders = orders![index]['orders'] as List<Map<String, dynamic>>;
                      var orderDateTime = formatDateTime(userOrders.first['order']['orderDate']);
                      var groupedProducts = _groupProducts(userOrders);
                      var totalProducts = groupedProducts.values.fold<int>(0, (sum, item) => sum + item['quantity'] as int);

                      return Card(
                        margin: EdgeInsets.all(10),
                        child: ExpansionTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Sipariş Tarihi: ${orderDateTime.split(' ')[0]}'),
                                  Text('Sipariş Saati: ${orderDateTime.split(' ')[1]}'),
                                ],
                              ),
                              if (userOrders.first['order']['status'] != 'shipped')
                                Icon(Icons.local_shipping, color: Colors.red),
                            ],
                          ),
                          subtitle: Text('Toplam Ürün: $totalProducts'),
                          children: [
                            ListTile(
                              title: Text('Tüm Ürünleri Görüntüle'),
                              trailing: Icon(Icons.arrow_forward),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderDetailsPage(orders: userOrders),
                                  ),
                                ).then((_) {
                                  // Sipariş durumunu kontrol edip sipariş sayısını güncelle
                                  _loadOrders();
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
