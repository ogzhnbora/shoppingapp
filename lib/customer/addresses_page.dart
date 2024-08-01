import 'package:flutter/material.dart';
import 'package:finalproject/customer/firebase_service.dart';
import 'add_address_page.dart';

class AddressesPage extends StatefulWidget {
  @override
  _AddressesPageState createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>>? addresses;

  @override
  void initState() {
    super.initState();
    _loadUserAddresses();
  }

  Future<void> _loadUserAddresses() async {
    List<Map<String, dynamic>>? userAddresses = await _firebaseService.getUserAddresses();
    setState(() {
      addresses = userAddresses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adreslerim'),
      ),
      body: addresses == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: addresses!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(addresses![index]['title']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sokak/Cadde: ${addresses![index]['street']}'),
                      Text('Apartman No: ${addresses![index]['buildingNo']}'),
                      Text('Daire No: ${addresses![index]['apartmentNo']}'),
                      Text('Mahalle: ${addresses![index]['neighborhood']}'),
                      Text('İl: ${addresses![index]['city']}'),
                      Text('İlçe: ${addresses![index]['district']}'),
                      Text('Telefon: ${addresses![index]['phone']}'),
                      Text('İsim: ${addresses![index]['name']}'),
                      Text('Soyisim: ${addresses![index]['surname']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          final updatedAddress = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddAddressPage(address: addresses![index], index: index)),
                          );
                          if (updatedAddress != null) {
                            _loadUserAddresses();
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await _firebaseService.deleteUserAddress(index);
                          _loadUserAddresses();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newAddress = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAddressPage()),
          );
          if (newAddress != null) {
            _loadUserAddresses();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
