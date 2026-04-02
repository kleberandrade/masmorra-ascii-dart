/// Cap. 8–10 — sala com saídas nomeadas (texto) até termos grade.
class Room {
  Room({
    required this.id,
    required this.description,
    Map<String, String>? saidas,
    this.inimigoId,
    this.temLoja = false,
  }) : saidas = saidas ?? const {};

  final String id;
  final String description;
  final Map<String, String> saidas;
  final String? inimigoId;
  final bool temLoja;
}
