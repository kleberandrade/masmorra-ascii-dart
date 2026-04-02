import 'item.dart';

/// Representa o jogador
class Jogador {
  final String nome;
  int hp;
  int maxHp;
  int ataque;
  int ouro;
  int tamanhoInventario;
  List<Item> inventario;

  Jogador({
    required this.nome,
    this.hp = 50,
    this.maxHp = 50,
    this.ataque = 5,
    this.ouro = 0,
    this.tamanhoInventario = 10,
  }) : inventario = [];

  bool get estaVivo => hp > 0;

  void adicionarItem(Item item) {
    if (inventario.length < tamanhoInventario) {
      inventario.add(item);
    }
  }

  void sofrerDano(int dano) {
    hp = (hp - dano).clamp(0, maxHp);
  }

  void curar(int amount) {
    hp = (hp + amount).clamp(0, maxHp);
  }

  @override
  String toString() => '$nome (HP: $hp/$maxHp, Ataque: $ataque, Ouro: $ouro)';
}
