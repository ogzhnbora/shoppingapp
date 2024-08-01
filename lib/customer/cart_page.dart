import 'package:flutter/material.dart';
import 'package:finalproject/customer/cart_model.dart';
import 'package:provider/provider.dart';
import 'package:finalproject/customer/nav_bar.dart';
import 'purchase_page.dart';
import 'product_page.dart'; // ProductPage import edildi
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finalproject/customer/login_page.dart'; // LoginPage import edildi

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);
    double shippingCost = 20.0;
    double total = cart.totalPrice + shippingCost;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Sepetim'),
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? Center(
                    child: Text('Henüz sepetinize ürün eklemediniz.'),
                  )
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      var product = cart.items[index];
                      var quantity = cart.getQuantity(product);

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 4,
                        child: ListTile(
                          leading: Image.network(
                            product.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                          title: Text(
                            product.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '₺${product.price.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          trailing: quantity > 0
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: () {
                                        cart.update(product, quantity - 1);
                                      },
                                    ),
                                    Text(
                                      '$quantity',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () {
                                        cart.update(product, quantity + 1);
                                      },
                                    ),
                                  ],
                                )
                              : IconButton(
                                  icon: Icon(Icons.delete, color: Color.fromARGB(255, 105, 102, 101)),
                                  onPressed: () {
                                    cart.remove(product);
                                  },
                                ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductPage(product: product),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
          if (cart.items.isNotEmpty)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, -3),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.black,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Toplam: ₺${total.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (user == null) {
                          _showLoginAlert(context);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PurchasePage()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 143, 24, 15),
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        'Satın Al',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, -3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 10),
                  Text(
                    'Ürünlerin Toplamı: ₺${cart.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Kargo Ücreti: ₺${shippingCost.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Genel Toplam: ₺${total.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: Duration(milliseconds: 300),
          ),
        ],
      ),
      bottomNavigationBar: MyBottomNavBar(
        selectedIndex: 1,
        onTabChange: (index) {
          // Navigator ve tab güncellemeleri burada
        },
      ),
    );
  }

  void _showLoginAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Giriş Yapınız'),
          content: Text('Satın almak için lütfen giriş yapınız.'),
          actions: [
            TextButton(
              child: Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
