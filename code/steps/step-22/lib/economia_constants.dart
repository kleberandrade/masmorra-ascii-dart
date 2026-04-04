/// Constantes de balanceamento da economia
class EconomiaConstants {
  /// Dificuldade escalonada por andar
  static const int kBaseHPPorInimigo = 10;
  static const double kAumentoHPPorAndar = 0.2; // +20% HP por andar

  /// Recompensas em ouro
  static const int kOuroBasePorInimigo = 5;
  static const double kAumentoOuroPorAndar = 0.3; // +30% ouro por andar

  /// Preços base da loja
  static const int kPrecoEspadaFerro = 50;
  static const int kPrecoArmaduraCouro = 75;
  static const int kPrecoPocaoVida = 20;

  /// Margem do comerciante
  static const double kMargemVenda = 0.5; // Comerciante oferece 50%
}
