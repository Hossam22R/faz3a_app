import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDataSource {
  FirebaseDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> usersCollection() {
    return firestore.collection('users');
  }

  CollectionReference<Map<String, dynamic>> productsCollection() {
    return firestore.collection('products');
  }

  CollectionReference<Map<String, dynamic>> ordersCollection() {
    return firestore.collection('orders');
  }

  CollectionReference<Map<String, dynamic>> categoriesCollection() {
    return firestore.collection('categories');
  }

  CollectionReference<Map<String, dynamic>> reviewsCollection() {
    return firestore.collection('reviews');
  }

  CollectionReference<Map<String, dynamic>> addressesCollection() {
    return firestore.collection('addresses');
  }

  CollectionReference<Map<String, dynamic>> adPackagesCollection() {
    return firestore.collection('ad_packages');
  }

  CollectionReference<Map<String, dynamic>> cartItemsCollection(String userId) {
    return firestore.collection('carts').doc(userId).collection('items');
  }
}
