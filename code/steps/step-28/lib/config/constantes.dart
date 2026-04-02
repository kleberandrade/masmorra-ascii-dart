/// Constantes centralizadas de configuração
class Constantes {
  // Saúde
  static const int hpMinimoCritico = 17;
  static const int hpMaximoBase = 50;
  static const int bonusHPPorNivel = 10;

  // Ataque
  static const int ataqueBase = 5;
  static const int bonusAtaquePorNivel = 2;

  // Economia
  static const int precoEspadaFerro = 50;
  static const int precoArmaduraCouro = 75;
  static const int precoPocaoVida = 20;
  static const double margemVenda = 0.5;

  // Experiência
  static const int xpPorZumbi = 15;
  static const int xpPorLobo = 30;
  static const int xpPorEsqueleto = 50;
  static const int xpPorOrc = 75;

  // Mapa
  static const int larguraTelaMax = 80;
  static const int alturaTelaMax = 24;

  // Geração
  static const int tentativasGeracaoMapa = 5;
  static const int inimigosMinimos = 3;

  // Progressão
  static const int nivelMaximo = 20;
  static const double aumentoHpPorAndar = 0.2;
  static const double aumentoOuroPorAndar = 0.3;
}
