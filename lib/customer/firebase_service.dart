import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

   Future<void> addOrder({required String sellerId, required Map<String, dynamic> orderData}) async {
    await FirebaseFirestore.instance.collection('orders').add(orderData);
  }

  Future<List<Map<String, dynamic>>> getOrdersForSeller(String sellerId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

   Future<void> updateOrderStatus(String orderId, String status) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': status,
      'shippedAt': status == 'shipped' ? Timestamp.now() : null,
    });
  }

void updateProductSearchKeys() async {
  CollectionReference products = FirebaseFirestore.instance.collection('products');
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
}



  Future<List<Map<String, dynamic>>?> getUserAddresses() async {
    return null;
  
    // Kullanıcı adreslerini almak için mevcut kodunuz
  }
