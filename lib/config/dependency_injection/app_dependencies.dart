import '../../core/services/auth_session.dart';
import '../../data/data_sources/remote/firebase_data_source.dart';
import '../../data/repositories/address_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/review_repository.dart';
import '../../data/repositories/vendor_repository.dart';

class AppDependencies {
  AppDependencies._();

  static late final FirebaseDataSource firebaseDataSource;
  static late final AuthRepository authRepository;
  static late final ProductRepository productRepository;
  static late final OrderRepository orderRepository;
  static late final VendorRepository vendorRepository;
  static late final CategoryRepository categoryRepository;
  static late final AddressRepository addressRepository;
  static late final ReviewRepository reviewRepository;
  static late final CartRepository cartRepository;
  static late final PaymentRepository paymentRepository;
  static late final AuthSession authSession;
}
