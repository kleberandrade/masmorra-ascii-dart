import 'package:step_20_entidades/andar_masmorra.dart';

import 'entidade.dart';
import 'inimigo.dart';
import 'jogador.dart';
import 'resultado_movimento.dart';
import 'tipo_colisao.dart';

class ProcessadorInteracao {
  void processarColisao(
    ResultadoMovimento resultado,
    Jogador jogador,
    AndarMasmorra andar,
    void Function(String) logCallback,
  ) {
    switch (resultado.tipo) {
      case TipoColisao.nenhuma:
        break;

      case TipoColisao.parede:
        logCallback('Você bateu numa parede!');
        break;

      case TipoColisao.inimigo:
        final inimigo = resultado.alvo as Inimigo;
        logCallback('Você encontrou um ${inimigo.nome}! Luta!');
        break;

      case TipoColisao.item:
        final entidade = resultado.alvo as Entidade;
        final foiColetado = entidade.aoTocada(jogador);
        if (foiColetado) {
          logCallback('Você coletou ${entidade.nome}!');
          andar.removerEntidade(entidade);
        }
        break;

      case TipoColisao.escada:
        logCallback('Você encontrou a escada! Digite "d" para descer.');
        break;

      case TipoColisao.outro:
        logCallback('Algo estranho aqui...');
        break;
    }
  }
}
