import 'package:flutter/material.dart';

void main() {
  runApp(const NaamaStoreApp());
}

class NaamaStoreApp extends StatelessWidget {
  const NaamaStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نعمة ستور',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: StoreHomePage(),
      ),
    );
  }
}

class StoreHomePage extends StatefulWidget {
  const StoreHomePage({super.key});

  @override
  State<StoreHomePage> createState() => _StoreHomePageState();
}

class _StoreHomePageState extends State<StoreHomePage> {
  final List<Product> _products = const [
    Product(
      id: 'p1',
      name: 'تمر فاخر',
      description: 'تمر طبيعي من أجود الأنواع.',
      price: 32.0,
      icon: Icons.grain,
    ),
    Product(
      id: 'p2',
      name: 'عسل طبيعي',
      description: 'عسل نقي 100% من مناحل محلية.',
      price: 58.0,
      icon: Icons.local_florist,
    ),
    Product(
      id: 'p3',
      name: 'قهوة عربية',
      description: 'قهوة محمصة بطابع عربي أصيل.',
      price: 25.0,
      icon: Icons.coffee,
    ),
    Product(
      id: 'p4',
      name: 'مكسرات مشكلة',
      description: 'خليط مكسرات طازج وصحي.',
      price: 45.0,
      icon: Icons.set_meal,
    ),
  ];

  final Map<String, int> _cart = <String, int>{};

  int get _cartItemsCount {
    return _cart.values.fold(0, (sum, qty) => sum + qty);
  }

  double get _cartTotal {
    double total = 0;
    for (final product in _products) {
      final quantity = _cart[product.id] ?? 0;
      total += quantity * product.price;
    }
    return total;
  }

  void _addToCart(Product product) {
    setState(() {
      _cart.update(product.id, (oldQty) => oldQty + 1, ifAbsent: () => 1);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تمت إضافة ${product.name} إلى السلة')),
    );
  }

  void _removeFromCart(Product product) {
    final currentQty = _cart[product.id] ?? 0;
    if (currentQty == 0) {
      return;
    }

    setState(() {
      if (currentQty == 1) {
        _cart.remove(product.id);
      } else {
        _cart[product.id] = currentQty - 1;
      }
    });
  }

  void _openCartSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final cartProducts = _products.where((item) => (_cart[item.id] ?? 0) > 0).toList();
        if (cartProducts.isEmpty) {
          return const SizedBox(
            height: 220,
            child: Center(
              child: Text(
                'السلة فارغة حاليًا',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'سلة نعمة ستور',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: cartProducts.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final product = cartProducts[index];
                    final quantity = _cart[product.id] ?? 0;
                    final lineTotal = quantity * product.price;

                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text('$quantity × ${product.price.toStringAsFixed(2)} ر.س'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _removeFromCart(product),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('${lineTotal.toStringAsFixed(2)} ر.س'),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'الإجمالي: ${_cartTotal.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {},
                  child: const Text('إتمام الطلب'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نعمة ستور'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'تسوق منتجاتك المفضلة بسرعة وسهولة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: _products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final product = _products[index];
                return ProductCard(
                  product: product,
                  onAdd: () => _addToCart(product),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCartSheet,
        icon: const Icon(Icons.shopping_cart_checkout),
        label: Text('السلة ($_cartItemsCount)'),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onAdd,
  });

  final Product product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(product.icon),
            ),
            const SizedBox(height: 12),
            Text(
              product.name,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              product.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Text(
              '${product.price.toStringAsFixed(2)} ر.س',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('إضافة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final IconData icon;
}
