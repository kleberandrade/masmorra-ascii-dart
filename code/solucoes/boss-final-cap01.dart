/// Boss Final Capítulo 1: Arte ASCII de Portal Mágico
///
/// Objetivo: Criar uma arte ASCII de um portal mágico ou inscrição antiga na
/// parede da masmorra, usando apenas print(). O objetivo é dominar a saída
/// no terminal e entender como texto visual funciona num roguelike.
///
/// Conceitos abordados:
/// - Saída formatada com print()
/// - Caracteres Unicode para efeitos visuais
/// - Box-drawing characters
/// - Padrões repetitivos e simetria
/// - Interpolação de strings
///
/// Instruções:
/// 1. Execute este arquivo com: dart boss-final-cap01.dart
/// 2. Observe a arte ASCII do portal
/// 3. Modifique os caracteres especiais para criar variações
/// 4. Adicione mais detalhes ou camadas ao portal
///
/// Resultado esperado: Um portal ASCII magnífico exibido no terminal

void main() {
  // Limpar tela (opcional)
  print('\u001b[2J\u001b[0;0H');

  exibirPortalMagico();
}

/// Exibe um portal mágico elaborado com arte ASCII
/// Usa simetria vertical e características visuais encantadas
void exibirPortalMagico() {
  // Borda superior com caracteres especiais
  print('');
  print('               ◆ ◆ ◆ ◆ ◆ ◆ ◆ ◆ ◆ ◆ ◆ ◆');
  print('         ◇                                       ◇');
  print('       ◆                                           ◆');
  print('      ◇                                             ◇');
  print('');

  // Portal externo (moldura)
  print('    ╔════════════════════════════════════════════════════╗');
  print('    ║                                                    ║');
  print('    ║                                                    ║');

  // Primeira linha do círculo mágico
  print('    ║         ✦                              ✦           ║');
  print('    ║      ◆  ═════════════════════════════  ◆            ║');
  print('    ║                                                    ║');

  // Centro do portal - anéis concêntricos
  print('    ║        ◇      ╔═══════════════════╗       ◇        ║');
  print('    ║      ◆        ║    PORTAL ANTIGO  ║        ◆      ║');
  print('    ║    ◇          ║    DESCOBERTO     ║          ◇    ║');
  print('    ║   ◆           ║                   ║           ◆   ║');
  print('    ║  ◇            ║   Realm Mágico    ║            ◇  ║');
  print('    ║              ║   Desperta Aqui    ║               ║');
  print('    ║              ╚═══════════════════╝               ║');
  print('    ║                                                    ║');

  // Anéis exteriores
  print('    ║      ◆                                      ◆      ║');
  print('    ║        ◇  ═════════════════════════════  ◇        ║');
  print('    ║         ✦                              ✦           ║');
  print('    ║                                                    ║');
  print('    ║                                                    ║');

  // Borda inferior
  print('    ╚════════════════════════════════════════════════════╝');
  print('      ◇                                             ◇');
  print('       ◆                                           ◆');
  print('         ◇                                       ◇');
  print('               ◆ ◆ ◆ ◆ ◆ ◆ ◆ ◆ ◆ ◆ ◆ ◆');
  print('');

  // Inscrição mística
  print('   ═══════════════════════════════════════════════════════');
  print('   │ Inscrição Antiga (Gera Calor Estranho) │');
  print('   ═══════════════════════════════════════════════════════');
  print('');
  print('   "Aquele que atravessa este limiar deixa para trás');
  print('    o mundo do sol e entra no domínio da sombra."');
  print('');
  print('   "Sete níveis aguardam. Coragem é moeda.');
  print('    Força é armadura. Sabedoria é a única escada."');
  print('');
  print('   ═══════════════════════════════════════════════════════');
  print('');
}

/// Variação: Portal Alternativo (mais simples)
void exibirPortalSimples() {
  print('');
  print('            ◆ ◆ ◆ ◆ ◆ ◆ ◆ ◆ ◆ ◆ ◆ ◆');
  print('          ◇                           ◇');
  print('        ◆                               ◆');
  print('       ◇                                 ◇');
  print('    ╔═══════════════════════════════════════╗');
  print('    ║         ✦  PORTAL  ✦               ║');
  print('    ║     ═════════════════════════        ║');
  print('    ║                                     ║');
  print('    ║      Mundo Mágico Aguarda...        ║');
  print('    ║                                     ║');
  print('    ║     ═════════════════════════        ║');
  print('    ║         ✦  ENTRADA ✦               ║');
  print('    ╚═══════════════════════════════════════╝');
  print('       ◇                                 ◇');
  print('        ◆                               ◆');
  print('          ◇                           ◇');
  print('            ◆ ◆ ◆ ◆ ◆ ◆ ◆ ◆ ◆ ◆ ◆ ◆');
  print('');
}

/// Variação: Portal com inscrição de bênção
void exibirPortalBencao() {
  print('');
  print('                    ✦');
  print('                   ◆ ◆');
  print('                  ◇   ◇');
  print('                 ◆     ◆');
  print('');
  print('         ╔════════════════════════════╗');
  print('         ║                            ║');
  print('         ║  ✦ BENÇÃO ANCESTRAL ✦    ║');
  print('         ║                            ║');
  print('         ║  "Que o luz guie teus     ║');
  print('         ║   passos nas trevas"      ║');
  print('         ║                            ║');
  print('         ║  Força: +1                 ║');
  print('         ║  Sabedoria: +2             ║');
  print('         ║  Sorte: imponderável       ║');
  print('         ║                            ║');
  print('         ╚════════════════════════════╝');
  print('');
  print('                 ◆     ◆');
  print('                  ◇   ◇');
  print('                   ◆ ◆');
  print('                    ✦');
  print('');
}
