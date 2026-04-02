// rolador.dart - Utilitária para operações aleatórias

import 'dart:math';

class Rolador {
  final Random random;

  Rolador({Random? random}) : random = random ?? Random();

  int rolar(int min, int max) {
    return min + random.nextInt(max - min + 1);
  }

  int d(int faces) => rolar(1, faces);

  bool chance(int percentual) {
    return random.nextInt(100) < percentual;
  }

  T escolher<T>(List<T> lista) {
    if (lista.isEmpty) throw Exception('Lista vazia');
    return lista[random.nextInt(lista.length)];
  }

  String escolherPonderado(Map<String, int> pesos) {
    final total = pesos.values.fold(0, (sum, p) => sum + p);
    var roll = random.nextInt(total);

    for (final entry in pesos.entries) {
      roll -= entry.value;
      if (roll < 0) return entry.key;
    }

    throw Exception('Erro interno');
  }

  int interpretarDados(String notacao) {
    // "2d6+3" → rolar 2d6 e somar 3
    final partes = notacao.split('+');
    final dado = partes[0];
    final bonus = partes.length > 1 ? int.parse(partes[1]) : 0;

    final dadoPartes = dado.split('d');
    final quantidade = int.parse(dadoPartes[0]);
    final faces = int.parse(dadoPartes[1]);

    int total = 0;
    for (int i = 0; i < quantidade; i++) {
      total += rolar(1, faces);
    }

    return total + bonus;
  }
}
