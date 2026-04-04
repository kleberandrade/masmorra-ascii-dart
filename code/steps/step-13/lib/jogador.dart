import 'item.dart';
import 'arma.dart';
import 'armadura.dart';

mixin Combatente {
  int hp = 0;
  int maxHp = 0;

  void sofrerDano(int d) {
    hp -= d;
    if (hp < 0) {
      hp = 0;
    }
  }

  void curar(int q) {
    hp += q;
    if (hp > maxHp) {
      hp = maxHp;
    }
  }

  bool get estaVivo => hp > 0;

  String mostrarBarraVida() {
    final pre = '█' * (hp ~/ (maxHp ~/ 10 + 1));
    final vaz = '░' * (10 - pre.length);
    return '[$pre$vaz] $hp/$maxHp';
  }
}

class Jogador with Combatente {
  final String nome;
  int _ouro;
  String _salaAtual;
  final List<Item> _inventario;
  Arma? armaEquipada;
  Armadura? armaduraEquipada;

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

  bool gastarOuro(int quantidade) {
    if (_ouro < quantidade) {
      return false;
    }
    _ouro -= quantidade;
    return true;
  }

  void adicionarItem(Item item) {
    if (_inventario.length < 10) {
      _inventario.add(item);
    }
  }

  bool tentarComprar(Item item) {
    if (!gastarOuro(item.preco)) {
      return false;
    }
    adicionarItem(item);
    return true;
  }

  bool tentarVender(int indice) {
    if (indice < 0 || indice >= _inventario.length) {
      return false;
    }

    final item = _inventario[indice];

    if (armaEquipada == item || armaduraEquipada == item) {
      return false;
    }

    final preco = (item.preco * 0.5).toInt();
    _ouro += preco;
    _inventario.removeAt(indice);
    return true;
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

  void mostraStatus() {
    // ignore: avoid_print
    print('\n== STATUS ==');
    // ignore: avoid_print
    print('HP: $hp/$maxHp');
    // ignore: avoid_print
    print(
      'Dano: $danoTotal (base: 5${armaEquipada != null ? ' + ${armaEquipada!.dano} arma' : ''})',
    );
    // ignore: avoid_print
    print(
      'Defesa: $defesaTotal (base: 2${armaduraEquipada != null ? ' + ${armaduraEquipada!.defesa} armadura' : ''})',
    );
    // ignore: avoid_print
    print('Ouro: $_ouro');
  }

  void moverPara(String novaSalaId) {
    _salaAtual = novaSalaId;
  }

  @override
  String toString() {
    return 'Jogador($nome, HP: ${mostrarBarraVida()}, Dano: $danoTotal, Defesa: $defesaTotal)';
  }
}
