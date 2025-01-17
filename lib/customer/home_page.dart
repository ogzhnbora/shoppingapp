import 'package:flutter/material.dart';
import 'package:finalproject/customer/app_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalproject/customer/product_page.dart';
import 'package:finalproject/seller/product.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finalproject/customer/nav_bar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  String? _selectedGender;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts(String gender, String? category) {
    setState(() {
      _selectedGender = gender;
      _selectedCategory = category; // Eğer "Tüm Ürünler" seçilmişse, null olur
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ArtisanModa',
          style: GoogleFonts.lobster(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color.fromARGB(255, 197, 130, 137),
        automaticallyImplyLeading: true,
        elevation: 0,
        centerTitle: true,
      ),
      drawer: AppDrawer(
        onSelectCategory: (gender, category) => _filterProducts(gender, category),
      ),
      body: Column(
        children: [
          SearchBar(
            searchController: _searchController,
            onChanged: (value) {
              setState(() {
                _searchText = value.toLowerCase();
              });
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Ürün bulunamadı.'));
                }

                List<DocumentSnapshot> products = snapshot.data!.docs;

                // Seçilen kategoriye ve cinsiyete göre filtreleme
                if (_selectedGender != null) {
                  if (_selectedCategory != null) {
                    // Belirli bir kategoriye göre filtreleme
                    products = products.where((product) {
                      final data = product.data() as Map<String, dynamic>;
                      return (data['gender'] == _selectedGender || data['gender'] == 'Unisex') &&
                          data['category'] == _selectedCategory;
                    }).toList();
                  } else {
                    // Tüm ürünler (sadece cinsiyete ve "Unisex" ürünlere göre filtreleme)
                    products = products.where((product) {
                      final data = product.data() as Map<String, dynamic>;
                      return data['gender'] == _selectedGender || data['gender'] == 'Unisex';
                    }).toList();
                  }
                }

                // Arama metnine göre filtreleme
                if (_searchText.isNotEmpty) {
                  products = products.where((product) {
                    final data = product.data() as Map<String, dynamic>;
                    return (data['name'] ?? '').toLowerCase().contains(_searchText);
                  }).toList();
                }

                return GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot snapshot = products[index];
                    Product product = Product.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id);

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductPage(product: product),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: product.imageUrl.isNotEmpty
                                  ? Image.network(
                                      product.imageUrl,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(Icons.image_not_supported, size: 60),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    '₺${product.price}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 33, 31, 91),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyBottomNavBar(
        selectedIndex: 0,
        onTabChange: (index) {
          // Tab değişimi için ek işlemler
        },
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onChanged;

  const SearchBar({
    required this.searchController,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        controller: searchController,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Ürün ara...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
