import 'jogador.dart';
import 'mercador.dart';

/// Renderiza a interface da loja
class LojaRenderer {
  final int largura;
  final int altura;

  LojaRenderer({
    this.largura = 80,
    this.altura = 24,
  });

  void renderizar(Jogador jogador, Mercador mercador) {
    _desenharCabecalho(mercador);
    _desenharColunasCompraVenda(jogador, mercador);
    _desenharHud(jogador);
  }

  void _desenharCabecalho(Mercador mercador) {
    print('═' * largura);
    print('║ LOJA DO ${mercador.nome.toUpperCase()} ║');
    print('═' * largura);
  }

  void _desenharColunasCompraVenda(Jogador jogador, Mercador mercador) {
    print('\n COMPRAR NA LOJA');
    print('─' * 40);

    for (int i = 0; i < mercador.inventario.length; i++) {
      final item = mercador.inventario[i];
      final linha =
          '[$i] ${item.item.nome} --- ${item.precoCompra} ouro (${item.quantidade})';

      if (!item.temEstoque) {
        print('(fora de estoque) $linha');
      } else {
        print(linha);
      }
    }

    print('\n TEU INVENTÁRIO');
    print('─' * 40);

    for (int i = 0; i < jogador.inventario.length; i++) {
      final item = jogador.inventario[i];
      final precoVenda = (item.preco ?? 0) ~/ 2;
      final linha = '[$i] ${item.nome} (⌬$precoVenda ouro)';
      print(linha);
    }

    if (jogador.inventario.isEmpty) {
      print('(vazio)');
    }
  }

  void _desenharHud(Jogador jogador) {
    print('\n┌─ STATUS ─────────────────────────┐');
    print('│ Ouro: ${jogador.ouro.toString().padLeft(6)}  '
        'HP: ${jogador.hp}/${jogador.maxHp}');
    print('│ Inventário: ${jogador.inventario.length}/'
        '${jogador.tamanhoInventario}');
    print('└────────────────────────────────────┘');

    print('Digita: [C]omprar [nº] | [V]ender [nº] | [S]air | [A]juda');
  }
}
