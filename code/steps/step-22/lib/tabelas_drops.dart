import 'entrada_saque.dart';

/// Tabelas de drops padrão para todos os tipos de inimigo
class TabelasDrops {
  static Map<String, List<EntradaSaque>> criar() {
    return {
      'Zumbi': [
        EntradaSaque(
          itemId: 'ouro',
          chance: 1.0,
          quantidadeMin: 3,
          quantidadeMax: 8,
          nomeItem: 'Moedas de ouro',
        ),
        EntradaSaque(
          itemId: 'adaga_velha',
          chance: 0.15,
          quantidadeMin: 1,
          quantidadeMax: 1,
          nomeItem: 'Adaga velha',
        ),
      ],
      'Lobo': [
        EntradaSaque(
          itemId: 'ouro',
          chance: 0.9,
          quantidadeMin: 5,
          quantidadeMax: 15,
          nomeItem: 'Moedas de ouro',
        ),
        EntradaSaque(
          itemId: 'espada_ferro',
          chance: 0.25,
          quantidadeMin: 1,
          quantidadeMax: 1,
          nomeItem: 'Espada de ferro',
        ),
        EntradaSaque(
          itemId: 'pocao_vida',
          chance: 0.1,
          quantidadeMin: 1,
          quantidadeMax: 2,
          nomeItem: 'Poção de vida',
        ),
      ],
      'Orc': [
        EntradaSaque(
          itemId: 'ouro',
          chance: 0.95,
          quantidadeMin: 15,
          quantidadeMax: 30,
          nomeItem: 'Moedas de ouro',
        ),
        EntradaSaque(
          itemId: 'espada_aco',
          chance: 0.35,
          quantidadeMin: 1,
          quantidadeMax: 1,
          nomeItem: 'Espada de aço',
        ),
        EntradaSaque(
          itemId: 'armadura_ferro',
          chance: 0.2,
          quantidadeMin: 1,
          quantidadeMax: 1,
          nomeItem: 'Armadura de ferro',
        ),
      ],
    };
  }
}
