class Sala {
  final String id;
  final String nome;
  final String descricao;
  final Map<String, String> saidas;
  final List<String> itens;
  final bool temLoja;
  final String? inimigoId;

  Sala({
    required this.id,
    required this.nome,
    required this.descricao,
    Map<String, String>? saidas,
    List<String>? itens,
    this.temLoja = false,
    this.inimigoId,
  })  : saidas = saidas ?? {},
        itens = itens ?? [];

  bool temSaida(String direcao) => saidas.containsKey(direcao);
  String? saidaPara(String direcao) => saidas[direcao];
  bool get temInimigo => inimigoId != null;
  bool get temItens => itens.isNotEmpty;

  @override
  String toString() => '$nome ($id)';
}
