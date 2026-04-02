/// Modelo de dados do jogador (sem responsabilidades de renderização)
class Jogador {
  final String nome;
  int hp;
  int maxHp;
  int ataque;
  int ouro;
  int nivel;
  int xp;
  List<String> inventario;

  Jogador({
    required this.nome,
    this.hp = 50,
    this.maxHp = 50,
    this.ataque = 5,
    this.ouro = 0,
    this.nivel = 1,
    this.xp = 0,
  }) : inventario = [];

  bool get estaVivo => hp > 0;

  void sofrerDano(int dano) {
    hp = (hp - dano).clamp(0, maxHp);
  }

  void curar(int amount) {
    hp = (hp + amount).clamp(0, maxHp);
  }

  void adicionarOuro(int quantidade) {
    ouro += quantidade;
  }

  @override
  String toString() =>
      '$nome (Nv.$nivel) | HP: $hp/$maxHp | ATK: $ataque | Ouro: $ouro';
}
