// Capítulo 17 - Boss Final: Teste de Determinismo (Replicabilidade)
// Descrição: Implementa == e hashCode em classes principais.
// Verifica que mapas com mesma seed são idênticos.

import 'dart:math';

enum TileMapa { parede, chao, agua }

class Posicao {
  final int x;
  final int y;

  Posicao(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Posicao && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() => '($x, $y)';
}

class MapaSimples {
  final int largura;
  final int altura;
  final int seed;
  late List<List<TileMapa>> _tiles;

  MapaSimples({required this.largura, required this.altura, required this.seed}) {
    _gerarComSeed(seed);
  }

  void _gerarComSeed(int semente) {
    final random = Random(semente);
    _tiles = List.generate(
      altura,
      (y) => List.generate(
        largura,
        (x) {
          if (x == 0 || x == largura - 1 || y == 0 || y == altura - 1) {
            return TileMapa.parede;
          }
          final valor = random.nextInt(100);
          if (valor < 70) return TileMapa.chao;
          if (valor < 85) return TileMapa.agua;
          return TileMapa.parede;
        },
      ),
    );
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
        sb.write(switch (tile) {
          TileMapa.parede => '#',
          TileMapa.chao => '.',
          TileMapa.agua => '~',
        });
      }
      sb.write('\n');
    }
    return sb.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapaSimples &&
          runtimeType == other.runtimeType &&
          largura == other.largura &&
          altura == other.altura &&
          seed == other.seed &&
          paraString() == other.paraString();

  @override
  int get hashCode =>
      largura.hashCode ^
      altura.hashCode ^
      seed.hashCode ^
      paraString().hashCode;

  @override
  String toString() => 'MapaSimples($largura×$altura, seed=$seed)';
}

class Jogador {
  final String nome;
  final Posicao posicao;
  final int hpMax;

  Jogador({
    required this.nome,
    required this.posicao,
    required this.hpMax,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Jogador &&
          runtimeType == other.runtimeType &&
          nome == other.nome &&
          posicao == other.posicao &&
          hpMax == other.hpMax;

  @override
  int get hashCode => nome.hashCode ^ posicao.hashCode ^ hpMax.hashCode;

  @override
  String toString() => 'Jogador($nome at $posicao)';
}

void testarDeterminismo() {
  print('=== Boss Final Cap 17: Teste de Determinismo ===\n');

  // Teste 1: Mesma seed = mesmo mapa
  print('Teste 1: Mesma seed deve gerar mapa idêntico');
  final mapa1 = MapaSimples(largura: 20, altura: 15, seed: 42);
  final mapa2 = MapaSimples(largura: 20, altura: 15, seed: 42);

  if (mapa1 == mapa2) {
    print('✓ PASSOU: Mapas com seed 42 são idênticos');
  } else {
    print('✗ FALHOU: Mapas com seed 42 são diferentes');
  }

  // Teste 2: Seeds diferentes = mapas diferentes
  print('\nTeste 2: Seeds diferentes devem gerar mapas diferentes');
  final mapa3 = MapaSimples(largura: 20, altura: 15, seed: 43);

  if (mapa1 != mapa3) {
    print('✓ PASSOU: Mapas com seeds 42 e 43 são diferentes');
  } else {
    print('✗ FALHOU: Mapas com seeds diferentes são iguais');
  }

  // Teste 3: Operador == é simétrico
  print('\nTeste 3: Simetria do operador ==');
  if ((mapa1 == mapa2) == (mapa2 == mapa1)) {
    print('✓ PASSOU: (a == b) é simétrico');
  } else {
    print('✗ FALHOU: (a == b) não é simétrico');
  }

  // Teste 4: Transitividade
  print('\nTeste 4: Transitividade (a == b && b == c → a == c)');
  final mapaC = MapaSimples(largura: 20, altura: 15, seed: 42);
  if (mapa1 == mapa2 && mapa2 == mapaC && mapa1 == mapaC) {
    print('✓ PASSOU: Transitividade mantida');
  } else {
    print('✗ FALHOU: Transitividade quebrada');
  }

  // Teste 5: HashCode consistente
  print('\nTeste 5: HashCode deve ser consistente para objetos iguais');
  if (mapa1.hashCode == mapa2.hashCode) {
    print('✓ PASSOU: HashCodes iguais para mapas iguais');
  } else {
    print('✗ FALHOU: HashCodes diferentes para mapas iguais');
  }

  // Teste 6: Jogadores
  print('\nTeste 6: Igualdade de Jogadores');
  final j1 = Jogador(nome: 'Aldric', posicao: Posicao(5, 5), hpMax: 100);
  final j2 = Jogador(nome: 'Aldric', posicao: Posicao(5, 5), hpMax: 100);
  final j3 = Jogador(nome: 'Aldric', posicao: Posicao(6, 5), hpMax: 100);

  if (j1 == j2) {
    print('✓ PASSOU: Jogadores com mesmos dados são iguais');
  } else {
    print('✗ FALHOU: Jogadores com mesmos dados são diferentes');
  }

  if (j1 != j3) {
    print('✓ PASSOU: Jogadores em posições diferentes são diferentes');
  } else {
    print('✗ FALHOU: Jogadores em posições diferentes são iguais');
  }

  // Visualizar um mapa
  print('\n--- Visualização do Mapa (seed 42) ---');
  print(mapa1.paraString());

  print('\n--- Todos os testes completados! ---\n');
}

void main() {
  testarDeterminismo();
}
