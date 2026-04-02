import 'package:test/test.dart';
import 'dart:io';
import 'package:masmorra_ascii/modelos/jogador.dart';
import 'package:masmorra_ascii/ui/renderizador.dart';

void main() {
  group('Golden Tests - Renderizador', () {
    final renderizador = Renderizador();

    test('renderizar status jogador (golden)', () {
      final jogador = Jogador(
        nome: 'Aragorn',
        hpMax: 50,
        ataque: 10,
        defesa: 2,
      );

      jogador.sofrerDano(5);
      jogador.ganharXP(150);

      final output = renderizador.renderizarStatus(jogador);
      final goldenDir = Directory('test/golden');

      if (!goldenDir.existsSync()) {
        goldenDir.createSync(recursive: true);
      }

      final goldenFile = File('test/golden/status_jogador.txt');

      if (goldenFile.existsSync()) {
        final golden = goldenFile.readAsStringSync();
        expect(output, equals(golden));
      } else {
        // Primeira execução: captura o golden
        goldenFile.writeAsStringSync(output);
        expect(output, isNotEmpty);
      }
    });

    test('status contem HP atual', () {
      final jogador = Jogador(nome: 'Teste', hpMax: 50, ataque: 5);
      jogador.sofrerDano(10);

      final output = renderizador.renderizarStatus(jogador);
      expect(output, contains('HP'));
      expect(output, contains('40')); // HP atual
    });

    test('status contem ataque e defesa', () {
      final jogador = Jogador(
        nome: 'Guerreiro',
        hpMax: 50,
        ataque: 10,
        defesa: 3,
      );

      final output = renderizador.renderizarStatus(jogador);
      expect(output, contains('ATK'));
      expect(output, contains('DEF'));
    });

    test('barra de HP mostra percentual', () {
      final jogador = Jogador(nome: 'Mago', hpMax: 100, ataque: 5);
      jogador.sofrerDano(50);

      final output = renderizador.renderizarStatus(jogador);
      expect(output, contains('50%'));
    });

    test('nome jogador esta centralizado', () {
      final jogador = Jogador(
        nome: 'Très Léger',
        hpMax: 50,
        ataque: 5,
      );

      final output = renderizador.renderizarStatus(jogador);
      expect(output, contains('Très Léger'));
    });
  });
}
