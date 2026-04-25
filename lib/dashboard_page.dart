import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Operacional')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Resumo Financeiro (Mês Atual)", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildCardInfo("Receitas", "R\$ 0,00", Colors.green, Icons.trending_up),
                _buildCardInfo("Despesas", "R\$ 0,00", Colors.red, Icons.trending_down),
                _buildCardInfo("Saldo", "R\$ 0,00", Colors.blue, Icons.account_balance_wallet),
              ],
            ),
            const SizedBox(height: 40),
            const Text("Alertas de Estoque Baixo", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 15),
            
            // Lista em tempo real de produtos com estoque abaixo de 5 unidades
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: client.from('produtos').stream(primaryKey: ['id']).eq('estoque_atual', 0), // Exemplo: estoque zerado
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const LinearProgressIndicator();
                final produtosSemEstoque = snapshot.data!;
                
                if (produtosSemEstoque.isEmpty) {
                  return const Text("Tudo em dia por aqui! ✅");
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: produtosSemEstoque.length,
                  itemBuilder: (context, index) {
                    final p = produtosSemEstoque[index];
                    return ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: Text(p['nome']),
                      subtitle: const Text("Estoque zerado! Faça um pedido de compra."),
                      trailing: ElevatedButton(
                        onPressed: () { /* Navegar para Importação XML */ },
                        child: const Text("Comprar"),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardInfo(String titulo, String valor, Color cor, IconData icone) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(icone, color: cor, size: 30),
              const SizedBox(height: 10),
              Text(titulo, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 5),
              Text(valor, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cor)),
            ],
          ),
        ),
      ),
    );
  }
}