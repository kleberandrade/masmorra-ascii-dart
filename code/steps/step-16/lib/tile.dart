enum Tile {
  parede,
  chao,
  porta,
  escadaDesce,
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
