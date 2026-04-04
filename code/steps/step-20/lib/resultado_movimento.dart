import 'entidade.dart';
import 'entidade_escada.dart';
import 'inimigo.dart';
import 'item.dart';
import 'tipo_colisao.dart';

class ResultadoMovimento {
  final bool podeMovimentar;
  final TipoColisao tipo;
  final int? novoX;
  final int? novoY;
  final dynamic alvo;

  ResultadoMovimento._({
    required this.podeMovimentar,
    required this.tipo,
    this.novoX,
    this.novoY,
    this.alvo,
  });

  factory ResultadoMovimento.sucesso(int x, int y) => ResultadoMovimento._(
        podeMovimentar: true,
        tipo: TipoColisao.nenhuma,
        novoX: x,
        novoY: y,
      );

  factory ResultadoMovimento.colisaoParede() => ResultadoMovimento._(
        podeMovimentar: false,
        tipo: TipoColisao.parede,
      );

  factory ResultadoMovimento.colisaoInimigo(Inimigo inimigo) =>
      ResultadoMovimento._(
        podeMovimentar: false,
        tipo: TipoColisao.inimigo,
        alvo: inimigo,
      );

  factory ResultadoMovimento.colisaoItem(Item item, Entidade entidade) =>
      ResultadoMovimento._(
        podeMovimentar: false,
        tipo: TipoColisao.item,
        alvo: entidade,
      );

  factory ResultadoMovimento.colisaoEscada(EntidadeEscada escada) =>
      ResultadoMovimento._(
        podeMovimentar: false,
        tipo: TipoColisao.escada,
        alvo: escada,
      );

  factory ResultadoMovimento.colisaoDesconhecida() => ResultadoMovimento._(
        podeMovimentar: false,
        tipo: TipoColisao.outro,
      );
}
