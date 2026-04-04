import 'item.dart';

/// Caps. 8–9 — jogador como objeto; Caps. 11/13 — combate, ouro, inventário.
class Jogador {
  Jogador({
    required this.nome,
    this.hp = 20,
    this.ouro = 12,
    this.salaAtual = 'praca',
    this.defesa = 0,
  });

  final String nome;
  int hp;
  int defesa;
  int ouro;
  String salaAtual;
  final List<Item> inventario = [];
  Arma? armaEquipada;

  bool emMasmorra = false;

  int get danoAtual => armaEquipada?.dano ?? 1;

  void danificar(int d) {
    hp -= d;
    if (hp < 0) {
      hp = 0;
    }
  }

  bool equiparArmaPorId(String id) {
    for (final it in inventario) {
      if (it is Arma && it.id == id) {
        armaEquipada = it;
        return true;
      }
    }
    return false;
  }
}
