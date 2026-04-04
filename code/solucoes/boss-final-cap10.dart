/// Capítulo 10 - Herança: a família dos inimigos
/// Boss Final 10.6 - Integrar combate ao game loop
///
/// Sistema completo com Jogador, Inimigos, Salas e loop de combate por turnos.
/// Demonstra herança, polimorfismo e integração de combate no jogo principal.

import 'dart:io';
import 'dart:math';

// ══════════════════════════════════════
// CLASSE JOGADOR
// ══════════════════════════════════════

class Jogador {
  String nome;
  int hp;
  int maxHp;
  int ataque;

  Jogador({
    required this.nome,
    this.hp = 100,
    this.maxHp = 100,
    this.ataque = 8,
  });

  void sofrerDano(int dano) {
    hp -= dano;
    if (hp < 0) hp = 0;
  }

  void curar(int quantidade) {
    hp += quantidade;
    if (hp > maxHp) hp = maxHp;
  }

  bool get estaVivo => hp > 0;

  String construirBarra() {
    const totalBlocos = 15;
    final blocos = ((hp / maxHp) * totalBlocos).toInt();
    final cheios = '█' * blocos;
    final vazios = '░' * (totalBlocos - blocos);
    return '$cheios$vazios $hp/$maxHp';
  }

  @override
  String toString() => 'Jogador($nome, HP: ${construirBarra()}, Atq: $ataque)';
}

// ══════════════════════════════════════
// CLASSE INIMIGO (ABSTRATA)
// ══════════════════════════════════════

abstract class Inimigo {
  final String nome;
  final String simbolo;
  int hp;
  final int maxHp;
  final int ataque;
  final String descricao;

  Inimigo({
    required this.nome,
    required this.simbolo,
    required this.hp,
    required this.maxHp,
    required this.ataque,
    required this.descricao,
  });

  void sofrerDano(int dano) {
    hp -= dano;
    if (hp < 0) hp = 0;
  }

  bool get estaVivo => hp > 0;

  String construirBarra() {
    const totalBlocos = 15;
    final blocos = ((hp / maxHp) * totalBlocos).toInt();
    final cheios = '█' * blocos;
    final vazios = '░' * (totalBlocos - blocos);
    return '$cheios$vazios $hp/$maxHp';
  }

  String descreverAcao();

  @override
  String toString() => '$nome [$simbolo] - HP: ${construirBarra()}';
}

// ══════════════════════════════════════
// INIMIGOS CONCRETOS
// ══════════════════════════════════════

class Zumbi extends Inimigo {
  Zumbi()
      : super(
          nome: 'Zumbi Pilhador',
          simbolo: 'Z',
          hp: 30,
          maxHp: 30,
          ataque: 6,
          descricao: 'Uma criatura de decomposição e vontade de carne.',
        );

  @override
  String descreverAcao() => 'O Zumbi grunhe e avança ferozmente!';
}

class Esqueleto extends Inimigo {
  Esqueleto()
      : super(
          nome: 'Esqueleto Antigo',
          simbolo: 'E',
          hp: 25,
          maxHp: 25,
          ataque: 7,
          descricao: 'Ossos antigos, alma presa. Rangem a cada passo.',
        );

  @override
  String descreverAcao() => 'O Esqueleto levanta sua adaga óssea!';
}

class Lobo extends Inimigo {
  Lobo()
      : super(
          nome: 'Lobo Selvagem',
          simbolo: 'L',
          hp: 20,
          maxHp: 20,
          ataque: 5,
          descricao: 'Uma criatura selvagem de garras afiadas.',
        );

  @override
  String descreverAcao() => 'O Lobo rosna ameaçadoramente!';
}

// ══════════════════════════════════════
// CLASSE SALA
// ══════════════════════════════════════

class Sala {
  final String id;
  final String nome;
  final String descricao;
  final Map<String, String> saidas;
  final List<String> itens;
  Inimigo? inimigoPresente;

  Sala({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.saidas,
    List<String>? itens,
    this.inimigoPresente,
  }) : itens = itens ?? [];

  @override
  String toString() => '$nome ($id)';
}

// ══════════════════════════════════════
// SISTEMA DE COMBATE
// ══════════════════════════════════════

class Combate {
  final Jogador jogador;
  final Inimigo inimigo;
  int turno = 0;
  final Random random = Random();

  Combate({required this.jogador, required this.inimigo});

  void mostrarStatus() {
    print('\n⚔️  COMBATE ⚔️');
    print('${jogador.nome.padRight(20)} vs ${inimigo.nome}');
    print('${jogador.construirBarra().padRight(40)} ${inimigo.construirBarra()}');
    print('');
  }

  void atacar() {
    final variacao = (jogador.ataque * 0.2).toInt();
    final dano = jogador.ataque - variacao + random.nextInt(variacao * 2);

    print('⚔️  ${jogador.nome} ataca! Dano: $dano');
    inimigo.sofrerDano(dano);

    if (!inimigo.estaVivo) {
      print('💀 ${inimigo.nome} foi derrotado!');
    }
  }

  void turnoInimigo() {
    if (!inimigo.estaVivo) return;

    final variacao = (inimigo.ataque * 0.2).toInt();
    final dano = inimigo.ataque - variacao + random.nextInt(variacao * 2);

    print('⚔️  ${inimigo.descreverAcao()} Dano: $dano');
    jogador.sofrerDano(dano);

    if (!jogador.estaVivo) {
      print('💀 ${jogador.nome} foi derrotado...');
    }
  }

  void executar() {
    print('\n═══════════════════════════════════');
    print('Um ${inimigo.nome} [$simbolo] está aqui!');
    print('═══════════════════════════════════');

    while (jogador.estaVivo && inimigo.estaVivo) {
      turno++;
      mostrarStatus();

      print('Opções:');
      print('1 - Atacar');
      print('2 - Defender (reduz dano em 50%)');
      print('3 - Fugir (40% de chance)');
      print('');

      stdout.write('Sua escolha (1-3): ');
      var escolha = stdin.readLineSync() ?? '1';

      switch (escolha.trim()) {
        case '1':
          atacar();
          break;
        case '2':
          print('🛡️  ${jogador.nome} assume posição defensiva!');
          break;
        case '3':
          if (random.nextDouble() < 0.4) {
            print('✈️  ${jogador.nome} conseguiu fugir!');
            return;
          } else {
            print('❌ Não conseguiu escapar!');
          }
          break;
        default:
          print('Ação desconhecida!');
          continue;
      }

      if (inimigo.estaVivo) {
        turnoInimigo();
      }
    }

    if (jogador.estaVivo) {
      print('\n🎉 [VITÓRIA] Você venceu o combate!');
      print('Ganhou 50 XP e 20 ouro!');
    } else {
      print('\n💀 [DERROTA] Você caiu em combate...');
      print('[GAME OVER]');
    }
  }

  String get simbolo => inimigo.simbolo;
}

// ══════════════════════════════════════
// CRIAÇÃO DO MUNDO
// ══════════════════════════════════════

Map<String, Sala> criarMundo() {
  return {
    'praca': Sala(
      id: 'praca',
      nome: 'Praça Central',
      descricao: 'Uma fonte de pedra murmura. Tochas iluminam passagens.',
      saidas: {
        'norte': 'taverna',
        'leste': 'mercado',
      },
      itens: ['Tocha'],
      inimigoPresente: null,
    ),
    'taverna': Sala(
      id: 'taverna',
      nome: 'Taverna do Galo Bravo',
      descricao: 'Fumo, som de risadas e cheiro de cerveja.',
      saidas: {
        'sul': 'praca',
        'norte': 'floresta',
      },
      itens: ['Poção de Vida'],
      inimigoPresente: Zumbi(),
    ),
    'mercado': Sala(
      id: 'mercado',
      nome: 'Mercado da Vila',
      descricao: 'Bancas de comida, armas e poções.',
      saidas: {
        'oeste': 'praca',
        'norte': 'cripta',
      },
      itens: ['Moeda de Ouro', 'Pão'],
      inimigoPresente: null,
    ),
    'floresta': Sala(
      id: 'floresta',
      nome: 'Floresta Escura',
      descricao: 'Árvores altas e sons estranhos na escuridão.',
      saidas: {
        'sul': 'taverna',
      },
      itens: [],
      inimigoPresente: Lobo(),
    ),
    'cripta': Sala(
      id: 'cripta',
      nome: 'Cripta Antiga',
      descricao: 'Lápides rotas e silêncio assustador.',
      saidas: {
        'sul': 'mercado',
      },
      itens: [],
      inimigoPresente: Esqueleto(),
    ),
  };
}

// ══════════════════════════════════════
// ESTADO DO JOGO
// ══════════════════════════════════════

late Map<String, Sala> mundo;
late Jogador jogador;
var salaAtual = 'praca';
var turno = 0;

// ══════════════════════════════════════
// FUNÇÕES DO JOGO
// ══════════════════════════════════════

void exibirSala() {
  final sala = mundo[salaAtual]!;

  print('\n═══════════════════════════════════');
  print(sala.nome.toUpperCase());
  print('═══════════════════════════════════');
  print(sala.descricao);
  print('');

  if (sala.inimigoPresente != null) {
    final ini = sala.inimigoPresente!;
    print('⚠️  Um ${ini.nome} [${ini.simbolo}] está aqui!');
    print('   ${ini.construirBarra()}');
  }

  if (sala.itens.isNotEmpty) {
    print('📦 No chão: ${sala.itens.join(", ")}');
  }

  final saidasTexto = sala.saidas.keys.map((d) => '[$d]').join(' ');
  print('🚪 Saídas: $saidasTexto');
  print('');
}

void mover(String direcao) {
  final sala = mundo[salaAtual]!;

  if (!sala.saidas.containsKey(direcao)) {
    print('❌ Não há saída para $direcao.');
    return;
  }

  salaAtual = sala.saidas[direcao]!;
  turno++;
  print('Você vai para $direcao...');
  exibirSala();

  final novaSala = mundo[salaAtual]!;
  if (novaSala.inimigoPresente != null && novaSala.inimigoPresente!.estaVivo) {
    stdout.write('\nDeseja combater? (s/n): ');
    var resposta = stdin.readLineSync() ?? 's';
    if (resposta.toLowerCase() == 's') {
      final combate = Combate(jogador: jogador, inimigo: novaSala.inimigoPresente!);
      combate.executar();

      if (!jogador.estaVivo) {
        print('\n[JOGO ENCERRADO]');
        exit(0);
      }
    }
  }
}

void exibirStatus() {
  print('\n📊 STATUS:');
  print('   ${jogador.toString()}');
  print('   Sala: ${mundo[salaAtual]!.nome}');
  print('   Turno: $turno');
  print('');
}

// ══════════════════════════════════════
// GAME LOOP
// ══════════════════════════════════════

void main() {
  mundo = criarMundo();
  jogador = Jogador(nome: 'Aldric', maxHp: 100, hp: 100, ataque: 8);

  print('');
  print('╔════════════════════════════════════╗');
  print('║   MASMORRA ASCII - Sistema Completo ║');
  print('║       com Herança e Combate         ║');
  print('╚════════════════════════════════════╝');
  print('');
  print('Bem-vindo, ${jogador.nome}!');
  print('');

  exibirSala();

  while (true) {
    stdout.write('> ');
    var input = (stdin.readLineSync() ?? '').trim().toLowerCase();

    if (input.isEmpty) continue;

    var partes = input.split(' ');
    var cmd = partes[0];

    switch (cmd) {
      case 'norte' || 'n':
        mover('norte');

      case 'sul' || 's':
        mover('sul');

      case 'leste' || 'l':
        mover('leste');

      case 'oeste' || 'o':
        mover('oeste');

      case 'status':
        exibirStatus();

      case 'olhar':
        exibirSala();

      case 'combate':
        final sala = mundo[salaAtual]!;
        if (sala.inimigoPresente != null && sala.inimigoPresente!.estaVivo) {
          final combate =
              Combate(jogador: jogador, inimigo: sala.inimigoPresente!);
          combate.executar();
          if (!jogador.estaVivo) {
            print('\n[JOGO ENCERRADO]');
            return;
          }
        } else {
          print('❌ Não há inimigos aqui.');
        }

      case 'sair' || 'quit':
        print('');
        print('Até logo, ${jogador.nome}!');
        print('Durou $turno turnos. HP final: ${jogador.hp}/${jogador.maxHp}');
        return;

      default:
        print('❌ Comando desconhecido: "$cmd"');
    }
  }
}
