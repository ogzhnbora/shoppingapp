import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellerHomePage extends StatefulWidget {
  final String sellerId;

  const SellerHomePage({required this.sellerId, Key? key}) : super(key: key);

  @override
  _SellerHomePageState createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  int todayOrderCount = 0;
  double todayRevenue = 0.0;
  double endOfDayPayout = 0.0;
  int awaitingShipmentCount = 0;
  int shippedOrderCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSellerData();
  }

  Future<void> _loadSellerData() async {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    QuerySnapshot todayOrdersSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('sellerId', isEqualTo: widget.sellerId)
        .where('orderDate', isGreaterThanOrEqualTo: startOfDay)
        .get();

    double tempRevenue = 0.0;
    int tempAwaitingShipment = 0;
    int tempShipped = 0;

    for (var doc in todayOrdersSnapshot.docs) {
      Map<String, dynamic> orderData = doc.data() as Map<String, dynamic>;
      tempRevenue += (orderData['price'] ?? 0.0) as double;

      if (orderData['status'] == 'kargoya verilmesi için bekleniyor') {
        tempAwaitingShipment++;
      } else if (orderData['status'] == 'shipped') {
        tempShipped++;
      }
    }

    setState(() {
      todayOrderCount = todayOrdersSnapshot.docs.length;
      todayRevenue = tempRevenue;
      endOfDayPayout = tempRevenue * 0.80; // %20 komisyon
      awaitingShipmentCount = tempAwaitingShipment;
      shippedOrderCount = tempShipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ana Sayfa'),
                automaticallyImplyLeading: false,

      ),
      body: RefreshIndicator(
        onRefresh: _loadSellerData, // Refresh yapıldığında çağrılacak fonksiyon
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildInfoCard('Bugünkü Sipariş Sayısı', todayOrderCount.toString()),
              _buildInfoCard('Bugünkü Ciro', '₺${todayRevenue.toStringAsFixed(2)}'),
              _buildInfoCard('Gün Sonunda Bankaya Aktarılacak Miktar ', '₺${endOfDayPayout.toStringAsFixed(2)}'),
              _buildInfoCard('Kargo Bekleyen Sipariş Sayısı', awaitingShipmentCount.toString(), awaitingShipmentCount > 0 ? Colors.red : Colors.black),
              _buildInfoCard('Kargolanan Sipariş Sayısı', shippedOrderCount.toString()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, [Color? valueColor]) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(value, style: TextStyle(fontSize: 16, color: valueColor ?? Colors.black)),
      ),
    );
  }
}
