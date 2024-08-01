import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'product.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProductEditPage extends StatefulWidget {
  final Product product;

  ProductEditPage({required this.product});

  @override
  _ProductEditPageState createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late double _price;
  late String _gender;
  late String _fit;
  List<String> _selectedSizes = [];
  File? _imageFile;
  late String _imageUrl;

  final List<String> genders = ['Erkek', 'Kadın', 'Unisex'];
  final List<String> fits = ['Regular Fit', 'Oversize Fit', 'Slim Fit', 'Relaxed Fit'];
  final List<String> sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL'];

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _price = widget.product.price;
    _gender = widget.product.gender;
    _fit = widget.product.fit;
    _selectedSizes = List<String>.from(widget.product.sizes);
    _imageUrl = widget.product.imageUrl;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Eğer yeni bir resim seçildiyse, Firebase Storage'a yükleyin ve URL'yi güncelleyin
      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('product_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = storageRef.putFile(_imageFile!);
        final snapshot = await uploadTask;
        _imageUrl = await snapshot.ref.getDownloadURL();
      }

      // Firestore'da ürünü güncelle
      await FirebaseFirestore.instance.collection('products').doc(widget.product.id).update({
        'name': _name,
        'price': _price,
        'imageUrl': _imageUrl,
        'gender': _gender,
        'fit': _fit,
        'sizes': _selectedSizes,
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ürünü Düzenle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView( // Tek kaydırılabilir form
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: _name,
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
                SizedBox(height: 15,),
                TextFormField(
                  initialValue: _price.toString(),
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
                SizedBox(height: 15,),
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: InputDecoration(labelText: 'Cinsiyet'),
                  items: genders.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _gender = newValue!;
                    });
                  },
                  onSaved: (value) {
                    _gender = value!;
                  },
                ),
                SizedBox(height: 15,),
                DropdownButtonFormField<String>(
                  value: _fit,
                  decoration: InputDecoration(labelText: 'Kalıp'),
                  items: fits.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _fit = newValue!;
                    });
                  },
                  onSaved: (value) {
                    _fit = value!;
                  },
                ),
                SizedBox(height: 15,),
                Text('Beden Seçin:', style: TextStyle(fontSize: 16)),
                Wrap(
                  spacing: 5,
                  children: sizes.map((size) {
                    return ChoiceChip(
                      label: Text(size),
                      selected: _selectedSizes.contains(size),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSizes.add(size);
                          } else {
                            _selectedSizes.remove(size);
                          }
                        });
                      },
                      selectedColor: Colors.blue,
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                _imageFile == null
                    ? _imageUrl.isNotEmpty
                        ? Image.network(_imageUrl, height: 200)
                        : Icon(Icons.image, size: 200)
                    : Image.file(_imageFile!, height: 200),
                TextButton.icon(
                  icon: Icon(Icons.image),
                  label: Text('Resim Seç'),
                  onPressed: _pickImage,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: Text('Değişiklikleri Kaydet'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
