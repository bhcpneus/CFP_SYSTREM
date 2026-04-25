class Fornecedor {
  final String? id;
  final String razaoSocial;
  final String cnpj;
  final String? email;

  Fornecedor({this.id, required this.razaoSocial, required this.cnpj, this.email});

  Map<String, dynamic> toMap() {
    return {
      'razao_social': razaoSocial,
      'cnpj': cnpj,
      'email': email,
    };
  }
}