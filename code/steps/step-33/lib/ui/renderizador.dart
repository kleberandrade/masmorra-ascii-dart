import '../modelos/jogador.dart';

/// Renderizador ASCII polido para Step 33
/// Inclui HUD profissional com barras visuais, mapa e log de combate
class Renderizador {
  static const int largura = 80;

  /// Renderiza o painel de status do jogador com barras visuais.
  /// Mostra: nome, HP com barra, nível, ataque e XP acumulado.
  String renderizarStatus(Jogador j) {
    final buffer = StringBuffer();

    // Nome centralizado
    buffer.writeln(_centralizar(j.nome, largura));

    // Separador
    buffer.writeln('─' * largura);

    // HP: barra visual + percentual
    buffer.writeln('HP: [${_barra(j.hpAtual, j.hpMax, 20)}] | Nível: ${j.nivel.toString().padRight(2)}');

    // Ataque e XP
    buffer.writeln('Ataque: ${j.ataque.toString().padRight(2)} | XP: ${j.xp.toString().padRight(5)}');

    // Separador final
    buffer.writeln('─' * largura);

    return buffer.toString();
  }

  /// Centraliza texto em uma largura. Se texto é maior que largura, retorna intacto.
  /// Usado para nomes de personagens e títulos.
  String _centralizar(String texto, int larg) {
    if (texto.length >= larg) return texto;
    final padding = (larg - texto.length) ~/ 2;
    return texto.padRight(padding + texto.length).padLeft(larg);
  }

  /// Desenha barra visual (█ preenchido, ░ vazio) com percentual.
  /// Exemplo: _barra(35, 50, 20) renderiza 14 blocos preenchidos, 6 vazios, "70%".
  String _barra(int atual, int maximo, int larg) {
    if (maximo == 0) maximo = 1; // Evita divisão por zero

    final preenchido = (atual / maximo * larg).toInt();
    final vazio = larg - preenchido;
    final pct = (atual / maximo * 100).toInt();

    return '${'█' * preenchido}${'░' * vazio} ${pct.toString().padLeft(3)}%';
  }
}
