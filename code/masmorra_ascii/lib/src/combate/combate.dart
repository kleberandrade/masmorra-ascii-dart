import '../modelos/inimigo.dart';
import '../modelos/jogador.dart';

/// Cap. 14 — combate por turnos no terminal.
bool executarCombate({
  required Jogador jogador,
  required Inimigo inimigo,
  required void Function(String) log,
}) {
  log('--- Combate: ${jogador.nome} vs ${inimigo.nome} ---');
  while (jogador.hp > 0 && !inimigo.morto) {
    final d = jogador.danoAtual;
    inimigo.hp -= d;
    log('Acertas ${inimigo.nome} por $d (HP inimigo: ${inimigo.hp.clamp(0, 999)}).');
    if (inimigo.morto) {
      final ouro = 4 + inimigo.nome.length % 3;
      jogador.ouro += ouro;
      log('Venceu! +$ouro ouro.');
      return true;
    }
    inimigo.executarTurno(jogador, log);
  }
  return false;
}
