import 'inimigo.dart';

class Sala {
  final String id;
  final String nome;
  final String descricao;
  final Map<String, String> saidas;
  final List<String> _itens;
  final bool temLoja;
  Inimigo? inimigoPresente;

  Sala({
    required this.id,
    required this.nome,
    required this.descricao,
    Map<String, String>? saidas,
    List<String>? itens,
    this.temLoja = false,
    this.inimigoPresente,
  })  : saidas = saidas ?? {},
        _itens = itens ?? [];

  List<String> get itens => List.unmodifiable(_itens);

  bool temSaida(String direcao) => saidas.containsKey(direcao);
  String? saidaPara(String direcao) => saidas[direcao];
  bool get temInimigo => inimigoPresente != null;
  bool get temItens => _itens.isNotEmpty;

  void adicionarItem(String item) {
    _itens.add(item);
  }

  bool removerItem(String item) {
    return _itens.remove(item);
  }

  @override
  String toString() => '$nome ($id)';
}
