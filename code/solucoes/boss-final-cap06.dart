/// Boss Final Capítulo 6: Tela de Morte Épica (Game Over)
///
/// Objetivo: Criar uma tela de game over elaborada com arte ASCII,
/// nome do herói, turnos sobrevividos, ouro acumulado,
/// e mensagem de despedida. Usar box-drawing.
///
/// Conceitos abordados:
/// - Arte ASCII (túmulo/caveira)
/// - Layout com box-drawing
/// - Formatação visual
/// - Padrões estéticos em roguelikes

void main() {
  print('');
  telaGameOverEpica(
    nome: 'Aragorn, o Ranger',
    turnos: 45,
    ouro: 1250,
  );
}

/// Exibe tela de game over épica
void telaGameOverEpica({
  required String nome,
  required int turnos,
  required int ouro,
}) {
  print('');
  print('╔═══════════════════════════════════════════════════════════╗');
  print('║                                                           ║');
  print('║                     GAME OVER                            ║');
  print('║                                                           ║');
  print('║                        ◆◆◆                               ║');
  print('║                       ◆   ◆                              ║');
  print('║                       ◆ ✦ ◆                              ║');
  print('║                       ◆   ◆                              ║');
  print('║                        ◆◆◆                               ║');
  print('║                                                           ║');
  print('║                    ══════════════                         ║');
  print('║                    ║ DESCANSA    ║                       ║');
  print('║                    ║ EM PAZ      ║                       ║');
  print('║                    ║ ${ nome.padRight(13)} ║                       ║');
  print('║                    ║ HERÓI       ║                       ║');
  print('║                    ══════════════                         ║');
  print('║                                                           ║');
  print('║              A masmorra consumiu mais um...              ║');
  print('║                                                           ║');
  print('╠═══════════════════════════════════════════════════════════╣');
  print('║  Nome: ${ nome.padRight(51)} ║');
  print('║  Turnos: ${ turnos.toString().padRight(49)} ║');
  print('║  Ouro Acumulado: ${ ouro.toString().padRight(42)} ║');
  print('╠═══════════════════════════════════════════════════════════╣');
  print('║                                                           ║');
  print('║  "Sua jornada terminou aqui,                            ║');
  print('║   mas seu legado vive na memória dos vivos.             ║');
  print('║   Que encontres paz nas terras além."                   ║');
  print('║                                                           ║');
  print('╚═══════════════════════════════════════════════════════════╝');
  print('');
}

/// Variação: Caveira simples
void telaGameOverSimples({
  required String nome,
  required int turnos,
  required int ouro,
}) {
  print('');
  print('════════════════════════════════════════════════════════════');
  print('                        GAME OVER');
  print('════════════════════════════════════════════════════════════');
  print('');
  print('                          ▲');
  print('                         ▼█▼');
  print('                        ██████');
  print('                        ██  ██');
  print('                        ██████');
  print('                         ▼█▲');
  print('                          ▼');
  print('');
  print('          Herói: $nome');
  print('          Turnos Sobrevividos: $turnos');
  print('          Ouro Final: $ouro');
  print('');
  print('════════════════════════════════════════════════════════════');
  print('');
}

/// Variação: Game Over teatral
void telaGameOverTeatral({
  required String nome,
  required int turnos,
  required int ouro,
}) {
  print('');
  print('░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░');
  print('░                                                              ░');
  print('░                        ⚰️  GAME OVER  ⚰️                    ░');
  print('░                                                              ░');
  print('░                    A ESCURIDÃO VENCEU                       ░');
  print('░                                                              ░');
  print('░  O bravo herói ${ nome.padRight(35)} ░');
  print('░  caiu em combate contra as sombras da masmorra.           ░');
  print('░                                                              ░');
  print('░  Tempo de Sobrevivência: ${ turnos.toString().padRight(35)} ░');
  print('░  Tesouro Acumulado: ${ ouro.toString().padRight(40)} ░');
  print('░                                                              ░');
  print('░  ┌────────────────────────────────────────────────────┐    ░');
  print('░  │  Sua morte não foi em vão.                         │    ░');
  print('░  │  Outros virão à procura de riqueza.                │    ░');
  print('░  │  A masmorra permanece, eterna e impaciente.        │    ░');
  print('░  └────────────────────────────────────────────────────┘    ░');
  print('░                                                              ░');
  print('░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░');
  print('');
}
