import 'entidade.dart';
import 'explorador_masmorra.dart';

class VerificadorCondicoes {
  /// Verifica se o jogador morreu
  bool jogadorMorreu(Jogador jogador) {
    return jogador.hpAtual <= 0;
  }

  /// Verifica se o jogador venceu
  bool jogadorVenceu(int andarAtual, int andarFinal) {
    return andarAtual >= andarFinal;
  }

  /// Gera estatísticas finais
  EstatisticasJogo gerarEstatisticas(
    ExploradorMasmorra explorador,
  ) {
    return EstatisticasJogo(
      turnosJogados: explorador.turno,
      maiorAndarAlcancado: explorador.maiorAndarAlcancado,
      inimigosDefeitos: explorador.totalInimigosDefeitos,
      ouroColetado: explorador.jogador.ouro,
      tempoJogo: DateTime.now(),
      jogadorVenceu: explorador.vitoria,
    );
  }
}

class EstatisticasJogo {
  final int turnosJogados;
  final int maiorAndarAlcancado;
  final int inimigosDefeitos;
  final int ouroColetado;
  final DateTime tempoJogo;
  final bool jogadorVenceu;

  EstatisticasJogo({
    required this.turnosJogados,
    required this.maiorAndarAlcancado,
    required this.inimigosDefeitos,
    required this.ouroColetado,
    required this.tempoJogo,
    required this.jogadorVenceu,
  });

  void imprimirResumo() {
    final resultado = jogadorVenceu ? 'VITÓRIA' : 'DERROTA';
    // ignore: avoid_print
    print('\n╔════════════════════════════════════════╗');
    // ignore: avoid_print
    print('║       RESULTADO: $resultado         ║');
    // ignore: avoid_print
    print('╠════════════════════════════════════════╣');
    // ignore: avoid_print
    print('║ Turnos: $turnosJogados');
    // ignore: avoid_print
    print('║ Maior Andar: $maiorAndarAlcancado');
    // ignore: avoid_print
    print('║ Inimigos Derrotados: $inimigosDefeitos');
    // ignore: avoid_print
    print('║ Ouro Total: $ouroColetado');
    // ignore: avoid_print
    print('║ Data/Hora: ${tempoJogo.toString()}');
    // ignore: avoid_print
    print('╚════════════════════════════════════════╝\n');
  }
}
