// Capítulo 18 - Boss Final: Sistema de Sementes Reproduzível
// Descrição: Gera 3 mapas com mesma seed - todos devem ser idênticos.
// Exibe seed na HUD para permitir debugging e compartilhamento.

import 'dart:math';

enum TileMapa { parede, chao }

class MapaProcedural {
  final int largura;
  final int altura;
  final int seed;
  late List<List<TileMapa>> _tiles;
  late Random _random;

  MapaProcedural({
    required this.largura,
    required this.altura,
    required this.seed,
  }) {
    _gerarComSeed();
  }

  void _gerarComSeed() {
    _random = Random(seed);
    _tiles = List<List<TileMapa>>.generate(
      altura,
      (y) => List<TileMapa>.generate(largura, (x) => TileMapa.parede),
    );

    // Usar Random Walk para gerar caverna
    int x = largura ~/ 2;
    int y = altura ~/ 2;
    _tiles[y][x] = TileMapa.chao;

    const numPassos = 300;
    for (int passo = 0; passo < numPassos; passo++) {
      final direcao = _random.nextInt(4);
      switch (direcao) {
        case 0:
          if (y > 1) y--;
        case 1:
          if (y < altura - 2) y++;
        case 2:
          if (x < largura - 2) x++;
        case 3:
          if (x > 1) x--;
      }
      _tiles[y][x] = TileMapa.chao;
    }
  }

  TileMapa obterTile(int x, int y) {
    if (x < 0 || x >= largura || y < 0 || y >= altura) {
      return TileMapa.parede;
    }
    return _tiles[y][x];
  }

  String paraString() {
    final sb = StringBuffer();
    for (int y = 0; y < altura; y++) {
      for (int x = 0; x < largura; x++) {
        final tile = obterTile(x, y);
        sb.write(tile == TileMapa.parede ? '#' : '.');
      }
      sb.write('\n');
    }
    return sb.toString();
  }

  void renderizarComHUD() {
    // Imprimir cabeçalho com seed
    final linha = '═' * (largura + 2);
    print(linha);
    print('Mapa - Seed: $seed');
    print(linha);

    // Imprimir mapa
    print(paraString());

    // Imprimir rodapé
    print(linha);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapaProcedural &&
          runtimeType == other.runtimeType &&
          largura == other.largura &&
          altura == other.altura &&
          seed == other.seed &&
          paraString() == other.paraString();

  @override
  int get hashCode =>
      largura.hashCode ^ altura.hashCode ^ seed.hashCode ^ paraString().hashCode;
}

void testarReproducibilidade() {
  print('=== Boss Final Cap 18: Sementes Reproduzível ===\n');

  final seedTeste = 12345;
  const largura = 25;
  const altura = 12;

  print('Gerando 3 mapas com a mesma seed ($seedTeste)...\n');

  // Gerar 3 mapas
  final mapa1 = MapaProcedural(
    largura: largura,
    altura: altura,
    seed: seedTeste,
  );

  final mapa2 = MapaProcedural(
    largura: largura,
    altura: altura,
    seed: seedTeste,
  );

  final mapa3 = MapaProcedural(
    largura: largura,
    altura: altura,
    seed: seedTeste,
  );

  // Exibir cada mapa
  print('--- MAPA 1 ---');
  mapa1.renderizarComHUD();

  print('\n--- MAPA 2 ---');
  mapa2.renderizarComHUD();

  print('\n--- MAPA 3 ---');
  mapa3.renderizarComHUD();

  // Verificar igualdade
  print('\n--- VERIFICAÇÃO ---');
  print('Mapa 1 == Mapa 2: ${mapa1 == mapa2} (esperado: true)');
  print('Mapa 2 == Mapa 3: ${mapa2 == mapa3} (esperado: true)');
  print('Mapa 1 == Mapa 3: ${mapa1 == mapa3} (esperado: true)');

  // Testar seed diferente
  print('\n--- TESTE COM SEED DIFERENTE ---');
  final mapa4 = MapaProcedural(
    largura: largura,
    altura: altura,
    seed: seedTeste + 1,
  );

  print('Mapa 1 == Mapa 4 (seed diferente): ${mapa1 == mapa4} (esperado: false)');

  print('\n--- CONCLUSÃO ---');
  if (mapa1 == mapa2 && mapa2 == mapa3 && mapa1 != mapa4) {
    print('✓ SUCESSO: Sistema de sementes é totalmente reproduzível!');
    print('  Mesma seed = mapa idêntico');
    print('  Seed diferente = mapa diferente');
  } else {
    print('✗ FALHA: Sistema de sementes não funciona corretamente');
  }

  print('\nDica: Compartilhe a seed "12345" com amigos para gerar');
  print('o mesmo desafio de masmorra repetidamente!\n');
}

void main() {
  testarReproducibilidade();
}
