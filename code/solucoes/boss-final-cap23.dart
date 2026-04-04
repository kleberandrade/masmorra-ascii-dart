// ============================================================================
// Capítulo 23 - Boss Final: Itens Únicos e Valiosos
// ============================================================================
// Exercício: Sistema de Itens Raros com Estoque Limitado
//
// Implementa itens lendários que aparecem apenas 1 vez por andar.
// Quando comprados, desaparecem, mas reaparecem no próximo andar.
// Itens normais sempre têm estoque completo.
// Demonstra estado dinâmico, raridade e economia de loja.
// ============================================================================

// Enumeração de raridade de itens
enum RaridadeItem {
  comum,
  rara,
  lendaria,
}

// Classe que representa um item à venda
class ItemVenda {
  final String id;
  final String nome;
  final String descricao;
  final int precoBase;
  final RaridadeItem raridade;
  final bool ehRaro;

  int _quantidadeAtual;
  final int _quantidadeMax;

  ItemVenda({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.precoBase,
    required this.raridade,
    required int quantidadeMax,
    this.ehRaro = false,
  })  : _quantidadeAtual = quantidadeMax,
        _quantidadeMax = quantidadeMax;

  // Preço ajustado pela raridade
  int get precoAjustado {
    return switch (raridade) {
      RaridadeItem.comum => precoBase,
      RaridadeItem.rara => (precoBase * 2.5).toInt(),
      RaridadeItem.lendaria => (precoBase * 5.0).toInt(),
    };
  }

  // Verifica se há estoque disponível
  bool get temEstoque => _quantidadeAtual > 0;

  // Obtém quantidade em estoque
  int get quantidade => _quantidadeAtual;

  // Remove do estoque (quando comprado)
  void comprar() {
    if (_quantidadeAtual > 0) {
      _quantidadeAtual--;
    }
  }

  // Restaura estoque ao máximo (próximo andar)
  void restaurarEstoque() {
    _quantidadeAtual = _quantidadeMax;
  }

  // String descritiva para exibição
  String get descricaoLoja {
    final status = temEstoque ? '✓' : '✗ (fora)';
    return '$nome [$status] - ${precoAjustado} ouro (Raridade: ${raridade.name})';
  }
}

// Gerenciador de loja com itens únicos e raros
class LojaComItensUnicos {
  final List<ItemVenda> catalogo;
  int andarAtual = 0;

  LojaComItensUnicos({
    required this.catalogo,
  });

  // Restaura estoque: itens normais sempre, itens raros apenas 1x
  void restoquearParaAndar(int novoAndar) {
    andarAtual = novoAndar;

    for (final item in catalogo) {
      if (item.ehRaro) {
        // Itens raros sempre volta a 1 no novo andar
        item.restaurarEstoque();
      } else {
        // Itens normais sempre têm estoque pleno
        item.restaurarEstoque();
      }
    }
  }

  // Compra um item por índice
  String comprar(int indice, {required int ouroDisponivel}) {
    if (indice < 0 || indice >= catalogo.length) {
      return '❌ Item inválido!';
    }

    final item = catalogo[indice];

    if (!item.temEstoque) {
      return '❌ ${item.nome} está fora de estoque!';
    }

    if (ouroDisponivel < item.precoAjustado) {
      return '❌ Ouro insuficiente! Precisa de ${item.precoAjustado}, tem $ouroDisponivel.';
    }

    item.comprar();
    return '✓ Comprou ${item.nome} por ${item.precoAjustado} ouro!';
  }

  // Exibe catálogo da loja
  void exibirCatalogo() {
    print('\n╔════════════════════════════════════════════════════════════╗');
    print('║              LOJA DO MERCADOR - Andar $andarAtual');
    print('╠════════════════════════════════════════════════════════════╣');

    for (int i = 0; i < catalogo.length; i++) {
      final item = catalogo[i];
      final emoji = switch (item.raridade) {
        RaridadeItem.comum => '○',
        RaridadeItem.rara => '◆',
        RaridadeItem.lendaria => '★',
      };

      print('║ [$i] $emoji ${item.descricaoLoja}');
      if (item.ehRaro) {
        print('║     └─ [ÚNICO POR ANDAR] Reaparece no próximo nível');
      }
    }

    print('╚════════════════════════════════════════════════════════════╝');
  }

  // Resumo de estoque
  String resumoEstoque() {
    final disponiveis = catalogo.where((i) => i.temEstoque).length;
    return 'Itens disponíveis: $disponiveis/${catalogo.length}';
  }
}

// ============================================================================
// Demonstração completa do sistema
// ============================================================================

void main() {
  print('\n════════════════════════════════════════════════════════════');
  print('  MASMORRA ASCII - Capítulo 23: Itens Únicos e Valiosos');
  print('════════════════════════════════════════════════════════════\n');

  // Criar catálogo de itens
  final catalogo = [
    // Itens comuns: sempre disponível
    ItemVenda(
      id: 'pocao_vida',
      nome: 'Poção de Vida',
      descricao: 'Restaura 30 HP',
      precoBase: 50,
      raridade: RaridadeItem.comum,
      quantidadeMax: 5,
      ehRaro: false,
    ),

    // Itens raros: 1 por andar
    ItemVenda(
      id: 'espada_aco',
      nome: 'Espada de Aço Lendária',
      descricao: 'Lâmina forjada na antiguidade. +5 ATK',
      precoBase: 100,
      raridade: RaridadeItem.rara,
      quantidadeMax: 1,
      ehRaro: true,
    ),

    // Itens lendários: 1 por andar, muito caros
    ItemVenda(
      id: 'anel_imortalidade',
      nome: 'Anel de Imortalidade',
      descricao: 'Impede morte uma vez. Poder absoluto.',
      precoBase: 500,
      raridade: RaridadeItem.lendaria,
      quantidadeMax: 1,
      ehRaro: true,
    ),

    // Mais um item comum
    ItemVenda(
      id: 'pocao_mana',
      nome: 'Poção de Mana',
      descricao: 'Restaura 20 mana',
      precoBase: 30,
      raridade: RaridadeItem.comum,
      quantidadeMax: 3,
      ehRaro: false,
    ),
  ];

  final loja = LojaComItensUnicos(catalogo: catalogo);

  // ======================================================================
  // TESTE 1: Primeiro andar - todos os itens disponíveis
  // ======================================================================
  print('🔍 TESTE 1: Andar 1 - Itens Disponíveis');
  print('───────────────────────────────────────────────────────────');
  loja.restoquearParaAndar(1);
  loja.exibirCatalogo();
  print(loja.resumoEstoque());

  // ======================================================================
  // TESTE 2: Comprar itens raros
  // ======================================================================
  print('\n🔍 TESTE 2: Comprando Itens Raros');
  print('───────────────────────────────────────────────────────────');

  var resultado = loja.comprar(1, ouroDisponivel: 300); // Espada
  print('Tentativa 1: $resultado');

  resultado = loja.comprar(1, ouroDisponivel: 250); // Sem ouro
  print('Tentativa 2: $resultado');

  resultado = loja.comprar(1, ouroDisponivel: 300); // Tenta comprar de novo
  print('Tentativa 3 (item já comprado): $resultado');

  // ======================================================================
  // TESTE 3: Itens normais sempre têm estoque
  // ======================================================================
  print('\n🔍 TESTE 3: Itens Normais - Sempre em Estoque');
  print('───────────────────────────────────────────────────────────');

  resultado = loja.comprar(0, ouroDisponivel: 100); // Poção de vida
  print('Compra 1: $resultado');

  resultado = loja.comprar(0, ouroDisponivel: 100); // Poção novamente
  print('Compra 2: $resultado');

  print('${catalogo[0].nome} ainda tem ${catalogo[0].quantidade} em estoque');

  // ======================================================================
  // TESTE 4: Descer um andar - itens raros reaparecem
  // ======================================================================
  print('\n🔍 TESTE 4: Andar 2 - Itens Raros Reaprecem');
  print('───────────────────────────────────────────────────────────');
  loja.restoquearParaAndar(2);
  loja.exibirCatalogo();
  print(loja.resumoEstoque());

  print('\nVerificação: Espada Lendária voltou? ${catalogo[1].temEstoque ? '✓ SIM' : '✗ NÃO'}');

  // ======================================================================
  // TESTE 5: Comparação de preços por raridade
  // ======================================================================
  print('\n🔍 TESTE 5: Impacto da Raridade nos Preços');
  print('───────────────────────────────────────────────────────────');

  for (final item in catalogo) {
    final precoRaw = item.precoBase;
    final precoFinal = item.precoAjustado;
    final multiplicador = (precoFinal / precoRaw).toStringAsFixed(2);

    print('${item.nome}');
    print('  Preço Base: $precoRaw → Preço Ajustado: $precoFinal (x$multiplicador)');
  }

  // ======================================================================
  // TESTE 6: Descida por vários andares
  // ======================================================================
  print('\n🔍 TESTE 6: Jornada por 5 Andares');
  print('───────────────────────────────────────────────────────────');

  for (int andar = 1; andar <= 5; andar++) {
    loja.restoquearParaAndar(andar);
    final raro = catalogo[1]; // Espada
    final lendario = catalogo[2]; // Anel
    final raroStatus = raro.temEstoque ? 'disponível' : 'vendido';
    final lendarioStatus = lendario.temEstoque ? 'disponível' : 'vendido';

    print('Andar $andar: Espada ($raroStatus) | Anel ($lendarioStatus)');

    // Simular compra do item raro
    if (raro.temEstoque) {
      raro.comprar();
    }
  }

  print('\n════════════════════════════════════════════════════════════');
  print('  ★ Itens únicos reaparecem a cada andar!');
  print('════════════════════════════════════════════════════════════\n');
}
