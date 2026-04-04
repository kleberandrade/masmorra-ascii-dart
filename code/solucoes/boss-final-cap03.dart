/// Boss Final Capítulo 3: Painel de Estatísticas Finais
///
/// Objetivo: Ao final do jogo (saída ou morte), exibir um painel com:
/// nome, turnos sobrevividos, HP final, dano total, e nota (S/A/B/C).
/// Usar operadores ternários e box-drawing.
///
/// Conceitos abordados:
/// - Operadores ternários (? :)
/// - Box-drawing para layout visual
/// - Cálculo de nota baseado em critérios
/// - Formatação de números
/// - Interpolação de strings
///
/// Instruções:
/// 1. Execute este arquivo com: dart boss-final-cap03.dart
/// 2. Observe o painel de estatísticas
/// 3. Modifique os valores de HP e turnos para ver notas diferentes
/// 4. Customize o painel para seu jogo

void main() {
  print('═══════════════════════════════════════════════════════════');
  print('  Boss Final Capítulo 3: Painel de Estatísticas Finais');
  print('═══════════════════════════════════════════════════════════');
  print('');

  // Teste 1: Boa performance
  exibirPainelEstatisticas(
    nome: 'Aragorn',
    turnos: 45,
    hpFinal: 85,
    hpMax: 100,
    causa: 'Vitória contra o boss!',
  );

  print('');

  // Teste 2: Performance média
  exibirPainelEstatisticas(
    nome: 'Gimli',
    turnos: 28,
    hpFinal: 30,
    hpMax: 100,
    causa: 'Morte em combate',
  );

  print('');

  // Teste 3: Péssima performance
  exibirPainelEstatisticas(
    nome: 'Legolas',
    turnos: 5,
    hpFinal: 0,
    hpMax: 100,
    causa: 'Morreu no primeiro andar',
  );

  print('');

  // Teste 4: Performance excelente
  exibirPainelEstatisticas(
    nome: 'Gandalf',
    turnos: 120,
    hpFinal: 95,
    hpMax: 100,
    causa: 'Vitória definitiva após 2 horas',
  );
}

/// Exibe um painel com as estatísticas finais do jogo
void exibirPainelEstatisticas({
  required String nome,
  required int turnos,
  required int hpFinal,
  required int hpMax,
  required String causa,
}) {
  // Calcular métrica
  var danoTotal = hpMax - hpFinal;
  var porcentagemSaude = ((hpFinal / hpMax) * 100).toStringAsFixed(1);

  // Determinar nota usando operadores ternários
  // S: > 30 turnos e > 70% HP
  // A: > 20 turnos e > 40% HP
  // B: > 10 turnos e > 0% HP
  // C: <= 10 turnos (morreu rapido)
  var nota = turnos > 30 && hpFinal > (hpMax * 0.7)
      ? 'S'
      : turnos > 20 && hpFinal > (hpMax * 0.4)
          ? 'A'
          : turnos > 10 && hpFinal > 0
              ? 'B'
              : 'C';

  // Mensagem de desempenho
  var mensagem = nota == 'S'
      ? '⭐ HEROICO! Você foi magnífico!'
      : nota == 'A'
          ? '✨ Excelente desempenho!'
          : nota == 'B'
              ? '✓ Aceitável, mas poderia fazer melhor'
              : '✗ Fraco... A masmorra é cruel';

  // Emoji baseado na nota
  var emoji = nota == 'S'
      ? '👑'
      : nota == 'A'
          ? '⚔️'
          : nota == 'B'
              ? '*'
              : '💀';

  // Renderizar painel
  print('╔════════════════════════════════════════════════════════════╗');
  print('║                   ESTATÍSTICAS FINAIS                      ║');
  print('╠════════════════════════════════════════════════════════════╣');
  print(
      '║ Nome do Herói: ${_padDireita(nome, 47)} ║');
  print(
      '║ Causa: ${_padDireita(causa, 53)}║');
  print('║                                                            ║');
  print(
      '║ Turnos Sobrevividos: ${_padDireita(turnos.toString(), 40)} ║');
  print(
      '║ HP Final: ${_padDireita('$hpFinal/$hpMax ($porcentagemSaude%)', 47)} ║');
  print(
      '║ Dano Total Sofrido: ${_padDireita('$danoTotal/$hpMax', 42)} ║');
  print('║                                                            ║');
  print(
      '║ Nota Final: ${_padDireita('$nota', 48)} ║');
  print(
      '║ Desempenho: ${_padDireita(mensagem, 46)} ║');
  print('║ $emoji ${_padDireita('', 55)} ║');
  print('╠════════════════════════════════════════════════════════════╣');

  // Barra de HP visual
  var barraHP = _gerarBarraHP(hpFinal, hpMax);
  print('║ Saúde:  $barraHP');
  print('║ Status: ${_obterStatus(nota, hpFinal)}');

  print('╚════════════════════════════════════════════════════════════╝');
}

/// Gera uma barra visual de HP com caracteres
String _gerarBarraHP(int hpFinal, int hpMax) {
  var tamanhoMax = 45;
  var preenchido = ((hpFinal / hpMax) * tamanhoMax).toInt();
  var vazio = tamanhoMax - preenchido;

  var cor = hpFinal > (hpMax * 0.5)
      ? '🟩' // Verde
      : hpFinal > (hpMax * 0.25)
          ? '🟨' // Amarelo
          : '🟥'; // Vermelho

  var barra = cor * preenchido + '⬜' * vazio;
  return '$barra║';
}

/// Retorna status do jogador baseado em nota e HP
String _obterStatus(String nota, int hpFinal) {
  if (hpFinal <= 0) {
    return 'MORTO';
  } else if (nota == 'S') {
    return 'LENDÁRIO';
  } else if (nota == 'A') {
    return 'EXCELENTE';
  } else if (nota == 'B') {
    return 'ACEITÁVEL';
  } else {
    return 'FRACO';
  }
}

/// Função auxiliar para alinhar texto à direita
String _padDireita(String texto, int tamanho) {
  if (texto.length >= tamanho) {
    return texto.substring(0, tamanho);
  }
  return texto + ' ' * (tamanho - texto.length);
}

/// Versão simplificada (para console simples sem emojis)
void exibirPainelEstatisticasSimples({
  required String nome,
  required int turnos,
  required int hpFinal,
  required int hpMax,
}) {
  var nota = turnos > 30 && hpFinal > (hpMax * 0.7)
      ? 'S'
      : turnos > 20 && hpFinal > (hpMax * 0.4)
          ? 'A'
          : turnos > 10 && hpFinal > 0
              ? 'B'
              : 'C';

  print('═════════════════════════════════════════════════════════');
  print('NOME DO HERÓI: $nome');
  print('TURNOS: $turnos');
  print('HP: $hpFinal/$hpMax');
  print('NOTA: $nota');
  print('═════════════════════════════════════════════════════════');
}
