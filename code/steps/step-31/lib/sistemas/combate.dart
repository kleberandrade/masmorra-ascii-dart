import 'dart:math';
import '../modelos/jogador.dart';
import '../modelos/inimigo.dart';

/// Calculadora de dano no combate
class CalculadorDano {
  static const int minDano = 1;
  static const int variacao = 3;

  /// Calcula o dano baseado em ataque e defesa
  int calcular(int ataque, int defesa) {
    int danoBase = max(minDano, ataque - defesa);
    int danoAleatorio = Random().nextInt(variacao) + 1;
    return danoBase + danoAleatorio;
  }
}

/// Gerencia um combate entre jogador e inimigo
class Combate {
  final Jogador jogador;
  final Inimigo inimigo;
  late CalculadorDano calculador;
  bool _terminou = false;

  Combate({
    required this.jogador,
    required this.inimigo,
  }) {
    calculador = CalculadorDano();
  }

  /// Verifica se o combate terminou
  bool get terminou => _terminou;

  /// Jogador ataca o inimigo
  void atacarInimigo() {
    if (_terminou) return;

    int dano = calculador.calcular(jogador.ataque, inimigo.defesa);
    inimigo.sofrerDano(dano);

    if (!inimigo.estaVivo) {
      _terminou = true;
    }
  }

  /// Inimigo ataca o jogador
  void ataqueInimigo() {
    if (_terminou || !inimigo.estaVivo) return;

    int dano = calculador.calcular(inimigo.ataque, jogador.defesa);
    jogador.sofrerDano(dano);

    if (!jogador.estaVivo) {
      _terminou = true;
    }
  }

  /// Jogador se defende (reduz dano em 50%)
  int defesa = 0;

  void defender() {
    defesa = 1;
  }

  /// Reinicia o flag de defesa
  void resetarDefesa() {
    defesa = 0;
  }

  /// Retorna true se o jogador venceu
  bool jogadorVenceu() => inimigo.estaVivo == false && jogador.estaVivo;

  /// Retorna true se o inimigo venceu
  bool inimigoVenceu() => jogador.estaVivo == false && inimigo.estaVivo;
}
