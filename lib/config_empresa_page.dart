import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

class ConfigEmpresaPage extends StatefulWidget {
  const ConfigEmpresaPage({super.key});

  @override
  State<ConfigEmpresaPage> createState() => _ConfigEmpresaPageState();
}

class _ConfigEmpresaPageState extends State<ConfigEmpresaPage> {
  final _razaoController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _senhaCertController = TextEditingController();
  String? _nomeArquivoCertificado;
  bool _obscureSenha = true;

  // Função para selecionar o arquivo do certificado (.pfx ou .p12)
  Future<void> _selecionarCertificado() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pfx', 'p12'],
    );

    if (result != null) {
      setState(() {
        _nomeArquivoCertificado = result.files.first.name;
      });
      // Aqui, no futuro, converteremos o arquivo para Base64 para salvar no banco
    }
  }

  Future<void> _salvarConfiguracoes() async {
    try {
      await Supabase.instance.client.from('config_empresa').upsert({
        'id': 1,
        'razao_social': _razaoController.text,
        'cnpj': _cnpjController.text,
        'senha_certificado': _senhaCertController.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configurações atualizadas!')));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dados da Empresa e Certificado')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informações Comerciais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            TextField(controller: _razaoController, decoration: const InputDecoration(labelText: 'Razão Social')),
            TextField(controller: _cnpjController, decoration: const InputDecoration(labelText: 'CNPJ')),
            const SizedBox(height: 30),
            
            const Text('Configuração Fiscal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.file_present),
              title: Text(_nomeArquivoCertificado ?? 'Selecionar Certificado Digital (.pfx)'),
              trailing: ElevatedButton(onPressed: _selecionarCertificado, child: const Text('Upload')),
            ),
            TextField(
              controller: _senhaCertController,
              obscureText: _obscureSenha,
              decoration: InputDecoration(
                labelText: 'Senha do Certificado',
                suffixIcon: IconButton(
                  icon: Icon(_obscureSenha ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureSenha = !_obscureSenha),
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                onPressed: _salvarConfiguracoes, 
                child: const Text('Salvar Tudo')
              ),
            )
          ],
        ),
      ),
    );
  }
}