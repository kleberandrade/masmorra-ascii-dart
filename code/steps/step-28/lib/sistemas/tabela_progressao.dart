/// Sistema de progressão por experiência
class TabelaProgressao {
  int xpParaNivel(int nivel) {
    if (nivel <= 1) return 0;
    final n = nivel - 1;
    return n * n * 50;
  }

  int xpNecessarioParaProximoNivel(int nivelAtual) {
    final proximoNivel = nivelAtual + 1;
    return xpParaNivel(proximoNivel) - xpParaNivel(nivelAtual);
  }

  int percentualProgresso(int nivelAtual, int xpAtual) {
    if (nivelAtual >= 20) return 100;
    final xpDoNivelAtual = xpParaNivel(nivelAtual);
    final xpDoProximo = xpParaNivel(nivelAtual + 1);
    final xpNaJanela = xpAtual - xpDoNivelAtual;
    final janelaNecessaria = xpDoProximo - xpDoNivelAtual;
    return ((xpNaJanela / janelaNecessaria) * 100).toInt();
  }
}
