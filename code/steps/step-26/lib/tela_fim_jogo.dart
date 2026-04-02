/// Renderiza telas de vitória e derrota
class TelaFimJogo {
  final String nomeJogador;
  final int nivelFinal;
  final int andarAlcancado;
  final int totalTurnos;
  final int totalInimigosDefeitos;
  final int totalOuroColetado;
  final bool vitoria;

  TelaFimJogo({
    required this.nomeJogador,
    required this.nivelFinal,
    required this.andarAlcancado,
    required this.totalTurnos,
    required this.totalInimigosDefeitos,
    required this.totalOuroColetado,
    required this.vitoria,
  });

  void mostrar() {
    if (vitoria) {
      _mostrarVitoria();
    } else {
      _mostrarDerrota();
    }
  }

  void _mostrarVitoria() {
    print('''

╔════════════════════════════════════════════════════════╗
║                                                        ║
║              VITÓRIA GLORIOSA!                         ║
║                                                        ║
║   Você derrotou o Rei da Masmorra e libertou         ║
║   o reino das sombras que o enfeitiçavam!            ║
║                                                        ║
╚════════════════════════════════════════════════════════╝

ESTATÍSTICAS FINAIS
═══════════════════════════════════════════════════════

Herói:          $nomeJogador
Nível Final:    $nivelFinal
Andares:        $andarAlcancado / 5
Turnos Totais:  $totalTurnos
Inimigos:       $totalInimigosDefeitos
Ouro Coletado:  $totalOuroColetado

═══════════════════════════════════════════════════════

  Parabéns! Você completou Masmorra ASCII!
  Sua lenda será contada nos séculos vindouros.

    ''');
  }

  void _mostrarDerrota() {
    print('''

╔════════════════════════════════════════════════════════╗
║                                                        ║
║              DERROTA AMARGA                            ║
║                                                        ║
║   Você caiu nas sombras da masmorra, derrotado       ║
║   pelas forças que nela habitam.                      ║
║                                                        ║
╚════════════════════════════════════════════════════════╝

EPITÁFIO
═══════════════════════════════════════════════════════

Aqui jaz $nomeJogador
Um herói de nível $nivelFinal

Caiu no andar $andarAlcancado
Derrotou $totalInimigosDefeitos inimigos
Coletou $totalOuroColetado ouro
Viveu por $totalTurnos turnos

═══════════════════════════════════════════════════════

  Nem toda jornada resulta em glória.
  Mas sua tentativa é lembrada.

    ''');
  }
}
