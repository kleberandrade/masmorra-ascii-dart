enum Direcao {
  norte(simbolo: '↑', id: 'n'),
  sul(simbolo: '↓', id: 's'),
  leste(simbolo: '→', id: 'e'),
  oeste(simbolo: '←', id: 'o');

  final String simbolo;
  final String id;

  const Direcao({required this.simbolo, required this.id});

  Direcao get oposta {
    switch (this) {
      case Direcao.norte:
        return Direcao.sul;
      case Direcao.sul:
        return Direcao.norte;
      case Direcao.leste:
        return Direcao.oeste;
      case Direcao.oeste:
        return Direcao.leste;
    }
  }

  static Direcao? deString(String s) {
    switch (s.toLowerCase()) {
      case 'n':
      case 'norte':
        return Direcao.norte;
      case 's':
      case 'sul':
        return Direcao.sul;
      case 'e':
      case 'leste':
        return Direcao.leste;
      case 'o':
      case 'oeste':
        return Direcao.oeste;
      default:
        return null;
    }
  }
}
