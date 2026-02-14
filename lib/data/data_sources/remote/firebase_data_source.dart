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

  CollectionReference<Map<String, dynamic>> categoriesCollection() {
    return _firestore.collection('categories');
  }

  CollectionReference<Map<String, dynamic>> reviewsCollection() {
    return _firestore.collection('reviews');
  }

  CollectionReference<Map<String, dynamic>> addressesCollection() {
    return _firestore.collection('addresses');
  }

  CollectionReference<Map<String, dynamic>> adPackagesCollection() {
    return _firestore.collection('ad_packages');
  }
}
