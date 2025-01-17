import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  final Function(String, String?) onSelectCategory; // Seçilen kategori (cinsiyet ve alt kategori)

  AppDrawer({required this.onSelectCategory});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _showCategories = false; // Alt kategorilerin görünüm durumu
  String? _selectedGender; // Seçilen cinsiyet

  // Kadın için kategoriler
  final List<String> femaleCategories = [
    'Tüm Ürünler',
    'Tişört',
    'Sweatshirt',
    'Pantolon',
    'Ceket',
    'Elbise',
    'Şort',
    'Etek',
    'Gömlek',
    'Eşofman',
    'Kazak',
    'Mont',
    'Bluz',
    'Büstiyer'
  ];

  // Erkek için kategoriler
  final List<String> maleCategories = [
    'Tüm Ürünler',
    'Tişört',
    'Sweatshirt',
    'Pantolon',
    'Ceket',
    'Şort',
    'Gömlek',
    'Eşofman',
    'Kazak',
    'Mont',
  ];

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
      _showCategories = true; // Alt kategorileri göster
    });
  }

  void _goBackToGenderSelection() {
    setState(() {
      _showCategories = false; // Geri dönerek cinsiyet seçim ekranını göster
      _selectedGender = null;
    });
  }

  List<String> _getCategoriesForGender() {
    if (_selectedGender == 'Kadın') {
      return femaleCategories;
    } else if (_selectedGender == 'Erkek') {
      return maleCategories;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header with Back Button
          Container(
            height: 100,
            width: double.infinity,
            color: Color.fromARGB(255, 197, 130, 137),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _showCategories ? _goBackToGenderSelection : null,
                ),
                Text(
                  'Kategoriler',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _showCategories
                ? _buildCategoryView() // Alt kategorileri göster
                : _buildGenderSelectionView(), // Kadın/Erkek seçim ekranı
          ),
        ],
      ),
    );
  }

  // Kadın/Erkek Seçim Ekranı
  Widget _buildGenderSelectionView() {
    return ListView(
      children: [
        ListTile(
          leading: Icon(Icons.female, color: Colors.pink),
          title: Text('Kadın'),
          onTap: () => _selectGender('Kadın'),
        ),
        ListTile(
          leading: Icon(Icons.male, color: Colors.blue),
          title: Text('Erkek'),
          onTap: () => _selectGender('Erkek'),
        ),
      ],
    );
  }

  // Alt Kategoriler Görünümü
  Widget _buildCategoryView() {
    final categories = _getCategoriesForGender(); // Seçilen cinsiyete uygun kategoriler
    return ListView(
      children: categories.map((category) {
        return ListTile(
          title: Text(category),
          onTap: () {
            Navigator.pop(context);
            widget.onSelectCategory(_selectedGender!, category == 'Tüm Ürünler' ? null : category);
          },
        );
      }).toList(),
    );
  }
}
