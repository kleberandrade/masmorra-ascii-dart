import 'dart:io';
import 'dart:math';
import 'package:step_20_entidades/tile.dart';
import 'package:step_20_entidades/tela_ascii.dart';
import 'package:step_20_entidades/campo_visao.dart';
import 'package:step_20_entidades/entidade.dart';

void main() {
  final mapa = MapaMasmorra(largura: 50, altura: 20);

  for (int y = 0; y < 20; y++) {
    for (int x = 0; x < 50; x++) {
      if (x == 0 || x == 49 || y == 0 || y == 19) {
        mapa.definirTile(x, y, Tile.parede);
      }
    }
  }

  for (int x = 10; x < 40; x += 5) {
    for (int y = 2; y < 18; y++) {
      mapa.definirTile(x, y, Tile.parede);
    }
    mapa.definirTile(x, 10, Tile.chao);
  }

  final jogador = Jogador(
    nome: 'Aldric',
    x: 5,
    y: 5,
    hpMax: 100,
    ouro: 0,
  );

  final spawner = GeradorEntidades(
    mapa: mapa,
    andarAtual: 0,
  );

  final andar = AndarMasmorra(
    numero: 0,
    mapa: mapa,
    entidades: spawner.spawn(),
  );

  final tela = TelaAscii(largura: 50, altura: 25);

  print('=== MASMORRA ASCII: Entidades ===\n');

  bool rodando = true;
  int turno = 0;

  while (rodando) {
    tela.limpar();

    // Renderizar mapa
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
    for (final entidade in andar.entidades) {
      entidade.renderizarNaTela(tela, mapa.fov);
    }

    jogador.renderizarNaTela(tela, mapa.fov);

    // HUD
    final hudY = mapa.altura + 1;
    tela.desenharString(0, hudY, '═' * tela.largura);
    tela.desenharString(
      0,
      hudY + 1,
      'Turno: $turno | HP: ${jogador.hpAtual}/${jogador.hpMax} | Itens: ${jogador.inventario.length}',
    );
    tela.desenharString(0, hudY + 2, '[W]cima [A]esq [S]baixo [D]dir [Q]uit');

    tela.renderizar();

    // Input
    stdout.write('> ');
    final cmd = stdin.readLineSync() ?? '';

    switch (cmd.toLowerCase()) {
      case 'w' || 'a' || 's' || 'd':
        final novoX = jogador.x + (cmd.toLowerCase() == 'd' ? 1 : cmd.toLowerCase() == 'a' ? -1 : 0);
        final novoY = jogador.y + (cmd.toLowerCase() == 's' ? 1 : cmd.toLowerCase() == 'w' ? -1 : 0);

        if (mapa.ehPassavel(novoX, novoY)) {
          final entidade = andar.encontrarEntidadeEm(novoX, novoY);
          if (entidade != null) {
            if (entidade is EntidadeEscada) {
              print('Você encontrou as escadas! Descer? (s/n)');
              final resp = stdin.readLineSync() ?? 'n';
              if (resp.toLowerCase() == 's') {
                print('Você desce para o próximo andar...');
                rodando = false;
              }
            } else if (entidade is EntidadeInimigo) {
              print('Você encontrou um ${entidade.nome}!');
              print('Engajar em combate? (s/n)');
              final resp = stdin.readLineSync() ?? 'n';
              if (resp.toLowerCase() == 's') {
                print('Você venceu! +25 ouro');
                jogador.ouro += 25;
                andar.removerEntidade(entidade);
              }
            } else if (entidade is EntidadeItem) {
              print('Você pegou ${entidade.nome}!');
              entidade.aoTocada(jogador);
              andar.removerEntidade(entidade);
            }
          } else {
            jogador.mover(novoX, novoY, mapa);
            turno++;
          }
        }

        mapa.fov.calcularShadowcast(
          Point(jogador.x, jogador.y),
          8,
          mapa,
        );

      case 'q':
        rodando = false;
      default:
        // Ignorar
    }
  }

  print('Até logo!');
}
