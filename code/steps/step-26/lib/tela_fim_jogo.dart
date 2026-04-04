import 'jogador.dart';

/// Renderiza telas de vitória e derrota
class TelaFimJogo {
  final Jogador jogador;
  final int andarAlcancado;
  final int totalTurnos;
  final int totalInimigosDefeitos;
  final int totalOuroColetado;
  final bool vitoria;

  TelaFimJogo({
    required this.jogador,
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
    print('');
    print('VITÓRIA GLORIOSA!');
    print('');
    print('Você derrotou o Rei da Masmorra e libertou');
    print('o reino das sombras que o enfeitiçavam!');
    print('');
    print('ESTATÍSTICAS FINAIS');
    print('═' * 55);
    print('');
    print('Herói:          ${jogador.nome}');
    print('Nível Final:    ${jogador.nivel}');
    print('HP:             ${jogador.hp}/${jogador.maxHp}');
    print('Ataque:         ${jogador.ataque}');
    print('');
    print('CAMPANHA');
    print('─' * 55);
    print('Andares Explorados:   $andarAlcancado / 5');
    print('Turnos Totais:        $totalTurnos');
    print('Inimigos Derrotados:  $totalInimigosDefeitos');
    print('Ouro Coletado:        $totalOuroColetado');
    print('');
    print('═' * 55);
    print('');
    print('Parabéns! Você completou Masmorra ASCII!');
    print('Sua lenda será contada nos séculos vindouros.');
    print('');
  }

  void _mostrarDerrota() {
    print('');
    print('DERROTA AMARGA');
    print('');
    print('Você caiu nas sombras da masmorra, derrotado');
    print('pelas forças que nela habitam.');
    print('');
    print('EPITÁFIO');
    print('═' * 55);
    print('');
    print('Aqui jaz ${jogador.nome}');
    print('Um herói de nível ${jogador.nivel}');
    print('');
    print('Caiu no andar $andarAlcancado');
    print('Derrotou $totalInimigosDefeitos inimigos');
    print('Coletou $totalOuroColetado ouro');
    print('Viveu por $totalTurnos turnos');
    print('');
    print('═' * 55);
    print('');
    print('Nem toda jornada resulta em glória.');
    print('Mas sua tentativa é lembrada.');
    print('');
  }
}
