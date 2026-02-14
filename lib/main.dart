import 'package:flutter/material.dart';

import 'app.dart';
import 'config/dependency_injection/injection_container.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  runApp(const NemaStoreApp());
}
