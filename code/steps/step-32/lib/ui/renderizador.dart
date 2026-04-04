import '../modelos/jogador.dart';

/// Renderizador ASCII para interface
/// Cria strings formatadas para exibição no terminal
class Renderizador {
  static const int largura = 80;

  /// Renderiza status do jogador
  String renderizarStatus(Jogador jogador) {
    final buffer = StringBuffer();

    buffer.writeln('╔${'═' * (largura - 2)}╗');
    buffer.writeln('║ ${_centralizar(jogador.nome, largura - 4)} ║');
    buffer
        .writeln('║ HP: [${_barra(jogador.hpAtual, jogador.hpMax, 20)}] │ Nível: ${jogador.nivel} ║');
    buffer.writeln('║ Ataque: ${jogador.ataque} │ XP: ${jogador.xp} ║');
    buffer.writeln('╚${'═' * (largura - 2)}╝');

    return buffer.toString();
  }

  /// Centraliza texto em uma largura
  String _centralizar(String texto, int larg) {
    if (texto.length >= larg) return texto;
    final padding = (larg - texto.length) ~/ 2;
    return texto.padRight(padding + texto.length).padLeft(larg);
  }

  /// Renderiza barra visual de HP
  String _barra(int atual, int maximo, int larg) {
    final preenchido = (atual / maximo * larg).toInt();
    final vazio = larg - preenchido;
    final pct = (atual / maximo * 100).toInt();

    return '${'█' * preenchido}${'░' * vazio} ${pct.toString().padLeft(3)}%';
  }

  /// Renderiza banner do jogo
  String renderizarBanner() {
    return '''
╔═══════════════════════════════════════════╗
║                                           ║
║          M A S M O R R A  A S C I I       ║
║                                           ║
║     Um Roguelike em Dart Profissional     ║
║                                           ║
╚═══════════════════════════════════════════╝
''';
  }
}
