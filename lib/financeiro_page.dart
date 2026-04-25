import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FinanceiroPage extends StatefulWidget {
  const FinanceiroPage({super.key});

  @override
  State<FinanceiroPage> createState() => _FinanceiroPageState();
}

class _FinanceiroPageState extends State<FinanceiroPage> {
  final _supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financeiro - Contas a Pagar/Receber')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Aqui abriria um formulário de novo lançamento manual
        },
        label: const Text('Novo Lançamento'),
        icon: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Resumo de Saldo
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.blue[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _cardResumo("A Receber", Colors.green),
                _cardResumo("A Pagar", Colors.red),
              ],
            ),
          ),
          // Lista de Lançamentos
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _supabase.from('lancamentos').stream(primaryKey: ['id']).order('data_vencimento'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final lancamentos = snapshot.data!;

                return ListView.builder(
                  itemCount: lancamentos.length,
                  itemBuilder: (context, index) {
                    final item = lancamentos[index];
                    return ListTile(
                      leading: Icon(
                        item['tipo'] == 'receita' ? Icons.arrow_upward : Icons.arrow_downward,
                        color: item['tipo'] == 'receita' ? Colors.green : Colors.red,
                      ),
                      title: Text(item['descricao']),
                      subtitle: Text("Vence em: ${item['data_vencimento']}"),
                      trailing: Text(
                        "R\$ ${item['valor']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        // Lógica para dar baixa no pagamento
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardResumo(String titulo, Color cor) {
    return Column(
      children: [
        Text(titulo, style: TextStyle(color: cor, fontWeight: FontWeight.bold)),
        const Text("R\$ 0,00", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}