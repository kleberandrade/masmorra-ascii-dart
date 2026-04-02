import 'modelos/jogador.dart';
import 'ui/renderizador.dart';

void main() {
  final renderizador = Renderizador();

  final jogador = Jogador(
    nome: 'Aragorn',
    hpMax: 50,
    ataque: 10,
    defesa: 2,
  );

  jogador.sofrerDano(5);
  jogador.ganharXP(150);

  print(renderizador.renderizarStatus(jogador));
  print('Execute "dart test" para rodar os golden tests!');
}
