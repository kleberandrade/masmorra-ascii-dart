import 'package:test/test.dart';
import 'dart:io';
import 'dart:convert';
import 'package:masmorra_ascii/modelos/jogador.dart';
import 'package:masmorra_ascii/persistencia/gerenciador_salve.dart';

void main() {
  group('GerenciadorSalve', () {
    const String dirTeste = 'test_salves';

    setUpAll(() async {
      // Cria diretório temporário para testes
      final dir = Directory(dirTeste);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
      dir.createSync(recursive: true);
    });

    tearDownAll(() async {
      // Limpa diretório de teste
      final dir = Directory(dirTeste);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    });

    test('inicializar cria diretório', () async {
      final dir = Directory(dirTeste);
      expect(dir.existsSync(), isTrue);
    });

    test('salvar jogador em JSON', () async {
      final jogador = Jogador(
        nome: 'Heroi',
        hpMax: 50,
        ataque: 10,
        nivel: 2,
        xp: 150,
      );

      final arquivo = File('$dirTeste/salve_0.json');
      final json = jsonEncode({
        'jogador': jogador.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      await arquivo.writeAsString(json);
      expect(arquivo.existsSync(), isTrue);
    });

    test('carregar jogador de JSON', () async {
      final jogador = Jogador(
        nome: 'Guerreiro',
        hpMax: 60,
        ataque: 12,
        defesa: 2,
        nivel: 3,
        xp: 250,
      );

      final arquivo = File('$dirTeste/salve_1.json');
      final json = jsonEncode({
        'jogador': jogador.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      await arquivo.writeAsString(json);

      final conteudo = await arquivo.readAsString();
      final map = jsonDecode(conteudo) as Map<String, dynamic>;
      final carregado = Jogador.fromJson(
          map['jogador'] as Map<String, dynamic>);

      expect(carregado.nome, equals('Guerreiro'));
      expect(carregado.hpMax, equals(60));
      expect(carregado.ataque, equals(12));
      expect(carregado.nivel, equals(3));
    });

    test('toJson contem todos os atributos', () {
      final jogador = Jogador(
        nome: 'Mago',
        hpMax: 40,
        ataque: 8,
        defesa: 1,
        nivel: 2,
        xp: 100,
      );

      final json = jogador.toJson();

      expect(json.containsKey('nome'), isTrue);
      expect(json.containsKey('hpMax'), isTrue);
      expect(json.containsKey('hpAtual'), isTrue);
      expect(json.containsKey('ataque'), isTrue);
      expect(json.containsKey('defesa'), isTrue);
      expect(json.containsKey('nivel'), isTrue);
      expect(json.containsKey('xp'), isTrue);
      expect(json.containsKey('inventario'), isTrue);
    });

    test('fromJson restaura estado completo', () {
      final original = Jogador(
        nome: 'Paladin',
        hpMax: 70,
        ataque: 15,
        defesa: 3,
        nivel: 4,
        xp: 400,
      );

      original.adicionarItem('Espada');
      original.adicionarItem('Escudo');

      final restaurado = Jogador.fromJson(original.toJson());

      expect(restaurado.nome, equals(original.nome));
      expect(restaurado.hpMax, equals(original.hpMax));
      expect(restaurado.hpAtual, equals(original.hpAtual));
      expect(restaurado.ataque, equals(original.ataque));
      expect(restaurado.defesa, equals(original.defesa));
      expect(restaurado.nivel, equals(original.nivel));
      expect(restaurado.xp, equals(original.xp));
      expect(restaurado.inventario.length, equals(2));
      expect(restaurado.inventario, contains('Espada'));
    });

    test('fromJson com JSON minimo', () {
      final minimo = {
        'nome': 'Novo',
        'hpMax': 50,
        'ataque': 5,
        'defesa': 1,
        'nivel': 1,
        'xp': 0,
        'inventario': [],
      };

      final jogador = Jogador.fromJson(minimo);
      expect(jogador.nome, equals('Novo'));
      expect(jogador.inventario, isEmpty);
    });

    test('json roundtrip preserva estado', () {
      final original = Jogador(
        nome: 'Cleric',
        hpMax: 55,
        ataque: 7,
        defesa: 2,
        nivel: 3,
        xp: 300,
      );

      original.sofrerDano(10);
      original.adicionarItem('Pocao');

      final json = original.toJson();
      final restaurado = Jogador.fromJson(json);

      expect(restaurado.hpAtual, equals(original.hpAtual));
      expect(restaurado.inventario, equals(original.inventario));
    });
  });
}
