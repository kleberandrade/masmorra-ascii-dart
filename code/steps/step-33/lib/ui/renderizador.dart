import '../modelos/jogador.dart';

/// Renderizador ASCII polido para Step 32
/// Inclui HUD profissional com barras visuais
class Renderizador {
  static const int largura = 80;

  String renderizarStatus(Jogador jogador) {
    final buffer = StringBuffer();

    buffer.writeln('╔' + '═' * (largura - 2) + '╗');
    buffer.writeln('║ ${_centralizar(jogador.nome, largura - 4)} ║');
    buffer.writeln('║ HP:    [${_barra(jogador.hpAtual, jogador.hpMax, 20)}] ║');
    buffer
        .writeln('║ Nível: ${jogador.nivel.toString().padRight(2)} │ XP: ${jogador.xp.toString().padRight(6)} ║');
    buffer.writeln('║ ATK:   ${jogador.ataque.toString().padRight(2)} │ DEF: ${jogador.defesa.toString().padRight(2)} ║');
    buffer.writeln('╚' + '═' * (largura - 2) + '╝');

    return buffer.toString();
  }

  String _centralizar(String texto, int larg) {
    if (texto.length >= larg) return texto;
    final padding = (larg - texto.length) ~/ 2;
    return texto.padRight(padding + texto.length).padLeft(larg);
  }

  String _barra(int atual, int maximo, int larg) {
    final preenchido = (atual / maximo * larg).toInt();
    final vazio = larg - preenchido;
    final pct = (atual / maximo * 100).toInt();

    return '█' * preenchido + '░' * vazio + ' ${pct.toString().padLeft(3)}%';
  }

  String renderizarMapa(List<String> linha1) {
    final buffer = StringBuffer();
    buffer.writeln('┌─ MAPA ─' + '─' * (largura - 14) + '┐');
    buffer.writeln('│ Renderização de mapa será implementada │');
    buffer.writeln('└' + '─' * (largura - 2) + '┘');
    return buffer.toString();
  }
}
