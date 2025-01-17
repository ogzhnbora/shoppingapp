import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:math';

class ProductFormPage extends StatefulWidget {
  @override
  _ProductFormPageState createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _imageUrl = '';
  double _price = 0.0;
  String _gender = 'Unisex';
  String _category = 'Tişört'; // Varsayılan kategori
  List<String> _selectedSizes = [];
  String _fit = 'Regular Fit';
  String? userID;
  File? _imageFile;

  final List<String> _availableSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL'];
  final List<String> _categories = ['Tişört', 'Sweatshirt', 'Pantolon', 'Ceket', 'Elbise', 'Şort', 'Etek', 'Gömlek', 'Eşofman','Kazak','Mont','Bluz','Büstiyer'];
  Map<String, int> _sizeStocks = {};

  @override
  void initState() {
    super.initState();
    fetchUserID().then((id) {
      setState(() {
        userID = id;
      });
    });
  }

  Future<String> fetchUserID() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      return userData['userID'];
    } else {
      throw Exception('User not found');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;
    try {
      final storageRef = FirebaseStorage.instance.ref().child('product_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(_imageFile!);
      final snapshot = await uploadTask;
      _imageUrl = await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Image upload failed: $e');
    }
  }

  String generateRandomID(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ));
  }

  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate() && userID != null) {
      _formKey.currentState!.save();
      await _uploadImage();
      String productId = generateRandomID(10);
      await FirebaseFirestore.instance.collection('products').doc(productId).set({
        'productId': productId,
        'name': _name,
        'imageUrl': _imageUrl,
        'price': _price,
        'gender': _gender,
        'category': _category, // Yeni kategori alanı
        'sizes': _selectedSizes,
        'fit': _fit,
        'sizeStocks': _sizeStocks,
        'userID': userID,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ürün Ekle'),
      ),
      body: userID == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Ürün Adı'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Lütfen ürün adını girin';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _name = value!;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Fiyat'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Lütfen fiyatı girin';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _price = double.parse(value!);
                      },
                    ),
                    SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      items: ['Erkek', 'Kadın', 'Unisex'].map((String gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      decoration: InputDecoration(labelText: 'Cinsiyet'),
                      onChanged: (newValue) {
                        setState(() {
                          _gender = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: _category,
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      decoration: InputDecoration(labelText: 'Kategori'),
                      onChanged: (newValue) {
                        setState(() {
                          _category = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 15),
                    Text('Beden Seçimi', style: TextStyle(fontSize: 16)),
                    Wrap(
                      spacing: 10,
                      children: _availableSizes.map((size) {
                        bool isSelected = _selectedSizes.contains(size);
                        return FilterChip(
                          label: Text(size),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedSizes.add(size);
                              } else {
                                _selectedSizes.remove(size);
                                _sizeStocks.remove(size);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 15),
                    if (_selectedSizes.isNotEmpty)
                      Column(
                        children: _selectedSizes.map((size) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            elevation: 2.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    size,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      initialValue: _sizeStocks[size]?.toString() ?? '0',
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _sizeStocks[size] = int.tryParse(value) ?? 0;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    SizedBox(height: 20),
                    _imageFile == null
                        ? Text('Henüz bir resim seçilmedi.')
                        : Image.file(_imageFile!),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Resim Seç'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addProduct,
                      child: Text('Ürünü Ekle'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
