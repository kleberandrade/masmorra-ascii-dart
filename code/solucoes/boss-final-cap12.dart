/// Capítulo 12 - Enums e o parser de comandos
/// Boss Final 12.5 - Comando ComandoFala com argumento de frase
///
/// Implementa enums para direções, sealed classes para comandos,
/// parser robusto e sistema de fala com múltiplas palavras.

import 'dart:io';

// ══════════════════════════════════════
// ENUMS
// ══════════════════════════════════════

enum Direcao {
  norte(simbolo: '↑', id: 'n'),
  sul(simbolo: '↓', id: 's'),
  leste(simbolo: '→', id: 'l'),
  oeste(simbolo: '←', id: 'o');

  final String simbolo;
  final String id;

  const Direcao({required this.simbolo, required this.id});

  Direcao get oposta {
    switch (this) {
      case Direcao.norte:
        return Direcao.sul;
      case Direcao.sul:
        return Direcao.norte;
      case Direcao.leste:
        return Direcao.oeste;
      case Direcao.oeste:
        return Direcao.leste;
    }
  }

  static Direcao? deString(String s) {
    return switch (s.toLowerCase()) {
      'n' || 'norte' => Direcao.norte,
      's' || 'sul' => Direcao.sul,
      'l' || 'e' || 'leste' => Direcao.leste,
      'o' || 'w' || 'oeste' => Direcao.oeste,
      _ => null,
    };
  }

  @override
  String toString() => id.toUpperCase();
}

// ══════════════════════════════════════
// SEALED CLASSES - COMANDOS TIPADOS
// ══════════════════════════════════════

sealed class ComandoJogo {
  const ComandoJogo();

  String executar();
}

class ComandoMover extends ComandoJogo {
  final Direcao direcao;

  const ComandoMover(this.direcao);

  @override
  String executar() => 'Movendo para $direcao...';
}

class ComandoAtacar extends ComandoJogo {
  final String alvo;

  const ComandoAtacar(this.alvo);

  @override
  String executar() => 'Atacando $alvo!';
}

class ComandoPegar extends ComandoJogo {
  final String item;

  const ComandoPegar(this.item);

  @override
  String executar() => 'Pegando $item...';
}

class ComandoInventario extends ComandoJogo {
  const ComandoInventario();

  @override
  String executar() => 'Abrindo inventário...';
}

class ComandoOlhar extends ComandoJogo {
  const ComandoOlhar();

  @override
  String executar() => 'Observando ao seu redor...';
}

class ComandoStatus extends ComandoJogo {
  const ComandoStatus();

  @override
  String executar() => 'Mostrando status...';
}

class ComandoFala extends ComandoJogo {
  final String mensagem;

  const ComandoFala(this.mensagem);

  @override
  String executar() => 'Você disse: "$mensagem"';
}

class ComandoAjuda extends ComandoJogo {
  const ComandoAjuda();

  @override
  String executar() =>
      'Comandos: norte, sul, leste, oeste, atacar, pegar, inv, status, olhar, falar, ajuda, sair';
}

class ComandoSair extends ComandoJogo {
  const ComandoSair();

  @override
  String executar() => 'Até logo!';
}

class ComandoDesconhecido extends ComandoJogo {
  final String entrada;

  const ComandoDesconhecido(this.entrada);

  @override
  String executar() => 'Não entendo "$entrada". Digite "ajuda".';
}

// ══════════════════════════════════════
// PARSER
// ══════════════════════════════════════

ComandoJogo analisarLinha(String entrada) {
  final linha = entrada.trim();

  if (linha.isEmpty) {
    return const ComandoDesconhecido('(vazio)');
  }

  // Verifica se começa com "falar" e captura tudo depois como mensagem
  if (linha.toLowerCase().startsWith('falar ')) {
    final mensagem = linha.substring(6).trim();
    if (mensagem.isEmpty) {
      return const ComandoDesconhecido('falar o quê?');
    }
    return ComandoFala(mensagem);
  }

  final palavras = linha.split(RegExp(r'\s+'));
  final verbo = palavras[0].toLowerCase();
  final args = palavras.length > 1 ? palavras.sublist(1) : [];

  switch (verbo) {
    case 'n' || 'norte':
      return const ComandoMover(Direcao.norte);

    case 's' || 'sul':
      return const ComandoMover(Direcao.sul);

    case 'l' || 'e' || 'leste':
      return const ComandoMover(Direcao.leste);

    case 'o' || 'w' || 'oeste':
      return const ComandoMover(Direcao.oeste);

    case 'atacar' || 'a':
      if (args.isEmpty) {
        return const ComandoDesconhecido('atacar o quê?');
      }
      return ComandoAtacar(args.join(' '));

    case 'pegar' || 'p':
      if (args.isEmpty) {
        return const ComandoDesconhecido('pegar o quê?');
      }
      return ComandoPegar(args.join(' '));

    case 'inventario' || 'inv' || 'i':
      return const ComandoInventario();

    case 'olhar' || 'ver' || 'l':
      return const ComandoOlhar();

    case 'status':
      return const ComandoStatus();

    case 'falar':
      return const ComandoDesconhecido('falar o quê? Use: falar [mensagem]');

    case 'ajuda' || 'help' || '?':
      return const ComandoAjuda();

    case 'sair' || 'quit' || 'exit':
      return const ComandoSair();

    default:
      return ComandoDesconhecido(entrada);
  }
}

// ══════════════════════════════════════
// LOOP DO JOGO
// ══════════════════════════════════════

class LoopJogo {
  var turno = 0;

  void processarComando(ComandoJogo cmd) {
    print('');
    switch (cmd) {
      case ComandoMover(:final direcao):
        print('▶️  ${cmd.executar()}');
        print('   Você se move para ${direcao.simbolo}...');

      case ComandoAtacar(:final alvo):
        print('⚔️  ${cmd.executar()}');
        print('   Você desfere um golpe em $alvo!');

      case ComandoPegar(:final item):
        print('🎯 ${cmd.executar()}');
        print('   Você pegou $item do chão.');

      case ComandoInventario():
        print('📦 ${cmd.executar()}');
        print('   Você está carregando: espada, escudo, poção');

      case ComandoOlhar():
        print('👁️  ${cmd.executar()}');
        print('   Você vê uma sala escura com vários itens.');

      case ComandoStatus():
        print('📊 ${cmd.executar()}');
        print('   Aventureiro - HP: 100/100 - XP: 0');

      case ComandoFala(:final mensagem):
        print('💬 ${cmd.executar()}');
        print('   Você grita: "$mensagem"');
        print('   Um eco retorna: "$mensagem"');

      case ComandoAjuda():
        print('ℹ️  ${cmd.executar()}');

      case ComandoSair():
        print('🚪 ${cmd.executar()}');

      case ComandoDesconhecido(:final entrada):
        print('❌ ${cmd.executar()}');
    }
    print('');
  }

  void executar() {
    print('');
    print('╔═══════════════════════════════════╗');
    print('║ MASMORRA ASCII - Parser de Comandos║');
    print('║      com Enums e Sealed Classes    ║');
    print('╚═══════════════════════════════════╝');
    print('');
    print('Digite "ajuda" para ver comandos.');
    print('Digite "sair" para encerrar.\n');

    while (true) {
      turno++;
      stdout.write('Turno $turno > ');
      var entrada = stdin.readLineSync() ?? '';

      final cmd = analisarLinha(entrada);
      processarComando(cmd);

      if (cmd is ComandoSair) {
        break;
      }
    }

    print('Até a próxima aventura! Durou $turno turnos.');
  }
}

// ══════════════════════════════════════
// TESTE DO PARSER
// ══════════════════════════════════════

void testarParser() {
  print('\n═══════════════════════════════════');
  print('   TESTE DO PARSER');
  print('═══════════════════════════════════\n');

  final testes = [
    'n',
    'norte',
    'atacar zumbi',
    'pegar tocha',
    'inv',
    'falar Olá, mundo!',
    'falar Qual é o seu nome?',
    'ajuda',
    'comando_invalido',
  ];

  for (final teste in testes) {
    final cmd = analisarLinha(teste);
    print('Input: "$teste"');
    print('Resultado: ${cmd.runtimeType.toString()}');
    print('Executar: ${cmd.executar()}');
    print('');
  }
}

// ══════════════════════════════════════
// MAIN
// ══════════════════════════════════════

void main(List<String> args) {
  if (args.contains('--teste')) {
    testarParser();
  } else {
    final loop = LoopJogo();
    loop.executar();
  }
}
