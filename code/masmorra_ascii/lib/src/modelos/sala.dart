/// Cap. 8–10 — sala com saídas nomeadas (texto) até termos grade.
class Sala {
  Sala({
    required this.id,
    required this.descricao,
    Map<String, String>? saidas,
    this.inimigoId,
    this.temLoja = false,
  }) : saidas = saidas ?? const {};

  final String id;
  final String descricao;
  final Map<String, String> saidas;
  final String? inimigoId;
  final bool temLoja;
}
