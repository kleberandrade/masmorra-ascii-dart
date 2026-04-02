class Jogador {
  final String nome;
  int _hp;
  int _maxHp;
  int _ouro;
  int _ataque;
  String _salaAtual;
  final List<String> _inventario;

  Jogador(
    this.nome, {
    int hp = 100,
    int maxHp = 100,
    int ouro = 0,
    int ataque = 5,
    String salaAtual = 'praca',
    List<String>? inventario,
  })  : _hp = hp,
        _maxHp = maxHp,
        _ouro = ouro,
        _ataque = ataque,
        _salaAtual = salaAtual,
        _inventario = inventario ?? [];

  Jogador.recruta(String nome)
      : this(nome, hp: 80, maxHp: 80, ouro: 10, ataque: 3);

  Jogador.veterano(String nome)
      : this(nome, hp: 150, maxHp: 150, ouro: 100, ataque: 12);

  int get hp => _hp;
  int get maxHp => _maxHp;
  int get ouro => _ouro;
  int get ataque => _ataque;
  String get salaAtual => _salaAtual;
  List<String> get inventario => List.unmodifiable(_inventario);

  void sofrerDano(int quantidade) {
    if (quantidade < 0) {
      return;
    }
    _hp -= quantidade;
    if (_hp < 0) {
      _hp = 0;
    }
  }

  void curar(int quantidade) {
    if (quantidade < 0) {
      return;
    }
    _hp += quantidade;
    if (_hp > _maxHp) {
      _hp = _maxHp;
    }
  }

  bool gastarOuro(int quantidade) {
    if (_ouro < quantidade) {
      return false;
    }
    _ouro -= quantidade;
    return true;
  }

  void receberOuro(int quantidade) {
    _ouro += quantidade;
  }

  bool get estaVivo => _hp > 0;
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
    return 'Jogador($nome, HP: $_hp/$_maxHp, Ouro: ${_ouro}g, Ataque: $_ataque)';
  }
}
