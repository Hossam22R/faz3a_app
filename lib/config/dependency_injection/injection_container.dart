import '../../core/services/auth_session.dart';
import '../../data/data_sources/remote/firebase_data_source.dart';
import '../../data/repositories/firebase/firebase_address_repository.dart';
import '../../data/repositories/firebase/firebase_auth_repository.dart';
import '../../data/repositories/firebase/firebase_cart_repository.dart';
import '../../data/repositories/firebase/firebase_category_repository.dart';
import '../../data/repositories/firebase/firebase_order_repository.dart';
import '../../data/repositories/firebase/firebase_payment_repository.dart';
import '../../data/repositories/firebase/firebase_product_repository.dart';
import '../../data/repositories/firebase/firebase_review_repository.dart';
import '../../data/repositories/firebase/firebase_vendor_repository.dart';
import 'app_dependencies.dart';

bool _isSetup = false;

/// Registers app-wide dependencies.
void setupDependencies() {
  if (_isSetup) {
    return;
  }

  final FirebaseDataSource dataSource = FirebaseDataSource();

  AppDependencies.firebaseDataSource = dataSource;
  AppDependencies.authRepository = FirebaseAuthRepository(dataSource: dataSource);
  AppDependencies.productRepository = FirebaseProductRepository(dataSource);
  AppDependencies.orderRepository = FirebaseOrderRepository(dataSource);
  AppDependencies.vendorRepository = FirebaseVendorRepository(dataSource);
  AppDependencies.categoryRepository = FirebaseCategoryRepository(dataSource);
  AppDependencies.addressRepository = FirebaseAddressRepository(dataSource);
  AppDependencies.reviewRepository = FirebaseReviewRepository(dataSource);
  AppDependencies.cartRepository = FirebaseCartRepository(dataSource);
  AppDependencies.paymentRepository = FirebasePaymentRepository(dataSource);
  AppDependencies.authSession = AuthSession(AppDependencies.authRepository);

  _isSetup = true;
}
