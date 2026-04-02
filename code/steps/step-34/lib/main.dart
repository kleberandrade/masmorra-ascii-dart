import 'modelos/inimigo.dart';
import 'padroes/acao.dart';
import 'padroes/estrategia_ia.dart';
import 'padroes/gerenciador_acoes.dart';

void main() {
  print('=== DEMONSTRAÇÃO: Strategy + Command Pattern ===\n');

  // ============ ESTRATÉGIAS ============
  print('--- Criando inimigos com diferentes estratégias ---');

  // Inimigo agressivo
  var inimigo1 = Inimigo(
    nome: 'Goblin Selvagem',
    hpMax: 30,
    ataque: 5,
    defesa: 1,
    estrategia: IAAgressiva(),
  );
  print('${inimigo1.nome}: HP ${inimigo1.hpAtual}/${inimigo1.hpMax} - Estratégia: AGRESSIVA');

  // Inimigo covarde
  var inimigo2 = Inimigo(
    nome: 'Goblin Astuto',
    hpMax: 25,
    ataque: 4,
    defesa: 0,
    estrategia: IACovardia(limiteHP: 40),
  );
  print('${inimigo2.nome}: HP ${inimigo2.hpAtual}/${inimigo2.hpMax} - Estratégia: COVARDIA');

  // Inimigo passivo
  var inimigo3 = Inimigo(
    nome: 'Zumbi Letárgico',
    hpMax: 50,
    ataque: 3,
    defesa: 2,
    estrategia: IAPassiva(),
  );
  print('${inimigo3.nome}: HP ${inimigo3.hpAtual}/${inimigo3.hpMax} - Estratégia: PASSIVA\n');

  // ============ STRATEGY PATTERN: DECIDINDO AÇÕES ============
  print('--- Estratégias decidem as ações ---');

  // Simular alvo
  var jogador = Inimigo(
    nome: 'Jogador',
    hpMax: 100,
    ataque: 6,
    defesa: 2,
    estrategia: IAAgressiva(),
  );

  // Agressivo: vai atacar sempre
  var acaoAgressiva = inimigo1.estrategia.decidir(inimigo1, jogador, null);
  print('${inimigo1.nome} (AGRESSIVA) decide: ${acaoAgressiva.descricao}');

  // Passivo: vai aguardar
  var acaoPassiva = inimigo3.estrategia.decidir(inimigo3, jogador, null);
  print('${inimigo3.nome} (PASSIVA) decide: ${acaoPassiva.descricao}');

  // Covarde com full HP: vai atacar
  var acaoCovarde1 = inimigo2.estrategia.decidir(inimigo2, jogador, null);
  print('${inimigo2.nome} (COVARDIA, 100% HP) decide: ${acaoCovarde1.descricao}');

  // Covarde ferido: vai fugir
  inimigo2.hpAtual = 10; // Ferido (40% do HP)
  var acaoCovarde2 = inimigo2.estrategia.decidir(inimigo2, jogador, null);
  print('${inimigo2.nome} (COVARDIA, 40% HP) decide: ${acaoCovarde2.descricao}\n');

  // ============ COMMAND PATTERN: UNDO/REDO ============
  print('--- Executando ações com histórico (Undo/Redo) ---');

  var gerenciador = GerenciadorAcoes();

  // Simular combate
  print('\nEstado inicial: ${jogador.nome} HP ${jogador.hpAtual}');

  // Ação 1: Goblin ataca
  var acao1 = AcaoAtacar(inimigo1, jogador);
  gerenciador.executar(acao1);
  print('Após ação 1: ${jogador.nome} HP ${jogador.hpAtual}');

  // Ação 2: Goblin ataca novamente
  var acao2 = AcaoAtacar(inimigo1, jogador);
  gerenciador.executar(acao2);
  print('Após ação 2: ${jogador.nome} HP ${jogador.hpAtual}');

  // Ação 3: Zumbi ataca
  var acao3 = AcaoAtacar(inimigo3, jogador);
  gerenciador.executar(acao3);
  print('Após ação 3: ${jogador.nome} HP ${jogador.hpAtual}');

  print('\nHistórico de ações:');
  for (var desc in gerenciador.obterHistorico()) {
    print('  • $desc');
  }

  print('\n--- Desfazendo (Undo) ---');
  gerenciador.desfazer();
  print('Após desfazer ação 3: ${jogador.nome} HP ${jogador.hpAtual}');
  print('Histórico: ${gerenciador.obterHistorico().length} ações');

  print('\n--- Desfazendo mais uma ---');
  gerenciador.desfazer();
  print('Após desfazer ação 2: ${jogador.nome} HP ${jogador.hpAtual}');

  print('\n--- Refazendo (Redo) ---');
  gerenciador.refazer();
  print('Após refazer ação 2: ${jogador.nome} HP ${jogador.hpAtual}');

  print('\nEstado final do jogador: HP ${jogador.hpAtual}');
  print('\n=== FIM DA DEMONSTRAÇÃO ===');
}
