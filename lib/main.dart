import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Substitua pelos seus dados do painel do Supabase (Project Settings > API)
  await Supabase.initialize(
    url: 'SUA_URL_DO_SUPABASE',
    anonKey: 'SUA_CHAVE_ANON_DO_SUPABASE',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ERP Web',
      theme: ThemeData(primarySwatch: const Color.fromARGB(255, 213, 225, 235), useMaterial3: true),
      home: const CadastroProdutoPage(),
    );
  }
}