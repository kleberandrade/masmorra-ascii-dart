import 'dart:math';
import 'sala.dart';

class ValidadorSalas {
  bool salaEValida(
    Sala novaSala,
    List<Sala> salasExistentes, {
    int margem = 2,
    int larguraMinima = 80,
    int alturaMinima = 24,
  }) {
    // Verifica se fica dentro dos limites do mapa
    if (novaSala.xMax >= larguraMinima || novaSala.yMax >= alturaMinima) {
      return false;
    }

    // Verifica sobreposição com todas as salas existentes
    for (final sala in salasExistentes) {
      if (novaSala.sobrepoe(sala, margem: margem)) {
        return false;
      }
    }

    return true;
  }

  // Tenta colocar N salas aleatoriamente, retorna quantas conseguiu
  int colocarSalasAleatorias(
    List<Sala> salasDestino,
    int quantasGenerar,
    Random random,
    int larguraMapa,
    int alturaMapa, {
    int minTamanho = 5,
    int maxTamanho = 12,
  }) {
    int colocadas = 0;

    for (int tentativa = 0; tentativa < quantasGenerar * 3; tentativa++) {
      final largura = minTamanho + random.nextInt(maxTamanho - minTamanho + 1);
      final altura = minTamanho + random.nextInt(maxTamanho - minTamanho + 1);
      final x = 1 + random.nextInt((larguraMapa - largura).clamp(1, larguraMapa));
      final y = 1 + random.nextInt((alturaMapa - altura).clamp(1, alturaMapa));

      final novaSala = Sala(x: x, y: y, largura: largura, altura: altura);

      if (salaEValida(novaSala, salasDestino, margem: 2)) {
        salasDestino.add(novaSala);
        colocadas++;

        if (colocadas >= quantasGenerar) break;
      }
    }

    return colocadas;
  }
}
