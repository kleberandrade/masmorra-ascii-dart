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

  Jogador.recruta(String nome)
      : this(nome, hpInicial: 80, ouro: 10);

  Jogador.veterano(String nome)
      : this(nome, hpInicial: 150, ouro: 100);

  int get ouro => _ouro;
  String get salaAtual => _salaAtual;
  List<String> get inventario => List.unmodifiable(_inventario);

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

  bool get inventarioCheio => _inventario.length >= 10;

  bool pegarItem(String item) {
    if (inventarioCheio) {
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
