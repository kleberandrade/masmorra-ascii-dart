import '../model/enemy.dart';
import '../model/player.dart';

/// Cap. 14 — combate por turnos no terminal.
bool executarCombate({
  required Player jogador,
  required Enemy inimigo,
  required void Function(String) log,
}) {
  log('--- Combate: ${jogador.name} vs ${inimigo.nome} ---');
  while (jogador.hp > 0 && !inimigo.morto) {
    final d = jogador.danoAtual;
    inimigo.hp -= d;
    log('Acertas ${inimigo.nome} por $d (HP inimigo: ${inimigo.hp.clamp(0, 999)}).');
    if (inimigo.morto) {
      final ouro = 4 + inimigo.nome.length % 3;
      jogador.ouro += ouro;
      log('Venceste! +$ouro ouro.');
      return true;
    }
    inimigo.executarTurno(jogador, log);
  }
  return false;
}
