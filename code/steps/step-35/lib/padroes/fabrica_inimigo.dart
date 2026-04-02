import 'dart:math';
import '../modelos/inimigo.dart';
import 'estrategia_ia.dart';

/// Definição de tipo de inimigo
class DefinicaoInimigo {
  final String nome;
  final int hpBase;
  final int danoBase;
  final int defesaBase;
  final double raridade;
  final EstrategiaIA estrategia;

  DefinicaoInimigo({
    required this.nome,
    required this.hpBase,
    required this.danoBase,
    required this.defesaBase,
    required this.raridade,
    required this.estrategia,
  });
}

/// Factory centralizada para criar inimigos
class FabricaInimigo {
  static final Map<String, DefinicaoInimigo> catalogo = {
    'zumbi': DefinicaoInimigo(
      nome: 'Zumbi',
      hpBase: 15,
      danoBase: 2,
      defesaBase: 0,
      raridade: 0.4,
      estrategia: IAPassiva(),
    ),
    'lobo': DefinicaoInimigo(
      nome: 'Lobo',
      hpBase: 25,
      danoBase: 5,
      defesaBase: 1,
      raridade: 0.35,
      estrategia: IAAgressiva(),
    ),
    'goblin': DefinicaoInimigo(
      nome: 'Goblin',
      hpBase: 20,
      danoBase: 3,
      defesaBase: 0,
      raridade: 0.25,
      estrategia: IACovardia(),
    ),
  };

  /// Cria inimigo de tipo específico, escalando por andar
  static Inimigo criar(String tipo, int andar) {
    final def = catalogo[tipo];
    if (def == null) throw ArgumentError('Tipo desconhecido: $tipo');

    int hpFinal = def.hpBase + (andar * 3);
    int danoFinal = def.danoBase + (andar * 1);
    int defesaFinal = def.defesaBase + (andar ~/ 3);

    return Inimigo(
      nome: def.nome,
      hpMax: hpFinal,
      ataque: danoFinal,
      defesa: defesaFinal,
      estrategia: def.estrategia,
    );
  }

  /// Cria inimigo aleatório com raridade
  static Inimigo criarAleatorio(int andar) {
    double sorteio = Random().nextDouble();
    double acumulado = 0.0;

    for (var entrada in catalogo.entries) {
      acumulado += entrada.value.raridade;
      if (sorteio < acumulado) {
        return criar(entrada.key, andar);
      }
    }

    return criar('zumbi', andar);
  }
}
