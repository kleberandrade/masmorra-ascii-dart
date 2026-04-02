import 'chefao.dart';
import 'gerenciador_andares.dart';
import 'tela_fim_jogo.dart';

void main() {
  print('╔════════════════════════════════════════╗');
  print('║  CAPÍTULO 26 - MÚLTIPLOS ANDARES       ║');
  print('╚════════════════════════════════════════╝\n');

  final gerenciadorAndares = GerenciadorAndares();

  // Demonstrar andares
  print('=== CONFIGURAÇÃO DOS ANDARES ===\n');

  for (int i = 0; i <= 4; i++) {
    final config = gerenciadorAndares.configurarAndar(i);
    print('Andar $i:');
    print('  Descrição: ${gerenciadorAndares.descreverAndar(i)}');
    print('  Bônus HP: +${config.hpBonus}');
    print('  Bônus ATK: +${config.ataqueBonus}');
    print('  Inimigos: ${config.inimigos.join(", ")}');
    print('');
  }

  // Demonstrar chefão
  print('=== COMBATE COM CHEFÃO ===\n');

  final chefao = Chefao(nome: 'Rei da Masmorra', hpMax: 150, danoBase: 12);

  print(chefao.descreverStatus());

  // Simular dano ao chefão em diferentes fases
  print('Simulando dano ao chefão...\n');

  for (int turno = 0; turno < 5; turno++) {
    final dano = 30 + (turno * 10);
    chefao.sofrerDano(dano);
    print('Turno ${turno + 1}: Chefão sofre $dano dano! HP: ${chefao.hp}');
    chefao.executarTurno();
    print('Fase atual: ${chefao.faseAtual.name}');
    print('');
  }

  // Tela de derrota
  print('=== TELA DE DERROTA ===\n');

  final telaDerrota = TelaFimJogo(
    nomeJogador: 'Aventureiro Corajoso',
    nivelFinal: 12,
    andarAlcancado: 4,
    totalTurnos: 247,
    totalInimigosDefeitos: 47,
    totalOuroColetado: 3250,
    vitoria: false,
  );

  telaDerrota.mostrar();

  // Tela de vitória
  print('\n=== TELA DE VITÓRIA ===\n');

  final telaVitoria = TelaFimJogo(
    nomeJogador: 'Campeão Lendário',
    nivelFinal: 18,
    andarAlcancado: 5,
    totalTurnos: 352,
    totalInimigosDefeitos: 89,
    totalOuroColetado: 8900,
    vitoria: true,
  );

  telaVitoria.mostrar();
}
