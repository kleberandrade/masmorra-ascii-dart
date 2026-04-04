import 'jogador.dart';
import 'inimigo.dart';

class TurnoCombate {
  final Jogador jogador;
  final Inimigo inimigo;

  TurnoCombate(this.jogador, this.inimigo);

  void atacarInimigo(int dano) {
    print('${jogador.nome} ataca!');
    inimigo.sofrerDano(dano);
    print(inimigo.mostrarBarraVida());

    if (!inimigo.estaVivo) {
      print('${inimigo.nome} foi derrotado!');
      return;
    }

    print('${inimigo.nome} contra-ataca!');
    jogador.sofrerDano(inimigo.ataque);
    print('${jogador.nome}: ${jogador.mostrarBarraVida()}');
  }

  void executarCombate() {
    while (jogador.estaVivo && inimigo.estaVivo) {
      print('\n--- Turno ---');
      print('Ataca o ${jogador.nome}?');
      atacarInimigo(5);
    }

    if (jogador.estaVivo) {
      print('Vitória! ${inimigo.nome} foi derrotado!');
    } else {
      print('Derrota... ${jogador.nome} morreu.');
    }
  }
}
