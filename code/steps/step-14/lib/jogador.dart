import 'combatente.dart';
import 'item.dart';

class Jogador with Combatente {
  final String nome;
  int _ouro;
  String _salaAtual;
  final List<Item> _inventario;
  Arma? armaEquipada;
  Armadura? armaduraEquipada;
  int xp = 0;

  Jogador(
    this.nome, {
    int hpInicial = 100,
    int ouro = 0,
    String salaAtual = 'praca',
  })  : _ouro = ouro,
        _salaAtual = salaAtual,
        _inventario = [] {
    hp = hpInicial;
    maxHp = hpInicial;
  }

  int get ouro => _ouro;
  String get salaAtual => _salaAtual;
  List<Item> get inventario => List.unmodifiable(_inventario);

  int get danoTotal {
    int total = 5;
    if (armaEquipada != null) {
      total += armaEquipada!.dano;
    }
    return total;
  }

  int get defesaTotal {
    int total = 2;
    if (armaduraEquipada != null) {
      total += armaduraEquipada!.defesa;
    }
    return total;
  }

  void receberOuro(int quantidade) {
    _ouro += quantidade;
  }

  void adicionarItem(Item item) {
    if (_inventario.length < 10) {
      _inventario.add(item);
    }
  }

  bool equiparArma(int indice) {
    if (indice < 0 || indice >= _inventario.length) {
      return false;
    }
    final item = _inventario[indice];
    if (item is! Arma) {
      return false;
    }
    if (armaEquipada != null) {
      _inventario.add(armaEquipada!);
    }
    _inventario.removeAt(indice);
    armaEquipada = item;
    return true;
  }

  bool equiparArmadura(int indice) {
    if (indice < 0 || indice >= _inventario.length) {
      return false;
    }
    final item = _inventario[indice];
    if (item is! Armadura) {
      return false;
    }
    if (armaduraEquipada != null) {
      _inventario.add(armaduraEquipada!);
    }
    _inventario.removeAt(indice);
    armaduraEquipada = item;
    return true;
  }

  void moverPara(String novaSalaId) {
    _salaAtual = novaSalaId;
  }

  @override
  String toString() {
    return 'Jogador($nome, HP: ${mostrarBarraVida()}, Dano: $danoTotal, Defesa: $defesaTotal, XP: $xp)';
  }
}
