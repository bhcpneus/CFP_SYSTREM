import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CadastroFornecedorPage extends StatefulWidget {
  const CadastroFornecedorPage({super.key});

  @override
  State<CadastroFornecedorPage> createState() => _CadastroFornecedorPageState();
}

class _CadastroFornecedorPageState extends State<CadastroFornecedorPage> {
  final _formKey = GlobalKey<FormState>();
  final _razaoController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _emailController = TextEditingController();
  bool _carregando = false;

  Future<void> _salvarFornecedor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);
    try {
      await Supabase.instance.client.from('fornecedores').insert({
        'razao_social': _razaoController.text,
        'cnpj': _cnpjController.text,
        'email': _emailController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fornecedor cadastrado!')));
        _razaoController.clear();
        _cnpjController.clear();
        _emailController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Fornecedor')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _razaoController,
                decoration: const InputDecoration(labelText: 'Razão Social', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _cnpjController,
                decoration: const InputDecoration(labelText: 'CNPJ', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail para Pedidos', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 30),
              _carregando 
                ? const CircularProgressIndicator() 
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _salvarFornecedor, 
                      child: const Text('Salvar Fornecedor')
                    ),
                  )
            ],
          ),
        ),
      ),
    );
  }
}