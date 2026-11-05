import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Descomentar cuando configures Firebase
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(
    // ProviderScope envuelve toda la app para que Riverpod funcione
    const ProviderScope(
      child: CafeteriaApp(),
    ),
  );
}
