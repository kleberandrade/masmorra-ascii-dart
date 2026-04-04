// Capítulo 19 - Boss Final: FOV em Múltiplos Andares
// Descrição: Estende FOV para andares acima e abaixo.
// Tiles em andares abaixo são vistos com opacidade reduzida.

import 'dart:math';

enum TileMapa { parede, chao, escada }

class Posicao {
  final int x;
  final int y;
  final int andar;

  Posicao(this.x, this.y, this.andar);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Posicao &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          andar == other.andar;

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ andar.hashCode;

  @override
  String toString() => '($x, $y, A$andar)';
}

class CampoVisaoMultiAndar {
  final Set<Posicao> tilesVisiveis = {};
  final Set<Posicao> tilesExplorados = {};

  // Raio base
  int raioBase = 8;

  void limpar() {
    tilesVisiveis.clear();
  }

  bool estaVisivel(int x, int y, int andar) {
    return tilesVisiveis.contains(Posicao(x, y, andar));
  }

  bool foiExplorado(int x, int y, int andar) {
    return tilesExplorados.contains(Posicao(x, y, andar));
  }

  void marcarVisivel(int x, int y, int andar) {
    tilesVisiveis.add(Posicao(x, y, andar));
    tilesExplorados.add(Posicao(x, y, andar));
  }

  void calcularFOVMultiAndar(
    int jogadorX,
    int jogadorY,
    int andarJogador,
    int mapaLargura,
    int mapaAltura,
  ) {
    limpar();

    // Andar atual: FOV normal (raio completo)
    _calcularShadowcastAndar(
      jogadorX,
      jogadorY,
      andarJogador,
      raioBase,
      mapaLargura,
      mapaAltura,
    );

    // Andares acima: raio reduzido em 50% por nível
    for (int andarAcima = andarJogador - 1; andarAcima >= andarJogador - 2; andarAcima--) {
      final distancia = (andarJogador - andarAcima).abs();
      final raioReduzido = (raioBase * (1 - distancia * 0.3)).ceil().clamp(2, raioBase);

      _calcularShadowcastAndar(
        jogadorX,
        jogadorY,
        andarAcima,
        raioReduzido,
        mapaLargura,
        mapaAltura,
      );
    }

    // Andares abaixo: raio reduzido em 50% por nível
    for (int andarAbaixo = andarJogador + 1; andarAbaixo <= andarJogador + 2; andarAbaixo++) {
      final distancia = (andarAbaixo - andarJogador).abs();
      final raioReduzido = (raioBase * (1 - distancia * 0.3)).ceil().clamp(2, raioBase);

      _calcularShadowcastAndar(
        jogadorX,
        jogadorY,
        andarAbaixo,
        raioReduzido,
        mapaLargura,
        mapaAltura,
      );
    }
  }

  void _calcularShadowcastAndar(
    int ox,
    int oy,
    int andar,
    int raio,
    int mapaLargura,
    int mapaAltura,
  ) {
    marcarVisivel(ox, oy, andar);

    final direcoes = [
      (1, 0),
      (1, 1),
      (0, 1),
      (-1, 1),
      (-1, 0),
      (-1, -1),
      (0, -1),
      (1, -1),
    ];

    for (final (dx, dy) in direcoes) {
      _lancarRaio(ox, oy, andar, dx, dy, raio, mapaLargura, mapaAltura);
    }
  }

  void _lancarRaio(
    int ox,
    int oy,
    int andar,
    int dx,
    int dy,
    int raio,
    int mapaLargura,
    int mapaAltura,
  ) {
    for (int passo = 1; passo <= raio; passo++) {
      final x = ox + dx * passo;
      final y = oy + dy * passo;

      if (x < 0 || x >= mapaLargura || y < 0 || y >= mapaAltura) {
        break;
      }

      marcarVisivel(x, y, andar);
    }
  }

  String obterCaracterVisibilidade(int x, int y, int andar, String charOriginal) {
    if (estaVisivel(x, y, andar)) {
      return charOriginal; // Visível: caractere normal
    } else if (foiExplorado(x, y, andar)) {
      // Explorado: caractere esfumaçado
      return switch (charOriginal) {
        '#' => '░',
        '.' => '·',
        '>' => '┐',
        _ => charOriginal.toLowerCase(),
      };
    } else {
      return ' '; // Nunca visto: vazio
    }
  }
}

class Mapa {
  final int largura;
  final int altura;
  final int andar;
  late List<List<TileMapa>> _tiles;

  Mapa({
    required this.largura,
    required this.altura,
    required this.andar,
  }) {
    _inicializar();
  }

  void _inicializar() {
    _tiles = List.generate(
      altura,
      (y) => List.generate(
        largura,
        (x) {
          if (x == 0 || x == largura - 1 || y == 0 || y == altura - 1) {
            return TileMapa.parede;
          }
          return TileMapa.chao;
        },
      ),
    );

    // Adicionar uma escada no canto inferior direito
    if (altura > 2 && largura > 2) {
      _tiles[altura - 2][largura - 2] = TileMapa.escada;
    }
  }

  TileMapa obterTile(int x, int y) {
    if (x < 0 || x >= largura || y < 0 || y >= altura) {
      return TileMapa.parede;
    }
    return _tiles[y][x];
  }

  String tileParaChar(TileMapa tile) {
    return switch (tile) {
      TileMapa.parede => '#',
      TileMapa.chao => '.',
      TileMapa.escada => '>',
    };
  }

  String renderizarComFOV(CampoVisaoMultiAndar fov, int jogadorX, int jogadorY) {
    final sb = StringBuffer();
    sb.write('Andar $andar:\n');

    for (int y = 0; y < altura; y++) {
      for (int x = 0; x < largura; x++) {
        final tile = obterTile(x, y);
        final charTile = tileParaChar(tile);
        final charFinal = fov.obterCaracterVisibilidade(x, y, andar, charTile);
        sb.write(charFinal);
      }
      sb.write('\n');
    }

    return sb.toString();
  }
}

void demonstrarFOVMultiAndar() {
  print('=== Boss Final Cap 19: FOV em Múltiplos Andares ===\n');

  // Criar mapas para 3 andares
  final mapaAndar1 = Mapa(largura: 20, altura: 10, andar: 1);
  final mapaAndar2 = Mapa(largura: 20, altura: 10, andar: 2);
  final mapaAndar3 = Mapa(largura: 20, altura: 10, andar: 3);

  final mapas = [mapaAndar1, mapaAndar2, mapaAndar3];

  // Posição do jogador
  const jogadorX = 10;
  const jogadorY = 5;
  const andarJogador = 2;

  // Calcular FOV em múltiplos andares
  final fov = CampoVisaoMultiAndar();
  fov.calcularFOVMultiAndar(
    jogadorX,
    jogadorY,
    andarJogador,
    20,
    10,
  );

  print('Jogador em: Posição ($jogadorX, $jogadorY), Andar $andarJogador');
  print('Raio FOV base: ${fov.raioBase} tiles\n');

  // Renderizar todos os andares
  for (final mapa in mapas) {
    print(mapa.renderizarComFOV(fov, jogadorX, jogadorY));
    print();
  }

  // Estatísticas
  print('--- ESTATÍSTICAS FOV ---');
  int totalVisivel = 0;
  int totalExplorado = 0;

  for (final mapa in mapas) {
    for (int y = 0; y < mapa.altura; y++) {
      for (int x = 0; x < mapa.largura; x++) {
        if (fov.estaVisivel(x, y, mapa.andar)) totalVisivel++;
        if (fov.foiExplorado(x, y, mapa.andar)) totalExplorado++;
      }
    }
  }

  print('Tiles visíveis agora: $totalVisivel');
  print('Tiles explorados (histórico): $totalExplorado');
  print('Total de tiles no mundo: ${20 * 10 * 3}');

  print('\n✓ Legendas:');
  print('  Normal: caracteres vistos normalmente');
  print('  Esfumaçado (░·┐): explorado mas fora do FOV');
  print('  Vazio: nunca explorado');
  print('\nN.B.: Andares distantes têm raio FOV reduzido!\n');
}

void main() {
  demonstrarFOVMultiAndar();
}
