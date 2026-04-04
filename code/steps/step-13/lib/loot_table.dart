import 'dart:math';
import 'item.dart';
import 'arma.dart';

final Map<String, List<Item>> lootTablePorInimigo = {
  'zumbi': [
    Item(
      id: 'moedas-sujas',
      nome: 'Moedas Sujas',
      descricao: 'Ouro roubado que o zumbi carregava',
      preco: 5,
      peso: 0,
    ),
    Arma(
      id: 'cutelo-enferrujado',
      nome: 'Cutelo Enferrujado',
      descricao: 'Uma arma pobre, mas cortante',
      preco: 40,
      peso: 2,
      dano: 4,
      tipo: 'cortante',
    ),
  ],
  'esqueleto': [
    Arma(
      id: 'sabre-ossudo',
      nome: 'Sabre do Túmulo',
      descricao: 'Arma de um cavaleiro há séculos falecido',
      preco: 120,
      peso: 3,
      dano: 9,
      tipo: 'cortante',
    ),
    Item(
      id: 'anel-prata',
      nome: 'Anel de Prata',
      descricao: 'Um adorno antigo, de valor incerto',
      preco: 80,
      peso: 0,
    ),
  ],
};

Item? obterLootAleatorio(String nomeDoInimigo) {
  final loot = lootTablePorInimigo[nomeDoInimigo];
  if (loot == null || loot.isEmpty) {
    return null;
  }

  final random = Random();
  return loot[random.nextInt(loot.length)];
}
