import 'dart:async';

import '../../models/address_model.dart';
import '../../models/cart_item_model.dart';
import '../../models/category_model.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../models/review_model.dart';
import '../../models/user_model.dart';

/// Shared in-memory fallback store used when Firebase is unavailable.
class FirebaseDemoStore {
  FirebaseDemoStore._();

  static bool _initialized = false;

  static final StreamController<UserModel?> authStateController =
      StreamController<UserModel?>.broadcast();

  static UserModel? currentUser;

  static final Map<String, UserModel> usersById = <String, UserModel>{};
  static final Map<String, String> passwordsByUserId = <String, String>{};
  static final Map<String, CategoryModel> categoriesById = <String, CategoryModel>{};
  static final Map<String, ProductModel> productsById = <String, ProductModel>{};
  static final Map<String, OrderModel> ordersById = <String, OrderModel>{};
  static final Map<String, AddressModel> addressesById = <String, AddressModel>{};
  static final Map<String, ReviewModel> reviewsById = <String, ReviewModel>{};
  static final Map<String, CartItemModel> cartItemsById = <String, CartItemModel>{};
  static final Map<String, Map<String, dynamic>> paymentByOrderId = <String, Map<String, dynamic>>{};

  static void ensureInitialized() {
    if (_initialized) {
      return;
    }
    _initialized = true;

    final DateTime seedDate = DateTime(2026, 2, 14);

    final UserModel admin = UserModel(
      id: 'demo-admin-1',
      fullName: 'Admin Demo',
      email: 'admin@nema.store',
      phone: '+9647000000000',
      userType: UserType.admin,
      isVerified: true,
      createdAt: seedDate,
    );
    final UserModel vendor = UserModel(
      id: 'demo-vendor-1',
      fullName: 'Ali Hasan',
      email: 'vendor@nema.store',
      phone: '+9647000000001',
      userType: UserType.vendor,
      isVerified: true,
      createdAt: seedDate,
      storeName: 'متجر علي',
      storeDescription: 'إلكترونيات ومنتجات منزلية',
      isApproved: true,
      subscriptionPlan: 'pro',
      rating: 4.7,
      totalSales: 142,
    );
    final UserModel customer = UserModel(
      id: 'demo-customer-1',
      fullName: 'Demo Customer',
      email: 'customer@nema.store',
      phone: '+9647000000002',
      userType: UserType.customer,
      isVerified: true,
      createdAt: seedDate,
      wishlist: const <String>['demo-product-1', 'demo-product-2'],
    );

    usersById[admin.id] = admin;
    usersById[vendor.id] = vendor;
    usersById[customer.id] = customer;
    passwordsByUserId[admin.id] = '123456';
    passwordsByUserId[vendor.id] = '123456';
    passwordsByUserId[customer.id] = '123456';

    final List<CategoryModel> categories = <CategoryModel>[
      CategoryModel(
        id: 'electronics',
        name: 'Electronics',
        nameAr: 'إلكترونيات',
        sortOrder: 1,
        createdAt: seedDate,
      ),
      CategoryModel(
        id: 'home',
        name: 'Home',
        nameAr: 'منزل',
        sortOrder: 2,
        createdAt: seedDate,
      ),
      CategoryModel(
        id: 'fashion',
        name: 'Fashion',
        nameAr: 'أزياء',
        sortOrder: 3,
        createdAt: seedDate,
      ),
    ];
    for (final CategoryModel category in categories) {
      categoriesById[category.id] = category;
    }

    final List<ProductModel> products = <ProductModel>[
      ProductModel(
        id: 'demo-product-1',
        vendorId: vendor.id,
        name: 'سماعات لاسلكية',
        description: 'سماعات بجودة صوت عالية وبطارية طويلة.',
        categoryId: 'electronics',
        price: 45000,
        discountPrice: 39000,
        stock: 15,
        images: const <String>[],
        status: ProductStatus.approved,
        rating: 4.5,
        reviewsCount: 82,
        ordersCount: 44,
        createdAt: seedDate,
      ),
      ProductModel(
        id: 'demo-product-2',
        vendorId: vendor.id,
        name: 'خلاط مطبخ',
        description: 'خلاط عملي بقدرة ممتازة للاستخدام اليومي.',
        categoryId: 'home',
        price: 62000,
        stock: 8,
        images: const <String>[],
        status: ProductStatus.approved,
        rating: 4.2,
        reviewsCount: 24,
        ordersCount: 19,
        createdAt: seedDate,
      ),
      ProductModel(
        id: 'demo-product-3',
        vendorId: vendor.id,
        name: 'هاتف ذكي',
        description: 'جهاز سريع مع بطارية قوية.',
        categoryId: 'electronics',
        price: 320000,
        stock: 5,
        images: const <String>[],
        status: ProductStatus.pending,
        createdAt: seedDate,
      ),
    ];
    for (final ProductModel product in products) {
      productsById[product.id] = product;
    }

    final AddressModel customerAddress = AddressModel(
      id: 'demo-address-1',
      userId: customer.id,
      label: 'المنزل',
      fullName: customer.fullName,
      phone: customer.phone,
      city: 'بغداد',
      area: 'الكرادة',
      street: 'شارع 52',
      isDefault: true,
      createdAt: seedDate,
    );
    addressesById[customerAddress.id] = customerAddress;

    final ReviewModel review = ReviewModel(
      id: 'demo-review-1',
      productId: 'demo-product-1',
      userId: customer.id,
      userName: customer.fullName,
      rating: 5,
      comment: 'منتج ممتاز وسعر مناسب.',
      isApproved: true,
      isVerifiedPurchase: true,
      createdAt: seedDate,
    );
    reviewsById[review.id] = review;

    final CartItemModel orderItem = CartItemModel(
      id: 'demo-order-1-item-1',
      userId: customer.id,
      productId: 'demo-product-1',
      productName: 'سماعات لاسلكية',
      unitPrice: 39000,
      quantity: 1,
      createdAt: seedDate,
    );
    final OrderModel order = OrderModel(
      id: 'demo-order-1',
      orderNumber: 'NS-1700000000',
      userId: customer.id,
      vendorId: vendor.id,
      items: <CartItemModel>[orderItem],
      status: OrderStatus.processing,
      subtotal: 39000,
      deliveryFee: 3000,
      total: 42000,
      addressId: customerAddress.id,
      addressSnapshot: <String, dynamic>{
        'city': customerAddress.city,
        'area': customerAddress.area,
        'street': customerAddress.street,
      },
      createdAt: seedDate,
    );
    ordersById[order.id] = order;
  }

  static void setCurrentUser(UserModel? user) {
    currentUser = user;
    if (!authStateController.isClosed) {
      authStateController.add(user);
    }
  }
}
