import 'package:flutter/material.dart';
import 'package:finalproject/customer/firebase_service.dart';

class AddAddressPage extends StatefulWidget {
  final Map<String, dynamic>? address;
  final int? index;

  AddAddressPage({this.address, this.index});

  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _buildingNoController = TextEditingController();
  final TextEditingController _apartmentNoController = TextEditingController();
  final TextEditingController _neighborhoodController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _titleController.text = widget.address!['title'] ?? '';
      _streetController.text = widget.address!['street'] ?? '';
      _buildingNoController.text = widget.address!['buildingNo'] ?? '';
      _apartmentNoController.text = widget.address!['apartmentNo'] ?? '';
      _neighborhoodController.text = widget.address!['neighborhood'] ?? '';
      _cityController.text = widget.address!['city'] ?? '';
      _districtController.text = widget.address!['district'] ?? '';
      _phoneController.text = widget.address!['phone'] ?? '';
      _nameController.text = widget.address!['name'] ?? '';
      _surnameController.text = widget.address!['surname'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adres Ekle / Güncelle'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Adres Başlığı',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
               TextField(
                controller: _neighborhoodController,
                decoration: InputDecoration(
                  labelText: 'Mahalle',
                  border: OutlineInputBorder(),
                ),
              ),
               SizedBox(height: 10),

              TextField(
                controller: _streetController,
                decoration: InputDecoration(
                  labelText: 'Sokak/Cadde',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _buildingNoController,
                decoration: InputDecoration(
                  labelText: 'Apartman No',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _apartmentNoController,
                decoration: InputDecoration(
                  labelText: 'Daire No',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
                           TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'İl',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _districtController,
                decoration: InputDecoration(
                  labelText: 'İlçe',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Telefon Numarası',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'İsim',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _surnameController,
                decoration: InputDecoration(
                  labelText: 'Soyisim',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String title = _titleController.text;
                  String street = _streetController.text;
                  String buildingNo = _buildingNoController.text;
                  String apartmentNo = _apartmentNoController.text;
                  String neighborhood = _neighborhoodController.text;
                  String city = _cityController.text;
                  String district = _districtController.text;
                  String phone = _phoneController.text;
                  String name = _nameController.text;
                  String surname = _surnameController.text;

                  if (title.isNotEmpty && street.isNotEmpty && buildingNo.isNotEmpty && 
                      apartmentNo.isNotEmpty && neighborhood.isNotEmpty && city.isNotEmpty &&
                      district.isNotEmpty && phone.isNotEmpty && name.isNotEmpty && surname.isNotEmpty) {
                    Map<String, dynamic> address = {
                      'title': title,
                      'street': street,
                      'buildingNo': buildingNo,
                      'apartmentNo': apartmentNo,
                      'neighborhood': neighborhood,
                      'city': city,
                      'district': district,
                      'phone': phone,
                      'name': name,
                      'surname': surname,
                    };

                    if (widget.index == null) {
                      await _firebaseService.addUserAddress(address);
                    } else {
                      await _firebaseService.updateUserAddress(widget.index!, address);
                    }

                    Navigator.pop(context, address);
                  }
                },
                child: Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
