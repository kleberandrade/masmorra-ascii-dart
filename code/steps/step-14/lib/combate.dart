import 'dart:io';
import 'dart:math';
import 'jogador.dart';
import 'inimigo.dart';

class Combate {
  final Jogador jogador;
  final Inimigo inimigo;
  final List<String> log = [];

  int turno = 0;
  bool defesaAtiva = false;

  Combate({required this.jogador, required this.inimigo});

  void _registrar(String mensagem) {
    log.add(mensagem);
    // ignore: avoid_print
    print(mensagem);
  }

  void mostrarStatus() {
    final barraJogador = _construirBarra(jogador.hp, jogador.maxHp);
    final barraInimigo = _construirBarra(inimigo.hp, inimigo.maxHp);

    // ignore: avoid_print
    print('\n╔════════════════════════════════════╗');
    // ignore: avoid_print
    print('║           ⚔ COMBATE ⚔           ║');
    // ignore: avoid_print
    print('╠════════════════════════════════════╣');
    // ignore: avoid_print
    print('║ ${jogador.nome.padRight(15)} vs ${inimigo.nome.padRight(16)} ║');
    // ignore: avoid_print
    print('║ $barraJogador $barraInimigo ║');
    // ignore: avoid_print
    print(
      '${'║ HP: ${jogador.hp}/${jogador.maxHp}'.padRight(19)}'
      '${' HP: ${inimigo.hp}/${inimigo.maxHp}'.padRight(18)}║',
    );
    // ignore: avoid_print
    print(
      '${'║ Ataque: ${jogador.danoTotal}'.padRight(15)}'
      '${' Ataque: ${inimigo.danoBase}'.padRight(18)}║',
    );
    // ignore: avoid_print
    print('╚════════════════════════════════════╝\n');
  }

  String _construirBarra(int hpAtual, int hpMax) {
    const total = 10;
    final blocos = ((hpAtual / hpMax) * total).toInt();
    final cheios = '█' * blocos;
    final vazios = '░' * (total - blocos);
    return '$cheios$vazios';
  }

  bool atacar() {
    final random = Random();
    final variacao = (jogador.danoTotal * 0.2).toInt();
    final dano =
        jogador.danoTotal - variacao + random.nextInt(variacao * 2 + 1);

    _registrar('> ${jogador.nome} ataca! Dano: $dano');

    inimigo.sofrerDano(dano);
    if (!inimigo.estaVivo) {
      _registrar('${inimigo.nome} foi derrotado!');
      return true;
    }

    defesaAtiva = false;
    return false;
  }

  bool defender() {
    defesaAtiva = true;
    _registrar('> ${jogador.nome} assume posição defensiva!');
    return false;
  }

  bool fugir() {
    final random = Random();
    if (random.nextDouble() < 0.4) {
      _registrar('${jogador.nome} conseguiu fugir!');
      return true;
    } else {
      _registrar('${jogador.nome} não conseguiu escapar!');
      return false;
    }
  }

  bool usarItem(int indice) {
    if (indice < 0 || indice >= jogador.inventario.length) {
      _registrar('Item inválido!');
      return false;
    }

    final item = jogador.inventario[indice];
    if (item.id == 'pocao-vida') {
      final cura = 20;
      final hpAnterior = jogador.hp;
      jogador.curar(cura);
      final curaReal = jogador.hp - hpAnterior;

      _registrar('> ${jogador.nome} usa poção e recupera $curaReal HP!');
      jogador.removerItemEm(indice);
      return false;
    }

    _registrar('Não podes usar isso em combate!');
    return false;
  }

  void turnoDoInimigo() {
    final dano = inimigo.calcularDano();

    int danoFinal = dano;
    if (defesaAtiva) {
      danoFinal = (dano * 0.6).toInt();
      _registrar('> ${inimigo.nome} ataca, mas a defesa reduz o impacto!');
    } else {
      _registrar('> ${inimigo.nome} contra-ataca! Dano: $danoFinal');
    }

    jogador.sofrerDano(danoFinal);

    if (!jogador.estaVivo) {
      _registrar('${jogador.nome} foi derrotado...');
    }

    defesaAtiva = false;
  }

  void executar() {
    turno = 0;
    mostrarStatus();

    while (jogador.estaVivo && inimigo.estaVivo) {
      turno++;
      // ignore: avoid_print
      print('\n--- TURNO $turno ---');

      // ignore: avoid_print
      print('\nOpções: (1)Atacar (2)Defender (3)Fugir (4)Usar item');
      // ignore: avoid_print
      stdout.write('Escolha: ');
      final entrada =
          stdin.readLineSync() ?? '1'; // ignore: avoid_print,io

      bool combateAcabou = false;

      switch (entrada.trim()) {
        case '1':
          combateAcabou = atacar();
          break;
        case '2':
          defender();
          break;
        case '3':
          combateAcabou = fugir();
          if (combateAcabou) {
            _registrar('Você fugiu do combate.');
            return;
          }
          break;
        case '4':
          // ignore: avoid_print
          print('Qual item? (0-${jogador.inventario.length - 1}): ');
          final indiceStr = stdin.readLineSync() ?? '0'; // ignore: io
          usarItem(int.tryParse(indiceStr) ?? 0);
          break;
        default:
          _registrar('Ação desconhecida!');
          continue;
      }

      if (combateAcabou && !inimigo.estaVivo) {
        break;
      }

      if (inimigo.estaVivo) {
        turnoDoInimigo();
      }

      if (!jogador.estaVivo) {
        _registrar('\n[DERROTA] Você caiu em combate.');
        _exibirGameOver();
        return;
      }

      mostrarStatus();
    }

    if (inimigo.estaVivo == false) {
      _exibirVitoria();
    }
  }

  void _exibirVitoria() {
    _registrar('\n[VITÓRIA] Você venceu o combate!');
    final ouroGanho = inimigo.calcularOuroDrop();
    final xpGanho = inimigo.calcularXPDrop();

    jogador.receberOuro(ouroGanho);
    jogador.xp += xpGanho;

    _registrar('Você ganhou $ouroGanho ouro e $xpGanho XP!');

    if (Random().nextDouble() < 0.3) {
      final item = inimigo.gerarLoot();
      if (item != null) {
        jogador.adicionarItem(item);
        _registrar('Você encontrou: ${item.nome}!');
      }
    }

    // ignore: avoid_print
    print('\n╔════════════════════════════════════╗');
    // ignore: avoid_print
    print('║         [VITÓRIA] Você venceu o combate!          ║');
    // ignore: avoid_print
    print('╠════════════════════════════════════╣');
    // ignore: avoid_print
    print('${'║ Ouro: +$ouroGanho'.padRight(38)}║');
    // ignore: avoid_print
    print('${'║ XP: +$xpGanho'.padRight(38)}║');
    // ignore: avoid_print
    print('╚════════════════════════════════════╝\n');
  }

  void _exibirGameOver() {
    // ignore: avoid_print
    print('\n╔════════════════════════════════════╗');
    // ignore: avoid_print
    print('║       [GAME OVER]                  ║');
    // ignore: avoid_print
    print('╠════════════════════════════════════╣');
    // ignore: avoid_print
    print('║ Você caiu em combate.              ║');
    // ignore: avoid_print
    print('${'║ Durou $turno turnos de glória.'.padRight(36)}║');
    // ignore: avoid_print
    print('╚════════════════════════════════════╝\n');
  }

  void mostrarLog() {
    // ignore: avoid_print
    print('\n=== LOG DE COMBATE ===');
    for (final msg in log) {
      // ignore: avoid_print
      print(msg);
    }
  }
}
