import 'jogador.dart';
import 'tabela_progressao.dart';

void main() {
  print('╔════════════════════════════════════════╗');
  print('║   CAPÍTULO 25 - PROGRESSÃO E NÍVEIS    ║');
  print('╚════════════════════════════════════════╝\n');

  // Criar jogador
  final jogador = Jogador(nome: 'Corajoso', hpMax: 50, ataque: 5);
  final tabela = TabelaProgressao();

  print('Jogador inicial: $jogador\n');

  // Mostrar curva de XP
  print('=== CURVA DE PROGRESSÃO ===\n');
  for (int n = 1; n <= 10; n++) {
    final xpNecessario = tabela.xpParaNivel(n);
    print('Nível $n: $xpNecessario XP necessário');
  }

  // Simular ganho de XP
  print('\n=== GANHANDO XP ===\n');

  jogador.ganharXp(50);
  print('Status: ${jogador.barraProgresso()}\n');

  jogador.ganharXp(100);
  print('Status: ${jogador.barraProgresso()}\n');

  jogador.ganharXp(150);
  print('Status: ${jogador.barraProgresso()}\n');

  jogador.ganharXp(200);
  print('Status: ${jogador.barraProgresso()}\n');

  jogador.ganharXp(250);
  print('Status: ${jogador.barraProgresso()}\n');

  // Mostrar status final
  print('\n=== STATUS FINAL ===\n');
  print(jogador);
  print('Barra de XP: ${jogador.barraProgresso()}');

  // Mostrar habilidades
  jogador.mostrarHabilidades();
}
