/// Gerencia configuração de dificuldade por andar
class GerenciadorAndares {
  int andarAtual = 0;
  final int andarFinal = 4;

  /// Retorna (hpBonus, ataqueBonus, tiposInimigos) para um andar
  ({int hpBonus, int ataqueBonus, List<String> inimigos}) configurarAndar(
      int numero) {
    return switch (numero) {
      0 => (hpBonus: 0, ataqueBonus: 0, inimigos: ['zumbi']),
      1 => (
        hpBonus: 10,
        ataqueBonus: 2,
        inimigos: ['zumbi', 'lobo'],
      ),
      2 => (
        hpBonus: 20,
        ataqueBonus: 4,
        inimigos: ['lobo', 'esqueleto'],
      ),
      3 => (
        hpBonus: 35,
        ataqueBonus: 6,
        inimigos: ['esqueleto', 'orc'],
      ),
      4 => (
        hpBonus: 60,
        ataqueBonus: 10,
        inimigos: ['chefao'],
      ),
      _ => (
        hpBonus: 100,
        ataqueBonus: 15,
        inimigos: ['chefao'],
      ),
    };
  }

  /// Itens disponíveis por andar
  List<String> itensPorAndar(int numero) {
    return switch (numero) {
      0 => ['pocaoVida', 'pocaoVida'],
      1 => ['pocaoVida', 'pocaoVida', 'espadaFerro'],
      2 => ['pocaoVida', 'espadaAco', 'escudoAco'],
      3 => ['pocaoVida', 'espadaRunada', 'armaduraPesada'],
      4 => [],
      _ => [],
    };
  }

  /// Descrição narrativa do andar
  String descreverAndar(int numero) {
    return switch (numero) {
      0 => 'Você entra nas masmorras. O ar é frio e úmido. Lodo cobre o chão.',
      1 => 'O segundo andar é mais rochoso. Você ouve ecos de criaturas.',
      2 => 'Aqui, ossos cobrem o solo. A magia é palpável.',
      3 => 'Este é o andar da perdição. Auras malignas fluem.',
      4 =>
        'Você entra numa câmara colossal. No centro, um trono antigo. E nele, ELE.',
      _ => 'Um lugar estranho na masmorra.',
    };
  }

  bool get ehAndarDoChefe => andarAtual == andarFinal;
  bool get ehUltimoAndar => andarAtual >= andarFinal;
}
