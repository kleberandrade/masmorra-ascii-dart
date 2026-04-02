import 'dart:io';

class TelaAscii {
  final int largura;
  final int altura;
  late List<List<String>> _buffer;

  TelaAscii({required this.largura, required this.altura}) {
    _inicializarBuffer();
  }

  void _inicializarBuffer() {
    _buffer = List<List<String>>.generate(
      altura,
      (y) => List<String>.generate(largura, (x) => ' '),
    );
  }

  void limpar() {
    for (int y = 0; y < altura; y++) {
      for (int x = 0; x < largura; x++) {
        _buffer[y][x] = ' ';
      }
    }
  }

  void desenharChar(int x, int y, String char) {
    if (x < 0 || x >= largura || y < 0 || y >= altura) return;
    _buffer[y][x] = char;
  }

  void desenharString(int x, int y, String texto) {
    for (int i = 0; i < texto.length; i++) {
      final charX = x + i;
      if (charX >= largura) break;
      desenharChar(charX, y, texto[i]);
    }
  }

  void renderizar() {
    stdout.write('\x1B[2J\x1B[H');
    final sb = StringBuffer();
    for (int y = 0; y < altura; y++) {
      for (int x = 0; x < largura; x++) {
        sb.write(_buffer[y][x]);
      }
      sb.write('\n');
    }
    stdout.write(sb.toString());
  }
}
