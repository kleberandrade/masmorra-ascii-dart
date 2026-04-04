// tile.dart - Definição de tipos de tiles

enum Tile {
  parede,      // '#' - parede sólida, intransponível
  chao,        // '.' - chão passável
  porta,       // '+' - porta fechada ou aberta
  escadaDesce, // '>' - escadas para próximo nível
}

String tileParaChar(Tile tile) {
  return switch (tile) {
    Tile.parede => '#',
    Tile.chao => '.',
    Tile.porta => '+',
    Tile.escadaDesce => '>',
  };
}

bool ehPassavelTile(Tile tile) {
  return tile == Tile.chao || tile == Tile.porta || tile == Tile.escadaDesce;
}
