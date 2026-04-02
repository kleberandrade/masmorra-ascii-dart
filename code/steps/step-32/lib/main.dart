import 'masmorra.dart';

/// Ponto de entrada do jogo
/// Localizado em lib/ para ser executável principal
void main() {
  final renderizador = Renderizador();
  print(renderizador.renderizarBanner());

  final jogador = Jogador(
    nome: 'Aragorn',
    hpMax: 50,
    ataque: 10,
    defesa: 2,
  );

  print(renderizador.renderizarStatus(jogador));

  print('Bem-vindo a Masmorra ASCII!');
  print('Este é um projeto Dart profissional com:');
  print('  - lib/ para código reutilizável');
  print('  - lib/main.dart como executável');
  print('  - test/ espelhando lib/');
  print('  - pubspec.yaml centralizando dependências');
  print('  - analysis_options.yaml para qualidade');
  print('');
  print('Execute "dart lib/main.dart" para jogar');
  print('Execute "dart test" para rodar testes');
  print('Execute "dart analyze" para verificar qualidade');
}
