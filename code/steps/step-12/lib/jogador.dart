import 'combatente.dart';

class Jogador with Combatente {
  final String nome;
  int _ouro;
  String _salaAtual;
  final List<String> _inventario;

  Jogador(
    this.nome, {
    int hpInicial = 100,
    int ouro = 0,
    String salaAtual = 'praca',
    List<String>? inventario,
  })  : _ouro = ouro,
        _salaAtual = salaAtual,
        _inventario = inventario ?? [] {
    hp = hpInicial;
    maxHp = hpInicial;
  }

  int get ouro => _ouro;
  String get salaAtual => _salaAtual;
  List<String> get inventario => List.unmodifiable(_inventario);

  void receberOuro(int quantidade) {
    _ouro += quantidade;
  }

  bool pegarItem(String item) {
    if (_inventario.length >= 10) {
      return false;
    }
    _inventario.add(item);
    return true;
  }

  bool largarItem(String item) {
    return _inventario.remove(item);
  }

  void moverPara(String novaSalaId) {
    _salaAtual = novaSalaId;
  }

  @override
  String toString() {
    return 'Jogador($nome, HP: ${mostrarBarraVida()}, Ouro: ${_ouro}g)';
  }
}

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
    final preenchimento = '█' * (hp ~/ (maxHp ~/ 10 + 1));
    final vazio = '░' * (10 - preenchimento.length);
    return '[$preenchimento$vazio] $hp/$maxHp';
  }
}
