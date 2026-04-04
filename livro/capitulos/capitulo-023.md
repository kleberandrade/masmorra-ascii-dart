# Capítulo 23 - A Loja do Mercador: UI e Fluxo

> *Entrou numa loja. O ar cheira a madeira antiga e moedas de ouro. Atrás do balcão, um homem de barba cinzenta sorri. "O que quer comprar?" As armas brilham na parede. As poções estão arrumadas em prateleiras. Este é o espaço de respiração do roguelike onde você estratégia: que armadura devo carregar? Quanto ouro devo guardar? Vale a pena vender isto agora? Aqui a economia ganha presença física e interface clara.*

## O Que Vamos Aprender

Neste capítulo você vai:

- Modelar a classe `Mercador` e seu inventário (`ItemVenda`)
- Criar a UI ASCII da loja: layout com colunas, listas, preços
- Implementar compra (se ouro >= preço) e venda (se item em inventário)
- Gerenciar modo loja vs modo exploração: dois estados de jogo distintos
- Validar operações: não deixar comprar sem ouro, não vender o que não tem
- Implementar restocking: a loja muda de items a cada andar/visita
- Integrar loja no fluxo de jogo: entrada por sala especial, saída natural
- Renderizar feedback visual: "Comprado!", "Sem ouro!", "Inventário cheio!"

Ao final, você terá uma loja completa e jogável que funciona como uma entidade real do jogo.

## O Conceito da Loja

A loja é mais que um menu. É uma experiência completa:

1. Uma sala física; você entra por ação específica (digita `shop` ou pisa numa sala especial marcada)
2. Um estado de jogo distinto; não há movimento ou combate, apenas compra/venda
3. Inventário dinâmico; muda a cada andar ou a cada visita, oferecendo itens progressivamente melhores
4. Interface clara e contextual; lista de items à venda, lista de seus items, preços visíveis
5. Transações validadas; compra com verificação de ouro, venda com verificação de inventário

## Classe ItemVenda e Inventário do Mercador

Um item à venda não é só um `Item`. Tem um preço e uma quantidade em estoque. A classe `ItemVenda` encapsula isto: o item, quanto custa, quantos estão disponíveis. Oferece métodos para remover do estoque (quando você compra) e verificar se ainda tem estoque disponível.

```dart
// lib/item_venda.dart

import 'item.dart';

/// Um item no inventário da loja (com preço e quantidade)
class ItemVenda {
  final Item item;
  final int precoCompra;
  int quantidade;

  ItemVenda({
    required this.item,
    required this.precoCompra,
    required this.quantidade,
  });

  int get precoVenda => (precoCompra * 0.5).toInt();
  bool get temEstoque => quantidade > 0;

  void removerDoEstoque() {
    if (quantidade > 0) quantidade--;
  }

  void adicionarAoEstoque() {
    quantidade++;
  }

  @override
  String toString() =>
      '${item.nome} ($precoCompra ouro) × $quantidade';
}
```

## Classe Mercador

O `Mercador` gerencia transações e seu inventário:

```dart
// lib/mercador.dart

import 'jogador.dart';
import 'item.dart';
import 'economia.dart';
import 'item_venda.dart';

/// O comerciante da loja
class Mercador {
  List<ItemVenda> inventario;
  final Economia economia;
  final String nome;

  Mercador({
    required this.inventario,
    required this.economia,
    this.nome = 'Mestre Aldwin',
  });

  /// Compra um item do inventário da loja
  String comprar(Jogador jogador, int indiceItem) {
    if (indiceItem < 0 || indiceItem >= inventario.length) {
      return 'Item inválido!';
    }

    final itemVenda = inventario[indiceItem];

    if (!itemVenda.temEstoque) {
      return '${itemVenda.item.nome} está em falta.';
    }

    if (jogador.ouro < itemVenda.precoCompra) {
      return 'Você não tem ouro suficiente (custo: ${itemVenda.precoCompra})';
    }

    if (jogador.inventario.length >= jogador.tamanhoInventario) {
      return 'Inventário cheio!';
    }

    jogador.ouro -= itemVenda.precoCompra;
    jogador.adicionarItem(itemVenda.item);
    itemVenda.removerDoEstoque();

    return '${itemVenda.item.nome} comprado por ${itemVenda.precoCompra} ouro!';
  }

  /// Vende um item do inventário do jogador para a loja
  String vender(Jogador jogador, int indiceItem) {
    if (indiceItem < 0 || indiceItem >= jogador.inventario.length) {
      return 'Item inválido!';
    }

    final item = jogador.inventario[indiceItem];
    final precoVenda = economia.precoVenda(item.id);

    if (precoVenda <= 0) {
      return 'Este item não tem valor!';
    }

    jogador.ouro += precoVenda;
    jogador.inventario.removeAt(indiceItem);
    _adicionarAoEstoqueDaLoja(item, precoVenda);

    return '${item.nome} vendido por $precoVenda ouro!';
  }

  void _adicionarAoEstoqueDaLoja(Item item, int preco) {
    final existe = inventario.firstWhereOrNull(
      (iv) => iv.item.id == item.id,
    );

    if (existe != null) {
      existe.adicionarAoEstoque();
    } else {
      inventario.add(ItemVenda(
        item: item,
        precoCompra: preco,
        quantidade: 1,
      ));
    }
  }

  /// Restoque da loja com novos itens
  void restoquear(int andarNumero) {
    inventario.clear();
    inventario.addAll(_inventarioBase());

    if (andarNumero >= 3) {
      inventario.addAll(_inventarioAndarAvancado());
    }
    if (andarNumero >= 7) {
      inventario.addAll(_inventarioAndarMuitoAvancado());
    }
  }

  List<ItemVenda> _inventarioBase() {
    return [
      ItemVenda(
        item: Item(
          id: 'pocao_vida',
          nome: 'Poção de vida',
          descricao: 'Restaura 20 HP quando usada.',
        ),
        precoCompra: 25,
        quantidade: 5,
      ),
      ItemVenda(
        item: Item(
          id: 'pocao_mana',
          nome: 'Poção de mana',
          descricao: 'Restaura 10 mana quando usada.',
        ),
        precoCompra: 15,
        quantidade: 3,
      ),
    ];
  }

  List<ItemVenda> _inventarioAndarAvancado() {
    return [
      ItemVenda(
        item: Item(
          id: 'espada_aco',
          nome: 'Espada de aço',
          descricao: 'Uma lâmina bem forjada. +3 ataque.',
        ),
        precoCompra: 75,
        quantidade: 2,
      ),
      ItemVenda(
        item: Item(
          id: 'armadura_couro',
          nome: 'Armadura de couro',
          descricao: 'Proteção básica. +2 defesa.',
        ),
        precoCompra: 50,
        quantidade: 1,
      ),
    ];
  }

  List<ItemVenda> _inventarioAndarMuitoAvancado() {
    return [
      ItemVenda(
        item: Item(
          id: 'espada_mithril',
          nome: 'Espada de mithril',
          descricao: 'Lendária e afiada. +6 ataque.',
        ),
        precoCompra: 200,
        quantidade: 1,
      ),
    ];
  }
}

extension _FirstWhereOrNull<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
```

## UI ASCII da Loja

A loja precisa de uma interface clara que mostre: que items você pode comprar, seus preços, seu inventário, seu ouro atual. A classe `LojaRenderer` desenha tudo em ASCII: cabeçalho com nome do comerciante, lista de items à venda, seu inventário, e HUD com status.

```dart
// lib/loja_renderer.dart

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
```

## Modo Loja: State Machine

A loja é um estado diferente do jogo. Precisa da sua própria máquina de estados. Enquanto você está na loja, o mundo exterior não existe: não há movimento, não há inimigos, só compra e venda. A classe `ModoLoja` é um loop independente: renderiza, lê comando (comprar, vender, sair), processa, renderiza de novo.

```dart
// lib/modo_loja.dart

import 'dart:io';
import 'jogador.dart';
import 'tela_ascii.dart';
import 'mercador.dart';
import 'loja_renderer.dart';

/// Executa a sessão de loja (estado especial do jogo)
class ModoLoja {
  final Jogador jogador;
  final Mercador mercador;
  final TelaAscii tela;
  final LojaRenderer renderer;

  bool emLoja = true;

  ModoLoja({
    required this.jogador,
    required this.mercador,
    required this.tela,
  }) : renderer = LojaRenderer(tela: tela);

  void executar() {
    renderer.renderizar(jogador, mercador);

    while (emLoja) {
      stdout.write('\n> ');
      final comando = stdin.readLineSync() ?? 'ajuda';
      processarComando(comando.trim());
      renderer.renderizar(jogador, mercador);
    }

    print('\nVocê saiu da loja.');
  }

  void processarComando(String cmd) {
    final partes = cmd.split(' ');
    final acao = partes[0].toLowerCase();

    switch (acao) {
      case 'comprar' || 'c':
        if (partes.length < 2) {
          print('Uso: comprar <número>');
          break;
        }
        final indice = int.tryParse(partes[1]);
        if (indice != null) {
          final mensagem = mercador.comprar(jogador, indice);
          print(mensagem);
        }
        break;

      case 'vender' || 'v':
        if (partes.length < 2) {
          print('Uso: vender <número>');
          break;
        }
        final indice = int.tryParse(partes[1]);
        if (indice != null) {
          final mensagem = mercador.vender(jogador, indice);
          print(mensagem);
        }
        break;

      case 'sair' || 's':
        emLoja = false;
        break;

      case 'status':
        print('Ouro: ${jogador.ouro} | HP: ${jogador.hp}/${jogador.maxHp}');
        break;

      default:
        print('Comando desconhecido. Digita "ajuda".');
    }
  }
}
```

## Desafios da Masmorra

**Desafio 23.1. Estoque Rotativo: Itens Novos a Cada Andar.** Implemente um método `regenerarEstoque()` na loja que troca parte dos itens a cada andar. Use `import 'dart:math'` e `Random().nextInt()` para selecionar 2-3 itens novos de uma lista maior de possibilidades. Cada vez que o jogador retorna à loja (novo andar), alguns itens antigos saem do catálogo e aparecem novos. O mercador comenta: "Chegou mercadoria nova!" quando o estoque muda. Dica: guarde uma lista de `_itemsCatalogo` (todos os itens possíveis) e `_itensAtuais` (o que está na loja agora). Cada chamada a `regenerarEstoque()` remove itens aleatórios e adiciona novos do catálogo.

**Desafio 23.2. A Chave do Final.** No coração da loja aparece um item lendário: a Chave Dourada que abre a porta do boss final. Crie um `ItemVenda` com nome "Chave Dourada Rara", id `'chave_dourada'`, preço 500 ouro, estoque 1. Adicione à loja (método `_inventarioBase()` ou crie um método novo). Teste: navegue a loja, veja a chave, pergunte: tenho ouro suficiente para comprar? Dica: use a classe `ItemVenda` com seu construtor para não repetir dados.

**Desafio 23.3. O Roubo do Comerciante.** Você negocia com o comerciante: uma Espada de Aço de 75 ouro em compra. Quanto ele oferece quando você quer vender de volta? Calcule manualmente (resposta: 37.5 ouro com margem 50%, ou 22.5 com margem 30%). Depois implemente no código e valide. O comerciante te prejudica na venda? Quanto você perde em uma transação completa (compra e venda)? Dica: sinta a economia em ação.

**Desafio 23.4. O Tesouro da Profundeza.** Conforme você desce muito fundo (andar 10 e além), a loja recebe artefatos lendários. Crie um método `_inventarioAndarProfundo()` que retorna itens épicos: "Espada Ancestral" (+10 ataque, 5000 ouro), "Anel de Imortalidade" (impede morte uma vez, 8000 ouro), "Tomo de Poder" (+5 ao nível, 6000 ouro). Integre em `restoquear()` com uma condição: `if (andar >= 10)`. Teste descendo até o andar 10, entre na loja, veja os itens novos aparecerem. Dica: siga o padrão de `_inventarioAndarInicial()`.

**Desafio 23.5. Loja Segura com Exceções.** A loja não pode quebrar. Se você não tem ouro, lança exceção, não trava. Crie `LojaExcecao`, `OuroInsuficienteExcecao`, `MochilaCheia Excecao`. Refatore `Mercador.comprar()` para verificar e lançar exceções ao invés de retornar strings de erro. Na UI, capture exceções e exiba mensagens amigáveis. Teste tentando comprar sem ouro, com mochila cheia, etc. Código mais robusto = jogo mais confiável. Dica: use try/catch na loja.

**Desafio 23.6. (Desafio): Ofertas do Dia.** Todo dia, a loja tem 3 itens especiais em destaque com 50% de desconto. Use `DateTime.now()` para pegar a data e criar seed determinística (ex: `seed = DateTime.now().year * 10000 + DateTime.now().month * 100 + DateTime.now().day`). Assim, o mesmo dia sempre tem os mesmos deals. Teste: reinicie o jogo 2x no mesmo dia, verá os mesmos deals? Reinicie no dia seguinte, verá offers diferentes? Dica: isso recompensa jogadores diários.

**Boss Final 23.7. Itens Únicos e Valiosos.** Itens lendários não devem estar sempre em estoque. Implemente: itens marcados como "raro=true" têm estoque máximo 1 por andar. Após vender, volta a 1 no próximo andar. Teste: compre a "Espada Ancestral" do andar 10, vá para andar 11, retorne ao 10, item deve estar de novo disponível. Outros itens normais sempre têm restoque completo. Dica: separe a lógica de restoque para itens raros vs normais.

## Pergaminho do Capítulo

Neste capítulo, você aprendeu:

- `ItemVenda` encapsula um item com preço e stock
- `Mercador` gerencia compras, vendas, restocking, validações
- `LojaRenderer` desenha a UI: colunas esquerda (loja) e direita (inventário)
- `ModoLoja` é um estado de jogo independente: processamento de comandos na loja
- Integração: a loja pode ser ativada por sala ou comando, depois volta à exploração
- Feedback visual: sucesso, falha, aviso, transação clara

A loja transforma a economia em interface tangível. Não é apenas números: é um espaço onde você estratégia, troca, planeja.

## Dica Profissional

::: dica
A UI é parte do design, não é apenas cosméticos. Uma loja bem desenhada faz o jogador querer entrar, explorar, decidir. Layout em colunas, números claros, feedback visual. Tudo isto é design de produto. Se o jogador não sabe que pode comprar, não vai comprar. Se não sabe se tem ouro, vai ficar frustrado. Invista tempo em feedback, formatação e instruções. É a diferença entre bom e ótimo.
:::

## Próximo Capítulo

No Capítulo 24, vamos dar superpotência a esta economia através de generics e pattern matching em Dart 3. Vamos criar um sistema de eventos tipado que dispara notificações quando items são comprados, vendidos, equipados. Cada evento tem sua própria estrutura e é processado com `switch` e pattern matching.

***

