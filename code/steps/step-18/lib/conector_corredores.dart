import 'dart:math';
import 'sala.dart';
import 'tile.dart';

class ConectorCorredores {
  void conectarTodasAsSalas(
    List<Sala> salas,
    List<List<Tile>> grade,
  ) {
    if (salas.isEmpty) return;

    // Usar algoritmo de Árvore Geradora Mínima (MST)
    // Conecta cada sala à mais próxima ainda não conectada
    final conectadas = <Sala>{salas[0]};
    final naoConectadas = <Sala>{...salas};
    naoConectadas.remove(salas[0]);

    while (naoConectadas.isNotEmpty) {
      // Encontra o par (conectada, não conectada) com menor distância
      Sala? salaProxima;
      Sala? salaConectarA;
      double menorDistancia = double.infinity;

      for (final con in conectadas) {
        for (final nao in naoConectadas) {
          final dist = _distancia(con.centro, nao.centro);
          if (dist < menorDistancia) {
            menorDistancia = dist;
            salaProxima = nao;
            salaConectarA = con;
          }
        }
      }

      if (salaProxima != null && salaConectarA != null) {
        salaConectarA.desenharCorredorPara(salaProxima, grade);
        conectadas.add(salaProxima);
        naoConectadas.remove(salaProxima);
      }
    }
  }

  double _distancia(Point<int> a, Point<int> b) {
    final dx = (a.x - b.x).toDouble();
    final dy = (a.y - b.y).toDouble();
    return sqrt(dx * dx + dy * dy);
  }
}
