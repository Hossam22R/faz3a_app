import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDataSource {
  FirebaseDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> usersCollection() {
    return _firestore.collection('users');
  }

  CollectionReference<Map<String, dynamic>> productsCollection() {
    return _firestore.collection('products');
  }

  CollectionReference<Map<String, dynamic>> ordersCollection() {
    return _firestore.collection('orders');
  }
}
