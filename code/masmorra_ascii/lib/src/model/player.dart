import 'item.dart';

/// Caps. 8–9 — jogador como objeto; Caps. 11/13 — combate, ouro, inventário.
class Player {
  Player({
    required this.name,
    this.hp = 20,
    this.ouro = 12,
    this.roomId = 'praca',
  });

  final String name;
  int hp;
  int ouro;
  String roomId;
  final List<Item> inventario = [];
  Weapon? armaEquipada;

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
      if (it is Weapon && it.id == id) {
        armaEquipada = it;
        return true;
      }
    }
    return false;
  }
}
