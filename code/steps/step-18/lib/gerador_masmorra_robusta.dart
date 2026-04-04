import 'dart:math';
import 'mapa_masmorra.dart';
import 'validador_mapa.dart';

class GeradorMasmorraRobusta {
  MapaMasmorra gerarValidado({
    required int largura,
    required int altura,
    required int numSalas,
    int maxTentativas = 10,
  }) {
    final validador = ValidadorMapa();

    for (int tentativa = 0; tentativa < maxTentativas; tentativa++) {
      final mapa = MapaMasmorra.comSalasECorredores(
        largura: largura,
        altura: altura,
        random: Random(),
        numSalas: numSalas,
      );

      final resultado = validador.validarMapaCompleto(mapa);

      if (resultado.valido) {
        print('Mapa válido gerado na tentativa ${tentativa + 1}');
        print('Regiões conectadas: ${resultado.numRegioes}');
        print('Tamanho maior região: ${resultado.tamanhoMaiorRegiao}');
        return mapa;
      }

      print('Tentativa ${tentativa + 1}: ${resultado.mensagem}');
    }

    // Fallback: retorna mapa inválido (ou lança exceção)
    throw Exception(
      'Falha ao gerar mapa válido após $maxTentativas tentativas'
    );
  }
}
