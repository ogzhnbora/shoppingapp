import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Address-related operations
  Future<List<Map<String, dynamic>>?> getUserAddresses() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      var data = userDoc.data() as Map<String, dynamic>?;
      if (userDoc.exists && data != null && data.containsKey('addresses')) {
        return List<Map<String, dynamic>>.from(data['addresses']);
      }
    }
    return [];
  }

  Future<void> addUserAddress(Map<String, dynamic> address) async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      List<Map<String, dynamic>> addresses = userDoc.exists && userDoc.data() != null && (userDoc.data() as Map<String, dynamic>).containsKey('addresses') 
        ? List<Map<String, dynamic>>.from((userDoc.data() as Map<String, dynamic>)['addresses']) 
        : [];
      addresses.add(address);
      await _firestore.collection('users').doc(user.uid).set({'addresses': addresses}, SetOptions(merge: true));
    }
  }

  Future<void> updateUserAddress(int index, Map<String, dynamic> address) async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      List<Map<String, dynamic>> addresses = userDoc.exists && userDoc.data() != null && (userDoc.data() as Map<String, dynamic>).containsKey('addresses') 
        ? List<Map<String, dynamic>>.from((userDoc.data() as Map<String, dynamic>)['addresses']) 
        : [];
      if (index >= 0 && index < addresses.length) {
        addresses[index] = address;
        await _firestore.collection('users').doc(user.uid).set({'addresses': addresses}, SetOptions(merge: true));
      }
    }
  }

  Future<void> deleteUserAddress(int index) async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      List<Map<String, dynamic>> addresses = userDoc.exists && userDoc.data() != null && (userDoc.data() as Map<String, dynamic>).containsKey('addresses') 
        ? List<Map<String, dynamic>>.from((userDoc.data() as Map<String, dynamic>)['addresses']) 
        : [];
      if (index >= 0 && index < addresses.length) {
        addresses.removeAt(index);
        await _firestore.collection('users').doc(user.uid).set({'addresses': addresses}, SetOptions(merge: true));
      }
    }
  }
Future<void> addOrder({
  required String userId,
  required List<Map<String, dynamic>> products,
  required Map<String, dynamic> userAddress,
  required double totalPrice,
  required String status,
}) async {
  final orderId = FirebaseFirestore.instance.collection('orders').doc().id;

  await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
    'orderId': orderId,
    'userId': userId,
    'products': products, // Ürün listesi
    'orderDate': Timestamp.now(), // Sipariş tarihi
    'status': status, // Sipariş durumu
    'userAddress': userAddress, // Kullanıcı adresi
    'totalPrice': totalPrice, // Toplam fiyat
  });
}

  Future<void> updateOrderStatus(String orderId, String status) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': status,
      'shippedAt': status == 'shipped' ? Timestamp.now() : null,
    });
  }

  // Product-related operations
  Future<void> addProduct(Map<String, dynamic> productData, String productId) async {
    await _firestore.collection('products').doc(productId).set(productData);
  }

  Future<void> updateStock(String productId, int quantity) async {
    DocumentReference productRef = _firestore.collection('products').doc(productId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(productRef);
      if (!snapshot.exists) {
        throw Exception("Product does not exist");
      }

      int currentStock = snapshot.get('stock');
      if (currentStock < quantity) {
        throw Exception("Insufficient stock available");
      }

      transaction.update(productRef, {'stock': currentStock - quantity});
    });
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    QuerySnapshot snapshot = await _firestore.collection('products').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<void> updateProductSearchKeys() async {
    CollectionReference products = _firestore.collection('products');
    QuerySnapshot snapshot = await products.get();

    for (var doc in snapshot.docs) {
      String name = doc['name'].toLowerCase();
      List<String> searchKeys = generateSearchKeys(name);

      await products.doc(doc.id).update({
        'searchKeys': searchKeys,
      });
    }
  }

  List<String> generateSearchKeys(String name) {
    List<String> searchKeys = [];
    List<String> words = name.split(' ');

    for (int i = 0; i < words.length; i++) {
      String key = "";
      for (int j = i; j < words.length; j++) {
        key = key.isEmpty ? words[j] : "$key ${words[j]}";
        searchKeys.add(key);
      }
    }
    return searchKeys;
  }
   Future<void> addReviewToUser(String productId, double rating, String comment) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final userRef = _firestore.collection('users').doc(user.uid);

    await userRef.update({
      "reviews": FieldValue.arrayUnion([
        {
          "productId": productId,
          "rating": rating,
          "comment": comment,
          "timestamp": Timestamp.now(),
        }
      ])
    });
  } else {
    throw Exception("Kullanıcı oturumu açık değil.");
  }
}

Future<List<String>> getPurchasedProducts() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return [];

  final ordersSnapshot = await FirebaseFirestore.instance
      .collection('orders')
      .where('userId', isEqualTo: user.uid)
      .get();

  List<String> productIds = [];

  for (var orderDoc in ordersSnapshot.docs) {
    final orderData = orderDoc.data();
    if (orderData['products'] != null) {
      final products = orderData['products'] as List<dynamic>;
      for (var product in products) {
        if (product['isReviewed'] == false) {
          productIds.add(product['productId'] as String);
        }
      }
    }
  }

  return productIds;
}
Future<void> addReviewToProduct(String productId, double rating, String comment) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final productRef = _firestore.collection('products').doc(productId);

    await productRef.update({
      "reviews": FieldValue.arrayUnion([
        {
          "userId": user.uid,
          "rating": rating,
          "comment": comment,
          "timestamp": Timestamp.now(),
        }
      ])
    });
  } else {
    throw Exception("Kullanıcı oturumu açık değil.");
  }
}
Future<double> getAverageRating(String productId) async {
  final productRef = FirebaseFirestore.instance.collection('products').doc(productId);
  final snapshot = await productRef.get();

  if (snapshot.exists) {
    final data = snapshot.data();
    final reviews = data?['reviews'] as List<dynamic>?;

    if (reviews != null && reviews.isNotEmpty) {
      double totalRating = 0;
      reviews.forEach((review) {
        totalRating += (review['rating'] as num).toDouble();
      });
      return totalRating / reviews.length;
    }
  }
  return 0.0; // Eğer yorum yoksa ortalama 0
}

Future<void> updateProductRating(String productId, double newRating) async {
  final productRef = FirebaseFirestore.instance.collection('products').doc(productId);

  await FirebaseFirestore.instance.runTransaction((transaction) async {
    final snapshot = await transaction.get(productRef);

    if (!snapshot.exists) {
      throw Exception("Ürün bulunamadı.");
    }

    final data = snapshot.data() as Map<String, dynamic>;
    final currentRating = (data['averageRating'] as num?)?.toDouble() ?? 0.0;
    final reviewCount = (data['reviewCount'] as int?) ?? 0;

    final updatedRating = (currentRating * reviewCount + newRating) / (reviewCount + 1);
    final updatedReviewCount = reviewCount + 1;

    transaction.update(productRef, {
      'averageRating': updatedRating,
      'reviewCount': updatedReviewCount,
    });
  });
}

}