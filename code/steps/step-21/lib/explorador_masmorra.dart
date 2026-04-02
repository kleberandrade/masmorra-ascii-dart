import 'dart:io';
import 'dart:math';
import 'tile.dart';
import 'tela_ascii.dart';
import 'campo_visao.dart';
import 'entidade.dart';

class ExploradorMasmorra {
  final Jogador jogador;
  late AndarMasmorra andarAtual;
  late TelaAscii tela;

  final int larguraMapa;
  final int alturaMapa;
  final int andarFinal;

  int andarNumero = 0;
  int turno = 0;
  bool emJogo = true;
  bool vitoria = false;

  int totalInimigosDefeitos = 0;
  int maiorAndarAlcancado = 0;

  ExploradorMasmorra({
    required this.jogador,
    this.larguraMapa = 60,
    this.alturaMapa = 20,
    this.andarFinal = 3,
  }) {
    tela = TelaAscii(largura: larguraMapa, altura: alturaMapa + 5);
  }

  void gerarAndar() {
    final mapa = MapaMasmorra.gerar(
      largura: larguraMapa,
      altura: alturaMapa,
    );

    final spawner = GeradorEntidades(
      mapa: mapa,
      andarAtual: andarNumero,
    );

    andarAtual = AndarMasmorra(
      numero: andarNumero,
      mapa: mapa,
      entidades: spawner.spawn(),
    );

    // Encontrar posição inicial passável
    bool encontrou = false;
    for (int y = 1; y < alturaMapa - 1 && !encontrou; y++) {
      for (int x = 1; x < larguraMapa - 1 && !encontrou; x++) {
        if (mapa.ehPassavel(x, y)) {
          jogador.x = x;
          jogador.y = y;
          encontrou = true;
        }
      }
    }

    mapa.fov.calcularShadowcast(
      Point(jogador.x, jogador.y),
      8,
      mapa,
    );

    maiorAndarAlcancado = andarNumero;
  }

  void renderizarFrame() {
    tela.limpar();

    final mapa = andarAtual.mapa;

    // Renderizar mapa com FOV
    for (int y = 0; y < mapa.altura; y++) {
      for (int x = 0; x < mapa.largura; x++) {
        final char = tileParaChar(mapa.tileEm(x, y));

        if (mapa.fov.estaVisivel(x, y)) {
          tela.desenharChar(x, y, char);
        } else if (mapa.fov.foiExplorado(x, y)) {
          final esfum = switch (char) {
            '#' => '░',
            '.' => '·',
            '>' => '┐',
            _ => char.toLowerCase(),
          };
          tela.desenharChar(x, y, esfum);
        }
      }
    }

    // Renderizar entidades
    for (final entidade in andarAtual.entidades) {
      entidade.renderizarNaTela(tela, mapa.fov);
    }

    jogador.renderizarNaTela(tela, mapa.fov);

    _renderizarHUD();
    tela.renderizar();
  }

  void _renderizarHUD() {
    final hudY = alturaMapa + 1;
    final hpBar = _construirBarraHP();

    tela.desenharString(0, hudY, '═' * larguraMapa);
    tela.desenharString(
      0,
      hudY + 1,
      'Andar: $andarNumero | Turno: $turno | $hpBar ${jogador.hpAtual}/${jogador.hpMax}',
    );
    tela.desenharString(
      0,
      hudY + 2,
      'Ouro: ${jogador.ouro} | Inimigos: ${totalInimigosDefeitos}',
    );
    tela.desenharString(0, hudY + 3, '[W]cima [A]esq [S]baixo [D]dir [I]nventário [Q]uit');
  }

  String _construirBarraHP() {
    const blocos = 5;
    final cheios = (jogador.hpAtual / jogador.hpMax * blocos).toInt();
    final vazios = blocos - cheios;
    return '█' * cheios + '░' * vazios;
  }

  void processarComando(String comando) {
    switch (comando.toLowerCase()) {
      case 'w' || 'a' || 's' || 'd':
        _processarMovimento(comando);
      case 'i':
        _mostrarInventario();
      case 'q':
        emJogo = false;
      default:
        // Ignorar
    }
  }

  void _processarMovimento(String direcao) {
    int novoX = jogador.x;
    int novoY = jogador.y;

    switch (direcao.toLowerCase()) {
      case 'w':
        novoY--;
      case 's':
        novoY++;
      case 'a':
        novoX--;
      case 'd':
        novoX++;
    }

    final mapa = andarAtual.mapa;

    if (!mapa.ehPassavel(novoX, novoY)) {
      return;
    }

    final entidade = andarAtual.encontrarEntidadeEm(novoX, novoY);
    if (entidade != null) {
      if (entidade is EntidadeInimigo) {
        final vitoriaCombate = _executarCombate(entidade.inimigo);
        if (!vitoriaCombate) {
          jogador.hpAtual = 0;
          return;
        }
        andarAtual.removerEntidade(entidade);
        totalInimigosDefeitos++;
        jogador.ouro += 25;
      } else if (entidade is EntidadeItem) {
        entidade.aoTocada(jogador);
        andarAtual.removerEntidade(entidade);
      } else if (entidade is EntidadeEscada) {
        andarNumero++;
        if (andarNumero >= andarFinal) {
          vitoria = true;
          emJogo = false;
        } else {
          gerarAndar();
        }
        return;
      }
    }

    jogador.mover(novoX, novoY, mapa);
    turno++;

    mapa.fov.calcularShadowcast(
      Point(jogador.x, jogador.y),
      8,
      mapa,
    );
  }

  bool _executarCombate(Inimigo inimigo) {
    // Simplificado: jogador sempre ganha
    return true;
  }

  void _mostrarInventario() {
    if (jogador.inventario.isEmpty) {
      print('Inventário vazio');
    } else {
      print('Inventário:');
      for (var item in jogador.inventario) {
        print('  - ${item.nome}');
      }
    }
  }

  void executar() {
    print('╔════════════════════════════════════════╗');
    print('║   MASMORRA ASCII: Dungeon Crawl       ║');
    print('║         (MARCO III - Completo)        ║');
    print('╚════════════════════════════════════════╝\n');

    gerarAndar();

    while (emJogo && jogador.hpAtual > 0) {
      renderizarFrame();

      stdout.write('> ');
      final entrada = stdin.readLineSync() ?? '';
      processarComando(entrada);
    }

    _mostrarGameOver();
  }

  void _mostrarGameOver() {
    print('\n╔════════════════════════════════════════╗');
    if (vitoria) {
      print('║       ESCAPASTE DA MASMORRA!          ║');
      print('║           PARABÉNS!                   ║');
    } else {
      print('║            GAME OVER                  ║');
      print('║        Caíste na masmorra...          ║');
    }
    print('╠════════════════════════════════════════╣');
    print('║ Estatísticas Finais:                   ║');
    print('║ Turnos: $turno'.padRight(40) + '║');
    print('║ Maior Andar: $maiorAndarAlcancado'.padRight(40) + '║');
    print('║ Inimigos Derrotados: $totalInimigosDefeitos'.padRight(40) + '║');
    print('║ Ouro Total: ${jogador.ouro}'.padRight(40) + '║');
    print('║ Itens Coletados: ${jogador.inventario.length}'.padRight(40) + '║');
    print('╚════════════════════════════════════════╝\n');
  }
}
