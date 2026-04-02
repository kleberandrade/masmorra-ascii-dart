import 'dart:math';
import '../modelos/jogador.dart';
import '../modelos/inimigo.dart';

class CalculadorDano {
  static const int minDano = 1;
  static const int variacao = 3;

  int calcular(int ataque, int defesa) {
    int danoBase = max(minDano, ataque - defesa);
    int danoAleatorio = Random().nextInt(variacao) + 1;
    return danoBase + danoAleatorio;
  }
}

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

  bool get terminou => _terminou;

  void atacarInimigo() {
    if (_terminou) return;

    int dano = calculador.calcular(jogador.ataque, inimigo.defesa);
    inimigo.sofrerDano(dano);

    if (!inimigo.estaVivo) {
      _terminou = true;
    }
  }

  void ataqueInimigo() {
    if (_terminou || !inimigo.estaVivo) return;

    int dano = calculador.calcular(inimigo.ataque, jogador.defesa);
    jogador.sofrerDano(dano);

    if (!jogador.estaVivo) {
      _terminou = true;
    }
  }

  bool jogadorVenceu() => inimigo.estaVivo == false && jogador.estaVivo;

  bool inimigoVenceu() => jogador.estaVivo == false && inimigo.estaVivo;
}
