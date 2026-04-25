import 'dart:convert';
import 'package:http/http.dart' as http;

class FiscalService {
  final String _token = "SEU_TOKEN_DA_API";
  final String _baseUrl = "https://api.focusnfe.com.br/v2"; // Exemplo

  Future<void> emitirNFe(Map<String, dynamic> dadosPedido, Map<String, dynamic> dadosEmpresa) async {
    final body = {
      "cnpj_emitente": dadosEmpresa['cnpj'],
      "data_emissao": DateTime.now().toIso8601String(),
      "modalidade_frete": 9, // Sem frete
      "items": dadosPedido['itens'], // Lista de produtos do carrinho
      "cliente": dadosPedido['cliente'],
    };

    final response = await http.post(
      Uri.parse("$_baseUrl/nfe"),
      headers: {
        "Authorization": "Basic " + base64Encode(utf8.encode("$_token:")),
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      print("Nota enviada com sucesso! Aguardando autorização...");
    } else {
      print("Erro na emissão: ${response.body}");
    }
  }
}