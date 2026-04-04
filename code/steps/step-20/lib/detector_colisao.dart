import 'andar_masmorra.dart';
import 'entidade_escada.dart';
import 'entidade_inimigo.dart';
import 'entidade_item.dart';
import 'jogador.dart';
import 'resultado_movimento.dart';

class DetectorColisao {
  ResultadoMovimento verificarMovimento(
    int novoX,
    int novoY,
    Jogador jogador,
    AndarMasmorra andar,
  ) {
    if (!andar.mapa.ehPassavel(novoX, novoY)) {
      return ResultadoMovimento.colisaoParede();
    }

    final entidade = andar.encontrarEntidadeEm(novoX, novoY);

    if (entidade == null) {
      return ResultadoMovimento.sucesso(novoX, novoY);
    }

    return switch (entidade) {
      EntidadeInimigo enemyEnt =>
        ResultadoMovimento.colisaoInimigo(enemyEnt.inimigo),
      EntidadeItem itemEnt =>
        ResultadoMovimento.colisaoItem(itemEnt.item, entidade),
      EntidadeEscada escadaEnt =>
        ResultadoMovimento.colisaoEscada(escadaEnt),
      _ => ResultadoMovimento.colisaoDesconhecida(),
    };
  }
}
