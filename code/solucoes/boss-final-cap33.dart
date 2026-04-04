/// Capítulo 33 - Testes Golden e HUD ASCII Polido
/// Boss Final 33.6: Progressão Cinematográfica
///
/// Implementa testes Golden que capturam a renderização ASCII da HUD
/// em diferentes momentos da progressão do jogador (nível 1, 2, 3).
/// Cada arquivo golden é um frame do filme da jornada.

import 'package:test/test.dart';
import 'dart:io';

/// Representa o estado de um personagem
class Personagem {
  String nome;
  int nivel;
  int xpAtual;
  int xpParaProximo;
  int hpAtual;
  int hpMax;
  int ataque;

  Personagem({
    required this.nome,
    required this.nivel,
    required this.xpAtual,
    required this.xpParaProximo,
    required this.hpAtual,
    required this.hpMax,
    required this.ataque,
  });

  /// Sobe um nível
  void subirNivel() {
    nivel++;
    xpAtual = 0;
    xpParaProximo = xpParaProximo + 30;
    hpMax += 10;
    hpAtual = hpMax;
    ataque += 2;
  }

  /// Ganha experiência
  void ganharXp(int xp) {
    xpAtual += xp;
    while (xpAtual >= xpParaProximo) {
      xpAtual -= xpParaProximo;
      subirNivel();
    }
  }
}

/// Renderizador que cria HUD em ASCII
class Renderizador {
  static const int largura = 60;

  /// Renderiza barra visual (█ preenchido, ░ vazio)
  String _barra(int atual, int maximo, int largura) {
    if (maximo == 0) maximo = 1;
    final preenchido = (atual / maximo * largura).toInt();
    final vazio = largura - preenchido;
    final pct = (atual / maximo * 100).toInt();
    return '█' * preenchido + '░' * vazio + ' $pct%';
  }

  /// Centraliza texto
  String _centralizar(String texto) {
    if (texto.length >= largura) return texto;
    final padding = (largura - texto.length) ~/ 2;
    return texto.padRight(padding + texto.length).padLeft(largura);
  }

  /// Renderiza a HUD completa do personagem
  String renderizar(Personagem p) {
    final buffer = StringBuffer();

    // Cabeçalho
    buffer.writeln(_centralizar('═' * (largura - 4)));
    buffer.writeln(_centralizar(p.nome));
    buffer.writeln(_centralizar('═' * (largura - 4)));

    // Linha vazia
    buffer.writeln('');

    // Nível
    buffer.writeln('Nível: ${p.nivel.toString().padRight(3)} | Ataque: ${p.ataque.toString().padRight(2)}');

    // HP
    buffer.writeln('HP: [${_barra(p.hpAtual, p.hpMax, 15)}]');

    // XP
    final percXp = (p.xpAtual / p.xpParaProximo * 100).toInt();
    buffer.writeln('XP: [${_barra(p.xpAtual, p.xpParaProximo, 15)}]');

    // Rodapé
    buffer.writeln('');
    buffer.writeln(_centralizar('─' * (largura - 4)));

    return buffer.toString();
  }
}

/// Cria ou valida arquivo golden
void criarOuValidarGolden(String nome, String conteudo) {
  final diretorio = Directory('test/golden');
  if (!diretorio.existsSync()) {
    diretorio.createSync(recursive: true);
  }

  final arquivo = File('test/golden/$nome.txt');

  if (arquivo.existsSync()) {
    final golden = arquivo.readAsStringSync();
    expect(conteudo, equals(golden),
      reason: 'Renderização diferente do golden. Verifique se foi intencional.');
  } else {
    arquivo.writeAsStringSync(conteudo);
    print('Golden criado: ${arquivo.path}');
  }
}

void main() {
  group('Golden Tests - Progressão Cinematográfica', () {
    final render = Renderizador();

    test('prog_nivel1.txt: Estado Inicial', () {
      final heroi = Personagem(
        nome: 'Aventureiro',
        nivel: 1,
        xpAtual: 0,
        xpParaProximo: 50,
        hpAtual: 30,
        hpMax: 30,
        ataque: 5,
      );

      final output = render.renderizar(heroi);
      criarOuValidarGolden('prog_nivel1', output);
    });

    test('prog_nivel1_30pct.txt: Primeira Progressão de XP', () {
      final heroi = Personagem(
        nome: 'Aventureiro',
        nivel: 1,
        xpAtual: 15,
        xpParaProximo: 50,
        hpAtual: 30,
        hpMax: 30,
        ataque: 5,
      );

      final output = render.renderizar(heroi);
      criarOuValidarGolden('prog_nivel1_30pct', output);
    });

    test('prog_sobe_nivel2.txt: Primeiro Aumento de Nível', () {
      final heroi = Personagem(
        nome: 'Aventureiro',
        nivel: 1,
        xpAtual: 45,
        xpParaProximo: 50,
        hpAtual: 30,
        hpMax: 30,
        ataque: 5,
      );

      // Ganha XP suficiente para subir
      heroi.ganharXp(10);

      final output = render.renderizar(heroi);
      criarOuValidarGolden('prog_sobe_nivel2', output);
    });

    test('prog_nivel2_50pct.txt: Progresso no Nível 2', () {
      final heroi = Personagem(
        nome: 'Aventureiro',
        nivel: 2,
        xpAtual: 40,
        xpParaProximo: 80,
        hpAtual: 40,
        hpMax: 40,
        ataque: 7,
      );

      final output = render.renderizar(heroi);
      criarOuValidarGolden('prog_nivel2_50pct', output);
    });

    test('prog_sobe_nivel3.txt: Segundo Aumento de Nível', () {
      final heroi = Personagem(
        nome: 'Aventureiro',
        nivel: 2,
        xpAtual: 70,
        xpParaProximo: 80,
        hpAtual: 40,
        hpMax: 40,
        ataque: 7,
      );

      // Ganha XP para subir
      heroi.ganharXp(20);

      final output = render.renderizar(heroi);
      criarOuValidarGolden('prog_sobe_nivel3', output);
    });

    test('prog_nivel3_completo.txt: Nível 3 Completo', () {
      final heroi = Personagem(
        nome: 'Aventureiro',
        nivel: 3,
        xpAtual: 30,
        xpParaProximo: 110,
        hpAtual: 50,
        hpMax: 50,
        ataque: 9,
      );

      final output = render.renderizar(heroi);
      criarOuValidarGolden('prog_nivel3_completo', output);
    });

    test('Verifica sequência de 5+ estados', () {
      // Este teste valida que a jornada está documentada
      final diretorios = Directory('test/golden');
      final arquivos = diretorios.listSync().whereType<File>()
        .where((f) => f.path.contains('prog_'))
        .toList();

      expect(arquivos.length, greaterThanOrEqualTo(5),
        reason: 'Deve ter pelo menos 5 arquivos golden para progressão');
    });
  });
}
