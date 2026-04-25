import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios e Consultas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.attach_money), text: "Financeiro"),
            Tab(icon: Icon(Icons.inventory_2), text: "Estoque"),
            Tab(icon: Icon(Icons.people), text: "Clientes/Fornecedores"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _relatorioFinanceiro(),
          _relatorioEstoque(),
          _relatorioContatos(),
        ],
      ),
    );
  }

  // --- RELATÓRIO FINANCEIRO ---
  Widget _relatorioFinanceiro() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _supabase.from('lancamentos').stream(primaryKey: ['id']).order('data_vencimento'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final dados = snapshot.data!;
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text("Filtrar por período: "),
                  const SizedBox(width: 10),
                  ElevatedButton(onPressed: () {}, child: const Text("Selecionar Datas")),
                  const Spacer(),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.picture_as_pdf), tooltip: "Exportar PDF"),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Vencimento')),
                    DataColumn(label: Text('Descrição')),
                    DataColumn(label: Text('Tipo')),
                    DataColumn(label: Text('Valor')),
                  ],
                  rows: dados.map((item) => DataRow(cells: [
                    DataCell(Text(item['data_vencimento'])),
                    DataCell(Text(item['descricao'])),
                    DataCell(Text(item['tipo'], style: TextStyle(color: item['tipo'] == 'receita' ? Colors.green : Colors.red))),
                    DataCell(Text("R\$ ${item['valor']}")),
                  ])).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- RELATÓRIO ESTOQUE ---
  Widget _relatorioEstoque() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assessment, size: 100, color: Colors.blueGrey),
          const Text("Geração de inventário completo em PDF"),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () {}, child: const Text("Gerar Relatório de Estoque")),
        ],
      ),
    );
  }

  // --- RELATÓRIO CONTATOS (CLIENTES/FORNECEDORES) ---
  Widget _relatorioContatos() {
     return const Center(child: Text("Busque um cliente para ver o histórico de compras."));
  }
}