import 'dart:math';

/// Gerenciador de aleatoriedade para testes previsíveis
class Rolador {
  final Random random;

  Rolador({Random? random}) : random = random ?? Random();

  /// Testa se um evento com probabilidade p acontece
  bool teste(double probabilidade) {
    return random.nextDouble() < probabilidade;
  }

  /// Rola um dado de d lados (1 a d)
  int rolarDado(int lados) {
    return 1 + random.nextInt(lados);
  }

  /// Escolhe um elemento aleatório de uma lista
  T escolher<T>(List<T> lista) {
    if (lista.isEmpty) throw ArgumentError('Lista não pode estar vazia');
    return lista[random.nextInt(lista.length)];
  }
}
