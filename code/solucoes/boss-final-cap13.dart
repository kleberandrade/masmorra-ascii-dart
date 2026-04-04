/// Boss Final Capítulo 13: Sistema de Loja
///
/// Objetivo: Criar uma classe Loja com métodos para vender ao jogador
/// e comprar do jogador, aplicando markup. Demonstrar uma loja funcional.
///
/// Conceitos abordados:
/// - Classe com estado (estoque, preço)
/// - Métodos que modificam estado
/// - Validação de transações
/// - List genérico com Item
/// - Lógica de compra/venda
///
/// Instruções:
/// 1. Execute este arquivo com: dart boss-final-cap13.dart
/// 2. Observe as transações da loja
/// 3. Teste compra com ouro insuficiente
/// 4. Venda de itens do inventário
///
/// Resultado esperado: Loja funcional com sistema de compra/venda

void main() {
  print('═══════════════════════════════════════════════════════════');
  print('  Boss Final Capítulo 13: Sistema de Loja');
  print('═══════════════════════════════════════════════════════════');
  print('');

  // Criar jogador com ouro inicial
  var jogador = Jogador(nome: 'Herói', ouro: 500, hpMax: 100);

  // Criar loja com itens
  var loja = Loja(
    nome: 'Forja do Senhor das Armas',
    taxaMarcup: 1.5, // 50% mais caro que o preço base
  );

  // Adicionar itens ao estoque
  loja.adicionarItem(Item(id: 'espada', nome: 'Espada de Ferro', precoBase: 100));
  loja.adicionarItem(
      Item(id: 'escudo', nome: 'Escudo de Carvalho', precoBase: 80));
  loja.adicionarItem(Item(id: 'pocao', nome: 'Poção de Vida', precoBase: 50));
  loja.adicionarItem(
      Item(id: 'helm', nome: 'Elmo de Aço', precoBase: 120));

  print('TESTE 1: Estado inicial');
  print('  Jogador: ${jogador.nome}');
  print('  Ouro disponível: ${jogador.ouro}g');
  print('  Inventário: ${jogador.inventario.isEmpty ? '(vazio)' : jogador.inventario.map((i) => i.nome).join(', ')}');
  print('');

  print('TESTE 2: Ver itens da loja');
  loja.listarItens();
  print('');

  print('TESTE 3: Comprar Espada de Ferro (preço com markup: 150g)');
  var sucesso = loja.venderAoJogador(jogador, 0);
  if (sucesso) {
    print('  ✓ Compra bem-sucedida!');
    print('  Ouro restante: ${jogador.ouro}g');
    print('  Inventário: ${jogador.inventario.map((i) => i.nome).join(', ')}');
  } else {
    print('  ✗ Compra falhou!');
  }
  print('');

  print('TESTE 4: Comprar Escudo (preço com markup: 120g)');
  sucesso = loja.venderAoJogador(jogador, 1);
  if (sucesso) {
    print('  ✓ Compra bem-sucedida!');
    print('  Ouro restante: ${jogador.ouro}g');
    print('  Inventário: ${jogador.inventario.map((i) => i.nome).join(', ')}');
  }
  print('');

  print('TESTE 5: Tentar comprar Elmo (precisa de 180g, tem ${jogador.ouro}g)');
  sucesso = loja.venderAoJogador(jogador, 3);
  if (!sucesso) {
    print('  ✗ Ouro insuficiente! Transação cancelada.');
  }
  print('');

  print('TESTE 6: Vender item do inventário (Espada por 50g = 50% do preço)');
  sucesso = loja.comprarDoJogador(jogador, 0);
  if (sucesso) {
    print('  ✓ Venda bem-sucedida!');
    print('  Ouro agora: ${jogador.ouro}g');
    print('  Inventário: ${jogador.inventario.isEmpty ? '(vazio)' : jogador.inventario.map((i) => i.nome).join(', ')}');
  }
  print('');

  print('═══════════════════════════════════════════════════════════');
  print('  Loja: Sistema funcional de compra e venda');
  print('═══════════════════════════════════════════════════════════');
}

/// Classe Item para representar produtos
class Item {
  final String id;
  final String nome;
  final double precoBase;

  Item({
    required this.id,
    required this.nome,
    required this.precoBase,
  });

  @override
  String toString() => '$nome (${precoBase}g)';
}

/// Classe Jogador para gerenciar ouro e inventário
class Jogador {
  final String nome;
  double ouro;
  int hpMax;
  List<Item> inventario = [];

  Jogador({
    required this.nome,
    required this.ouro,
    required this.hpMax,
  });

  /// Adicionar ouro
  void ganharOuro(double quantidade) {
    ouro += quantidade;
  }

  /// Remover ouro (com validação)
  bool gastarOuro(double quantidade) {
    if (ouro >= quantidade) {
      ouro -= quantidade;
      return true;
    }
    return false;
  }

  /// Adicionar item ao inventário
  void adicionarItem(Item item) {
    inventario.add(item);
  }

  /// Remover item do inventário (por índice)
  bool removerItem(int indice) {
    if (indice >= 0 && indice < inventario.length) {
      inventario.removeAt(indice);
      return true;
    }
    return false;
  }
}

/// Classe Loja para gerenciar vendas
class Loja {
  final String nome;
  final double taxaMarcup; // Multiplicador de preço (ex: 1.5 = 50% mais caro)
  List<Item> estoque = [];

  Loja({
    required this.nome,
    required this.taxaMarcup,
  });

  /// Adicionar item ao estoque
  void adicionarItem(Item item) {
    estoque.add(item);
  }

  /// Listar itens disponíveis com preços
  void listarItens() {
    print('Loja: $nome');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    for (var i = 0; i < estoque.length; i++) {
      var item = estoque[i];
      var precoComMarkup = (item.precoBase * taxaMarcup).toStringAsFixed(0);
      print('[$i] ${item.nome.padRight(25)} ${precoComMarkup}g');
    }
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  /// Vender item ao jogador
  /// Retorna true se a venda foi bem-sucedida
  bool venderAoJogador(Jogador jogador, int indiceEstoque) {
    if (indiceEstoque < 0 || indiceEstoque >= estoque.length) {
      print('Item inválido!');
      return false;
    }

    var item = estoque[indiceEstoque];
    var precoComMarkup = item.precoBase * taxaMarcup;

    // Verificar se jogador tem ouro suficiente
    if (jogador.gastarOuro(precoComMarkup)) {
      jogador.adicionarItem(item);
      return true;
    }

    print('Ouro insuficiente! Precisa de ${precoComMarkup.toStringAsFixed(0)}g');
    return false;
  }

  /// Comprar item do jogador
  /// Retorna true se a compra foi bem-sucedida
  bool comprarDoJogador(Jogador jogador, int indiceInventario) {
    if (indiceInventario < 0 ||
        indiceInventario >= jogador.inventario.length) {
      print('Item não encontrado no inventário!');
      return false;
    }

    var item = jogador.inventario[indiceInventario];
    // Pagar 50% do preço base ao comprar de volta
    var precoCompra = item.precoBase * 0.5;

    if (jogador.removerItem(indiceInventario)) {
      jogador.ganharOuro(precoCompra);
      return true;
    }

    return false;
  }

  /// Obter preço com markup de um item
  double obterPreco(Item item) {
    return item.precoBase * taxaMarcup;
  }

  /// Verificar se item está em estoque (por id)
  bool temItem(String itemId) {
    return estoque.any((item) => item.id == itemId);
  }
}
