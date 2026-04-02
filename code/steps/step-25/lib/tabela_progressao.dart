/// Define a curva de experiência e recompensas de nível
class TabelaProgressao {
  /// Fórmula: XP necessário para alcançar um nível
  int xpParaNivel(int nivel) {
    if (nivel <= 1) return 0;
    final n = nivel - 1;
    return n * n * 50;
  }

  /// XP necessário para ir DO nível atual AO próximo
  int xpNecessarioParaProximoNivel(int nivelAtual) {
    final proximoNivel = nivelAtual + 1;
    return xpParaNivel(proximoNivel) - xpParaNivel(nivelAtual);
  }

  /// Quanto XP falta (ou quantos pontos passaste)
  int xpRestanteParaProximo(int nivelAtual, int xpAtual) {
    final xpDoNivelAtual = xpParaNivel(nivelAtual);
    final xpDoProximo = xpParaNivel(nivelAtual + 1);
    final xpNaJanela = xpAtual - xpDoNivelAtual;
    final janelaNecessaria = xpDoProximo - xpDoNivelAtual;
    return janelaNecessaria - xpNaJanela;
  }

  /// Progresso em percentual (0-100) para próximo nível
  int percentualProgresso(int nivelAtual, int xpAtual) {
    if (nivelAtual >= 20) return 100;
    final xpDoNivelAtual = xpParaNivel(nivelAtual);
    final xpDoProximo = xpParaNivel(nivelAtual + 1);
    final xpNaJanela = xpAtual - xpDoNivelAtual;
    final janelaNecessaria = xpDoProximo - xpDoNivelAtual;
    return ((xpNaJanela / janelaNecessaria) * 100).toInt();
  }

  int bonusHPPorNivel() => 10;
  int bonusAtaquePorNivel() => 2;
  int nivelMaximo() => 20;

  int xpPorInimigo(String tipoInimigo) {
    return switch (tipoInimigo) {
      'zumbi' => 15,
      'lobo' => 30,
      'esqueleto' => 50,
      'orc' => 75,
      _ => 10,
    };
  }
}
