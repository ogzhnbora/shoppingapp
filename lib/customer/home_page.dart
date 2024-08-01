import 'package:flutter/material.dart';
import 'package:finalproject/customer/nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalproject/customer/product_page.dart';
import 'package:finalproject/seller/product.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finalproject/customer/app_drawer.dart'; // Drawer dosyasını import edin

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  String? _selectedGender;

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

  void _filterByGender(String gender) {
    setState(() {
      _selectedGender = gender;
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
        automaticallyImplyLeading: true, // Üç çizgi ikonunu göstermek için
        elevation: 0,
        centerTitle: true,
      ),
      drawer: AppDrawer(
        onSelectGender: _filterByGender,
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
              stream: _selectedGender == null
                  ? FirebaseFirestore.instance.collection('products').snapshots()
                  : FirebaseFirestore.instance.collection('products').where('gender', isEqualTo: _selectedGender).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Veri alınamadı: ${snapshot.error}'));
                }

                List<DocumentSnapshot> products = snapshot.data!.docs;

                // Filtreleme işlemi burada yapılacak
                List<DocumentSnapshot> filteredProducts = _searchText.isEmpty
                    ? products
                    : products.where((product) {
                        String name = (product.data() as Map<String, dynamic>)['name'].toLowerCase();
                        return name.contains(_searchText);
                      }).toList();

                return GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot snapshot = filteredProducts[index];
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
                                    style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 33, 31, 91), fontWeight: FontWeight.bold),
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
          // This is where you would handle changing tabs, potentially updating state
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
