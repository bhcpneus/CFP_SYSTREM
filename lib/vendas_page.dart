import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VendasPage extends StatefulWidget {
  const VendasPage({super.key});

  @override
  State<VendasPage> createState() => _VendasPageState();
}

class _VendasPageState extends State<VendasPage> {
  final List<Map<String, dynamic>> _carrinho = [];
  double _totalPedido = 0;

  void _adicionarProduto(Map<String, dynamic> produto) {
    setState(() {
      _carrinho.add({
        'id': produto['id'],
        'nome': produto['nome'],
        'preco': produto['preco_venda'],
        'qtd': 1,
      });
      _calcularTotal();
    });
  }

  void _calcularTotal() {
    _totalPedido = _carrinho.fold(0, (sum, item) => sum + (item['preco'] * item['qtd']));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Pedido de Venda')),
      body: Row(
        children: [
          // Lado Esquerdo: Seleção de Produtos
          Expanded(
            flex: 2,
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client.from('produtos').stream(primaryKey: ['id']),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final p = snapshot.data![index];
                    return Card(
                      child: ListTile(
                        title: Text(p['nome']),
                        subtitle: Text("R\$ ${p['preco_venda']}"),
                        onTap: () => _adicionarProduto(p),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Lado Direito: Carrinho e Fechamento
          Container(
            width: 350,
            color: Colors.grey[100],
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Itens do Pedido", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _carrinho.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(_carrinho[index]['nome']),
                      trailing: Text("R\$ ${_carrinho[index]['preco']}"),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.blueGrey[900],
                  child: Column(
                    children: [
                      Text("TOTAL: R\$ $_totalPedido", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
                        onPressed: () {
                          // Lógica para salvar no banco e baixar estoque
                        },
                        child: const Text("FINALIZAR VENDA"),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}