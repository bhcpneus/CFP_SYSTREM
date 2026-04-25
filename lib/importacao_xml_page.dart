import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:xml/xml.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- TÓPICO 2: MODELO DE DADOS PARA CONFERÊNCIA ---
class ItemImportacao {
  String codigoOriginal;
  String descricaoOriginal;
  String novaDescricao;
  double precoCusto;
  int quantidade;
  String? idProdutoVinculado;

  ItemImportacao({
    required this.codigoOriginal,
    required this.descricaoOriginal,
    required this.novaDescricao,
    required this.precoCusto,
    required this.quantidade,
    this.idProdutoVinculado,
  });
}

class ImportacaoXmlPage extends StatefulWidget {
  const ImportacaoXmlPage({super.key});

  @override
  State<ImportacaoXmlPage> createState() => _ImportacaoXmlPageState();
}

class _ImportacaoXmlPageState extends State<ImportacaoXmlPage> {
  List<ItemImportacao> _itensParaConferir = [];
  bool _processando = false;

  // Função para ler o XML e transformar em nossa lista de conferência
  Future<void> _processarArquivoXML() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xml'],
    );

    if (result != null && result.files.first.bytes != null) {
      setState(() => _processando = true);

      try {
        final xmlString = utf8.decode(result.files.first.bytes!);
        final document = XmlDocument.parse(xmlString);
        final listaItensXml = document.findAllElements('det');

        List<ItemImportacao> temporario = [];

        for (var item in listaItensXml) {
          final prod = item.findElements('prod').first;
          
          temporario.add(ItemImportacao(
            codigoOriginal: prod.findElements('cProd').first.innerText,
            descricaoOriginal: prod.findElements('xProd').first.innerText,
            novaDescricao: prod.findElements('xProd').first.innerText, // Começa igual à original
            precoCusto: double.parse(prod.findElements('vUnCom').first.innerText),
            quantidade: double.parse(prod.findElements('qCom').first.innerText).toInt(),
          ));
        }

        setState(() {
          _itensParaConferir = temporario;
          _processando = false;
        });
      } catch (e) {
        setState(() => _processando = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao ler XML: $e")));
      }
    }
  }

  // Simulação de salvar no Banco de Dados
  Future<void> _confirmarEntrada() async {
    // Aqui percorreríamos a lista _itensParaConferir e salvaríamos no Supabase
    // conforme a lógica de criar novo ou atualizar existente.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Entrada processada com sucesso!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrada de Nota Fiscal (XML)')),
      body: _processando 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _processarArquivoXML,
                icon: const Icon(Icons.file_upload),
                label: const Text("Carregar XML da Nota"),
              ),
              const Divider(height: 40),
              
              // --- TÓPICO 3: LISTA DE CONFERÊNCIA ---
              Expanded(
                child: _itensParaConferir.isEmpty 
                  ? const Center(child: Text("Selecione um XML para ver os itens"))
                  : ListView.builder(
                      itemCount: _itensParaConferir.length,
                      itemBuilder: (context, index) {
                        final item = _itensParaConferir[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  initialValue: item.novaDescricao,
                                  decoration: const InputDecoration(
                                    labelText: 'Descrição para o seu Cadastro',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (val) => item.novaDescricao = val,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Cód. Original: ${item.codigoOriginal}"),
                                    Text("Qtd: ${item.quantidade}"),
                                    Text("Custo: R\$ ${item.precoCusto}"),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // TODO: Abrir busca de produto existente
                                      },
                                      icon: const Icon(Icons.link, size: 16),
                                      label: const Text("Vincular"),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              ),
              if (_itensParaConferir.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      onPressed: _confirmarEntrada,
                      child: const Text("Confirmar Entrada e Atualizar Estoque"),
                    ),
                  ),
                )
            ],
          ),
    );
  }
}