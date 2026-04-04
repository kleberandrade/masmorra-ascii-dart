/// Capítulo 32 - Organização de Projeto: lib/, test/, pubspec.yaml
/// Boss Final 32.5: Pronto para Produção
///
/// Demonstra a estrutura profissional de um projeto Dart com:
/// - Organização em diretórios temáticos
/// - Separação entre código (lib/) e testes (test/)
/// - Configuração via pubspec.yaml
/// - Análise estática com analysis_options.yaml
/// - Importações corretas (relativos em lib, package: em test)

import 'dart:io';

/// Classe para representar um personagem do jogo
class Personagem {
  final String nome;
  final int nivel;
  final int experiencia;

  Personagem({
    required this.nome,
    required this.nivel,
    required this.experiencia,
  });

  @override
  String toString() => '$nome (Nível $nivel, XP $experiencia)';
}

/// Classe para gerenciar um projeto Dart profissional
class EstruturaProjeto {
  final String nomeProjeto;
  final Map<String, String> diretorios = {};

  EstruturaProjeto(this.nomeProjeto);

  /// Cria a estrutura de diretórios de um projeto Dart
  void criar() {
    print('Criando estrutura profissional para "$nomeProjeto"...\n');

    diretorios['lib'] = 'Código reutilizável e ponto de entrada';
    diretorios['lib/modelos'] = 'Classes de dados (Personagem, Item, etc)';
    diretorios['lib/ui'] = 'Renderização e interface';
    diretorios['lib/jogo'] = 'Lógica principal do jogo';
    diretorios['lib/combate'] = 'Sistema de combate';
    diretorios['lib/mundo'] = 'Mapa, dungeon, geração procedural';
    diretorios['lib/config'] = 'Constantes e configuração';
    diretorios['lib/persistencia'] = 'Save/load em JSON';
    diretorios['test'] = 'Testes automatizados';
    diretorios['test/modelos'] = 'Testes para modelos';
    diretorios['test/jogo'] = 'Testes para lógica do jogo';

    for (final (caminho, descricao) in diretorios.entries) {
      print('  📁 $caminho/');
      print('     → $descricao');
    }
  }

  /// Mostra a estrutura de arquivos criados
  void mostrarEstrutura() {
    print('\n\nArquivos de Configuração:');
    print('  📄 pubspec.yaml');
    print('     → Declaração de dependências e versão Dart');
    print('  📄 analysis_options.yaml');
    print('     → Regras de linting e qualidade');
    print('  📄 lib/main.dart');
    print('     → Ponto de entrada (função main)');
    print('  📄 README.md');
    print('     → Documentação do projeto');
  }
}

/// Demonstra a estrutura de pubspec.yaml
class PubspecYaml {
  final String nomeProjeto;
  final String versao;
  final String descricao;
  final String sdkMinimo;

  PubspecYaml({
    required this.nomeProjeto,
    this.versao = '1.0.0',
    this.descricao = 'Projeto Dart profissional',
    this.sdkMinimo = '3.11.0',
  });

  String gerar() {
    return '''
name: $nomeProjeto
description: $descricao
version: $versao
publish_to: none

environment:
  sdk: '>=$sdkMinimo <4.0.0'

dependencies:
  # Puro Dart (nenhuma por enquanto)

dev_dependencies:
  test: ^1.25.0
  lints: ^3.0.0
''';
  }
}

/// Demonstra a estrutura de analysis_options.yaml
class AnalysisOptionsYaml {
  String gerar() {
    return '''
include: package:lints/recommended.yaml

linter:
  rules:
    - camel_case_types
    - constant_identifier_names
    - empty_constructor_bodies
    - prefer_const_constructors
    - prefer_final_fields
    - prefer_null_aware_operators
    - use_key_in_widget_constructors
    - use_late_for_private_fields_and_variables
    - use_string_buffers
''';
  }
}

/// Demonstra como organizar importações em lib/
class ExemploImportos {
  /// Em lib/main.dart, use imports relativos
  void demonstrarImportosRelativosEmLib() {
    print('\n--- Importes em lib/ (relativos) ---');
    print("import 'modelos/personagem.dart';");
    print("import 'jogo/logica_jogo.dart';");
    print("import 'persistencia/gerenciador_salve.dart';");
    print('\n✓ Imports relativos são claros e simples dentro de lib/');
  }

  /// Em test/, use imports package:
  void demonstrarImportosPackageEmTest() {
    print('\n--- Imports em test/ (package:) ---');
    print("import 'package:masmorra_ascii/modelos/personagem.dart';");
    print("import 'package:masmorra_ascii/jogo/logica_jogo.dart';");
    print("import 'package:test/test.dart';");
    print('\n✓ Imports package: acessam código de lib/ a partir de test/');
  }
}

/// Demonstra um teste profissional
void demonstrarTeste() {
  print('\n--- Exemplo de Teste Profissional ---');
  print('''
// test/modelos/personagem_test.dart
import 'package:test/test.dart';
import 'package:masmorra_ascii/modelos/personagem.dart';

void main() {
  group('Testes de Personagem', () {
    test('criação básica', () {
      final hero = Personagem(nome: 'Herói', nivel: 1, experiencia: 0);
      expect(hero.nome, equals('Herói'));
      expect(hero.nivel, equals(1));
    });

    test('ganho de experiência', () {
      final hero = Personagem(nome: 'Herói', nivel: 1, experiencia: 100);
      expect(hero.experiencia, equals(100));
    });
  });
}
''');
}

void main() {
  print('╔════════════════════════════════════════════╗');
  print('║     PRONTO PARA PRODUÇÃO                  ║');
  print('║       Capítulo 32 - Boss Final             ║');
  print('╚════════════════════════════════════════════╝');
  print('');

  // Demonstra criação de estrutura
  final projeto = EstruturaProjeto('masmorra_ascii');
  projeto.criar();
  projeto.mostrarEstrutura();

  // Demonstra pubspec.yaml
  print('\n\n--- pubspec.yaml ---');
  final pubspec = PubspecYaml(
    nomeProjeto: 'masmorra_ascii',
    descricao: 'Roguelike ASCII em Dart puro',
  );
  print(pubspec.gerar());

  // Demonstra analysis_options.yaml
  print('\n--- analysis_options.yaml ---');
  final analysis = AnalysisOptionsYaml();
  print(analysis.gerar());

  // Demonstra importações
  final imports = ExemploImportos();
  imports.demonstrarImportosRelativosEmLib();
  imports.demonstrarImportosPackageEmTest();

  // Demonstra teste
  demonstrarTeste();

  // Demonstra uso do projeto
  print('\n\n--- Usando o Projeto Organizado ---');
  final heroi = Personagem(nome: 'Aventureiro', nivel: 5, experiencia: 2500);
  print('Personagem criado: $heroi');

  print('\nComandos para executar:');
  print('  $ dart lib/main.dart          # Executa o jogo');
  print('  $ dart test                   # Roda todos os testes');
  print('  $ dart analyze                # Verifica qualidade');
  print('  $ dart pub get                # Baixa dependências');

  print('\n✓ Projeto está profissional e pronto para crescer!');
}
