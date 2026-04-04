// Capítulo 16 - Boss Final: Números Flutuantes (Feedback Animado)
// Descrição: Quando o jogador coleta ouro, um "+50g" aparece na posição
// e flutua para cima durante 3 frames, desaparecendo depois.

import 'dart:io';

class NumeroFlutante {
  int x;
  int y;
  String numero;
  int frame;
  int duracaoFrames;

  NumeroFlutante({
    required this.x,
    required this.y,
    required this.numero,
    this.frame = 0,
    this.duracaoFrames = 3,
  });

  bool estaVivo() => frame < duracaoFrames;

  void atualizarFrame() {
    frame++;
    y--; // Flutua para cima a cada frame
  }

  @override
  String toString() => '$numero em ($x, $y) [frame $frame/$duracaoFrames]';
}

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
    if (x < 0 || x >= largura || y < 0 || y >= altura) {
      return;
    }
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
    stdout.write('\x1B[2J\x1B[H'); // Limpar tela ANSI

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

class GerenciadorNumerosFlutantes {
  final List<NumeroFlutante> numeros = [];

  void adicionarNumero(int x, int y, String valor) {
    numeros.add(NumeroFlutante(
      x: x,
      y: y,
      numero: valor,
    ));
  }

  void atualizarTodos() {
    // Atualizar e remover números mortos
    for (final numero in numeros) {
      if (numero.estaVivo()) {
        numero.atualizarFrame();
      }
    }
    // Limpar números que expiraram
    numeros.removeWhere((n) => !n.estaVivo());
  }

  void renderizarNaTela(TelaAscii tela) {
    for (final numero in numeros) {
      if (numero.estaVivo()) {
        tela.desenharString(numero.x, numero.y, numero.numero);
      }
    }
  }

  void depurar() {
    print('Números flutuantes ativos: ${numeros.length}');
    for (final numero in numeros) {
      print('  ${numero}');
    }
  }
}

void main() {
  print('=== Boss Final Cap 16: Números Flutuantes ===\n');

  final tela = TelaAscii(largura: 40, altura: 15);
  final gerenciador = GerenciadorNumerosFlutantes();

  // Simular 5 frames de animação
  print('Adicionando números flutuantes...');
  gerenciador.adicionarNumero(10, 10, '+50g');
  gerenciador.adicionarNumero(15, 10, '+25hp');
  gerenciador.adicionarNumero(20, 10, '-10dano');

  for (int frameAtual = 0; frameAtual < 5; frameAtual++) {
    print('\nFrame $frameAtual:');
    tela.limpar();

    // Desenhar piso simulado
    for (int x = 5; x < 35; x++) {
      tela.desenharChar(x, 12, '.');
    }

    // Atualizar e renderizar números
    if (frameAtual > 0) {
      gerenciador.atualizarTodos();
    }

    gerenciador.renderizarNaTela(tela);
    tela.renderizar();

    gerenciador.depurar();

    sleep(Duration(milliseconds: 500));
  }

  print('\n✓ Demonstração completa: números flutuaram e desapareceram!\n');
}
