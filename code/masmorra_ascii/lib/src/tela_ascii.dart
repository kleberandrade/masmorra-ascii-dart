/// Buffer de texto para compor telas **ASCII** (mapa, HUD, caixas).
///
/// Separa o **modelo** do jogo da **vista** textual — tema central a partir
/// do capítulo sobre `StringBuffer` e consolidado na oficina ASCII.
class TelaAscii {
  TelaAscii({this.width = 40, this.height = 20})
    : _lines = List<String>.filled(height, '');

  final int width;
  final int height;
  final List<String> _lines;

  /// Limpa o buffer com espaços à largura fixa.
  void clear([String fill = ' ']) {
    final pad = fill.padRight(1).substring(0, 1);
    final row = pad * width;
    for (var y = 0; y < height; y++) {
      _lines[y] = row;
    }
  }

  /// Escreve texto na posição `(x, y)` sem ultrapassar a largura.
  void write(int x, int y, String text) {
    if (y < 0 || y >= height) return;
    final row = _lines[y];
    if (x >= width) return;
    final start = x.clamp(0, width);
    final maxLen = width - start;
    final clip = text.length > maxLen ? text.substring(0, maxLen) : text;
    _lines[y] = row.replaceRange(start, start + clip.length, clip);
  }

  /// Moldura retangular com cantos `+` e traços `-` / `|`.
  void drawBox(int x, int y, int w, int h) {
    if (w < 2 || h < 2) return;
    write(x, y, '+${'-' * (w - 2)}+');
    for (var i = 1; i < h - 1; i++) {
      write(x, y + i, '|${' ' * (w - 2)}|');
    }
    write(x, y + h - 1, '+${'-' * (w - 2)}+');
  }

  /// Representação final com quebras de linha.
  @override
  String toString() => _lines.join('\n');
}
