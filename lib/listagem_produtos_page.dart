import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListagemProdutosPage extends StatelessWidget {
  const ListagemProdutosPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Criamos um "Stream" que fica ouvindo o banco de dados em tempo real
    final _stream = Supabase.instance.client
        .from('produtos')
        .stream(primaryKey: ['id'])
        .order('nome');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório de Estoque / Produtos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pop(context), // Volta para a tela de cadastro
          )
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum produto cadastrado.'));
          }

          final produtos = snapshot.data!;

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                columns: const [
                  DataColumn(label: Text('Nome')),
                  DataColumn(label: Text('Preço Venda')),
                  DataColumn(label: Text('Estoque')),
                  DataColumn(label: Text('Status')),
                ],
                rows: produtos.map((prod) {
                  final estoque = prod['estoque_atual'] ?? 0;
                  return DataRow(cells: [
                    DataCell(Text(prod['nome'].toString())),
                    DataCell(Text('R\$ ${prod['preco_venda']}')),
                    DataCell(Text(estoque.toString())),
                    DataCell(
                      Icon(
                        Icons.circle,
                        color: estoque > 0 ? Colors.green : Colors.red,
                        size: 12,
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}