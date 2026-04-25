import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CadastroProdutoPage extends StatefulWidget {
  const CadastroProdutoPage({super.key});

  @override
  State<CadastroProdutoPage> createState() => _CadastroProdutoPageState();
}

class _CadastroProdutoPageState extends State<CadastroProdutoPage> {
  final _nomeController = TextEditingController();
  final _precoController = TextEditingController();
  final _estoqueController = TextEditingController();
  bool _carregando = false;

  Future<void> _salvarProduto() async {
    setState(() => _carregando = true);
    
    try {
      await Supabase.instance.client.from('produtos').insert({
        'nome': _nomeController.text,
        'preco_venda': double.parse(_precoController.text),
        'estoque_atual': int.parse(_estoqueController.text),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto salvo com sucesso!')),
        );
        _nomeController.clear();
        _precoController.clear();
        _estoqueController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      app_bar: AppBar(title: const Text('Cadastro de Produto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome do Produto')),
            TextField(controller: _precoController, decoration: const InputDecoration(labelText: 'Preço de Venda'), keyboardType: TextInputType.number),
            TextField(controller: _estoqueController, decoration: const InputDecoration(labelText: 'Estoque Inicial'), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            _carregando 
              ? const CircularProgressIndicator() 
              : ElevatedButton(onPressed: _salvarProduto, child: const Text('Salvar Produto'))
          ],
        ),
      ),
    );
  }
}