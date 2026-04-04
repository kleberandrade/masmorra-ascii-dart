import 'padroes/fabrica_inimigo.dart';
import 'padroes/barramento_eventos.dart';

void main() async {
  print('=== DEMONSTRAÇÃO: Factory + Observer Pattern ===\n');

  // ============ FACTORY PATTERN ============
  print('--- Criando inimigos com FabricaInimigo em diferentes andares ---');

  // Criar inimigos específicos em diferentes andares
  var zumbiAndar1 = FabricaInimigo.criar('zumbi', 1);
  print('${zumbiAndar1.nome} (Andar 1): HP ${zumbiAndar1.hpAtual}, Ataque ${zumbiAndar1.ataque}, Defesa ${zumbiAndar1.defesa}');

  var loboAndar3 = FabricaInimigo.criar('lobo', 3);
  print('${loboAndar3.nome} (Andar 3): HP ${loboAndar3.hpAtual}, Ataque ${loboAndar3.ataque}, Defesa ${loboAndar3.defesa}');

  var goblinAndar5 = FabricaInimigo.criar('goblin', 5);
  print('${goblinAndar5.nome} (Andar 5): HP ${goblinAndar5.hpAtual}, Ataque ${goblinAndar5.ataque}, Defesa ${goblinAndar5.defesa}\n');

  // Criar inimigos aleatórios
  print('--- Gerando inimigos aleatórios em diferentes andares ---');
  for (int andar = 1; andar <= 3; andar++) {
    var inimigo = FabricaInimigo.criarAleatorio(andar);
    print('Andar $andar: ${inimigo.nome} (HP ${inimigo.hpAtual})');
  }

  print('\n--- Configurando Observer Pattern com BarramentoEventos ---');

  // ============ OBSERVER PATTERN: BARRAMENTO DE EVENTOS ============
  var barramento = BarramentoEventos();

  // Criar observadores
  var observadorLog = ObservadorLog(barramento);
  var observadorEstat = ObservadorEstatisticas(barramento);

  print('Observadores registrados:');
  print('  • ObservadorLog');
  print('  • ObservadorEstatisticas\n');

  // ============ EMITINDO EVENTOS ============
  print('--- Emitindo eventos de combate ---\n');

  // Evento 1: Dano aplicado
  print('[EVENTO] Aplicando dano...');
  var eventoDano1 = EventoDanoAplicado(
    atacante: 'Lobo',
    alvo: 'Jogador',
    dano: 8,
  );
  barramento.emitir(eventoDano1);
  await Future<void>.delayed(const Duration(milliseconds: 100));

  // Evento 2: Outro dano
  print('[EVENTO] Aplicando mais dano...');
  var eventoDano2 = EventoDanoAplicado(
    atacante: 'Goblin',
    alvo: 'Jogador',
    dano: 5,
  );
  barramento.emitir(eventoDano2);
  await Future<void>.delayed(const Duration(milliseconds: 100));

  // Evento 3: Morte de inimigo
  print('[EVENTO] Inimigo derrotado...');
  var eventoMorte = EventoMorteInimigo(
    nomeInimigo: 'Zumbi',
    xpRecompensa: 50,
  );
  barramento.emitir(eventoMorte);
  await Future<void>.delayed(const Duration(milliseconds: 100));

  // Evento 4: Mais dano
  print('[EVENTO] Aplicando último dano...');
  var eventoDano3 = EventoDanoAplicado(
    atacante: 'Lobo',
    alvo: 'Jogador',
    dano: 3,
  );
  barramento.emitir(eventoDano3);
  await Future<void>.delayed(const Duration(milliseconds: 100));

  print('\n--- Estatísticas Coletadas ---');
  print('Total de inimigos derrotados: ${observadorEstat.totalMatos}');
  print('Dano total recebido: ${observadorEstat.danoTotal}');
  print('Dano médio por ataque: ${(observadorEstat.danoTotal / 3).toStringAsFixed(2)}');

  // Limpar observadores
  observadorLog.cancelar();
  observadorEstat.cancelar();
  barramento.fechar();

  print('\n=== FIM DA DEMONSTRAÇÃO ===');
}
