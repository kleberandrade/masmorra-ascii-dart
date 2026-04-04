# Capítulo 23 - A Loja do Mercador: UI e Fluxo

> *Entrou numa loja. O ar cheira a madeira antiga e moedas de ouro. Atrás do balcão, um homem de barba cinzenta sorri. "O que quer comprar?" As armas brilham na parede. As poções estão arrumadas em prateleiras. Este é o espaço de respiração do roguelike onde você estratégia: que armadura devo carregar? Quanto ouro devo guardar? Vale a pena vender isto agora? Aqui a economia ganha presença física e interface clara.*

## Integração com o Sistema de Economia

A loja do Capítulo 23 é construída sobre os fundamentos do Capítulo 22: a `Economia` define preços de compra e venda (via `precoCompra()` e `precoVenda()`), as tabelas de drops alimentam o inventário do jogador com itens valiosos, e as recompensas escalonadas por andar permitem que você tenha progressivamente mais ouro para investir em equipamento melhor. Agora veremos como essa economia abstrata ganha corpo: uma loja real, com um comerciante real, onde você navega, escolhe e transaciona.

A loja não existe sozinha; ela é o ponto de encontro entre a progressão de dificuldade e a agência do jogador em decidir como gastar suas recompensas. Diferentemente do combate automático ou da exploração que ocorre naturalmente, a loja é um **espaço de pausa e decisão**. É aqui que você reflete: tenho ouro suficiente para esta espada? Vale vender este item descartável? Devo guardar ouro para um futuro mais difícil? A economia só importa quando você a sente tangibilizada em uma interface clara e responsiva.

## O Que Vamos Aprender

Neste capítulo você vai:

- Modelar a classe `Mercador` e seu inventário (`ItemVenda`)
- Criar a UI ASCII da *shop*: layout com colunas, listas, preços
- Implementar compra (se ouro >= preço) e venda (se item em inventário)
- Gerenciar modo *shop* vs modo exploração: dois estados de jogo distintos
- Validar operações: não deixar comprar sem ouro, não vender o que não tem
- Implementar *restock*: a loja muda de items a cada andar/visita
- Integrar *shop* no fluxo de jogo: entrada por sala especial, saída natural
- Renderizar feedback visual: "Comprado!", "Sem ouro!", "Inventário cheio!"

Ao final, você terá uma loja completa e jogável que funciona como uma entidade real do jogo.

## O Conceito da Loja

A loja é mais que um menu. É uma experiência completa:

1. Uma sala física; você entra por ação específica (digita `shop` ou pisa numa sala especial marcada)
2. Um estado de jogo distinto; não há movimento ou combate, apenas compra/venda
3. Inventário dinâmico; muda a cada andar ou a cada visita, oferecendo itens progressivamente melhores
4. Interface clara e contextual; lista de items à venda, lista de seus items, preços visíveis
5. Transações *type-safe* e validadas; compra com verificação de ouro, venda com verificação de inventário

## Classe ItemVenda e Inventário do Mercador

Um item à venda não é só um `Item`. Tem um preço e uma quantidade em estoque. A classe `ItemVenda` encapsula isto: o item, quanto custa, quantos estão disponíveis. Oferece métodos para remover do estoque (quando você compra) e verificar se ainda tem estoque disponível.

**Por que separar `ItemVenda` de `Item`?** Um `Item` é imutável e genérico — pode ser em qualquer lugar (inventário, drop, loja). Um `ItemVenda` é um `Item` com contexto comercial: preço e quantidade. Separar essas responsabilidades evita poluir `Item` com dados de negócio. Além disso, o mesmo item pode ter preços diferentes em lojas diferentes; `ItemVenda` permite essa flexibilidade sem clonar o item todo.

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

  // ← O comerciante compra por X mas vende por
  // 50% do preço (margem de lucro)
  int get precoVenda => (precoCompra * 0.5).toInt();

  // ← Verifica antes de permitir compra; evita
  // tentar vender algo sem estoque
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

O `Mercador` gerencia todas as transações da loja: compra, venda e restoque. É o coração lógico da economia local. Cada operação é validada rigorosamente antes de modificar estado.

**Ordem de validação em compra (crucial!):** (1) verificar se índice é válido, (2) verificar se item tem estoque, (3) verificar se jogador tem ouro suficiente, (4) verificar se inventário do jogador tem espaço, (5) aplicar a transação. Essa ordem importa profundamente porque evita estados inconsistentes: você não quer descontar ouro e depois descobrir que o inventário está cheio. Validação antes de modificação é padrão ouro em transações: se qualquer validação falha, o estado inteiro permanece inalterado (atomicidade).

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
  /// Retorna mensagem de sucesso ou erro sem modificar estado se falhar
  String comprar(Jogador jogador, int indiceItem) {
    // Validação 1: Índice existe?
    if (indiceItem < 0 || indiceItem >= inventario.length) {
      return 'Item inválido!';
    }

    final itemVenda = inventario[indiceItem];

    // Validação 2: Item tem estoque?
    if (!itemVenda.temEstoque) {
      return '${itemVenda.item.nome} está em falta.';
    }

    // Validação 3: Jogador tem ouro suficiente?
    if (jogador.ouro < itemVenda.precoCompra) {
      return 'Você não tem ouro suficiente '
          '(custo: ${itemVenda.precoCompra})';
    }

    // Validação 4: Mochila tem espaço?
    if (jogador.inventario.length >= jogador.tamanhoInventario) {
      return 'Inventário cheio!';
    }

    // Todas as validações passaram: executar transação atomicamente
    jogador.ouro -= itemVenda.precoCompra;
    jogador.adicionarItem(itemVenda.item);
    itemVenda.removerDoEstoque();

    return '${itemVenda.item.nome} comprado '
        'por ${itemVenda.precoCompra} ouro!';
  }

  /// Vende um item do inventário do jogador para a loja
  /// O comerciante compra por menos do que venderia (margem)
  String vender(Jogador jogador, int indiceItem) {
    if (indiceItem < 0 || indiceItem >= jogador.inventario.length) {
      return 'Item inválido!';
    }

    final item = jogador.inventario[indiceItem];
    // ← Usa Economia.precoVenda() que aplica desconto percentual
    final precoVenda = economia.precoVenda(item.id);

    if (precoVenda <= 0) {
      return 'Este item não tem valor!';
    }

    jogador.ouro += precoVenda;
    jogador.inventario.removeAt(indiceItem);
    // ← Adiciona item vendido ao catálogo da loja (restock dinâmico)
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

  /// Restoque progressivo: itens melhoram conforme você desce
  /// Cada andar muda o catálogo disponível (progression gate)
  void restoquear(int andarNumero) {
    inventario.clear();
    inventario.addAll(_inventarioBase());

    // ← A partir do andar 3: espadas, armaduras (equipamento)
    if (andarNumero >= 3) {
      inventario.addAll(_inventarioAndarAvancado());
    }
    // ← A partir do andar 7: artefatos lendários (gambit final)
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

> **Dica:** O método `firstWhereOrNull()` faz parte do `package:collection`. Adicione-o ao `pubspec.yaml`:
> ```yaml
> dependencies:
>   collection: ^1.18.0
> ```

## UI ASCII da Loja

A loja precisa de uma interface clara que mostre: que items você pode comprar, seus preços, seu inventário, seu ouro atual. A classe `LojaRenderer` desenha tudo em ASCII: cabeçalho com nome do comerciante, lista de items à venda, seu inventário, e HUD com status.

**Por que separar UI de lógica?** Isso segue o padrão *MVC* (Model-View-Controller): `Mercador` é o modelo (gerencia dados e regras de negócio), `LojaRenderer` é a visão (desenha na tela), e `ModoLoja` é o controlador (processa entrada). Essa separação é crítica: se você quiser mudar como a loja aparece (cores, layout, animações), muda apenas o renderer. A lógica de compra/venda fica segura, testável e reutilizável em outros contextos (web, mobile, etc.). O *Mercador* nunca precisa saber que usa ASCII; poderia usar gráficos ou terminal com cores e funcionaria igualmente.

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

    // ← Lista cada item com índice para seleção rápida
    for (int i = 0; i < mercador.inventario.length; i++) {
      final item = mercador.inventario[i];
      final linha =
          '[$i] ${item.item.nome} --- ${item.precoCompra} '
          'ouro (${item.quantidade})';

      if (!item.temEstoque) {
        print('(fora de estoque) $linha');
      } else {
        print(linha);
      }
    }

    print('\n TEU INVENTÁRIO');
    print('─' * 40);

    // ← Mostra seu inventário com preço de venda (margem aplicada)
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

A loja é um estado diferente do jogo. Precisa da sua própria máquina de estados. Enquanto você está na loja, o mundo exterior é **pausado**: não há movimento, não há inimigos, só compra e venda. A classe `ModoLoja` implementa um loop independente que é totalmente desacoplado do loop principal do dungeon: renderiza a interface, lê comando do usuário (comprar, vender, sair), processa a ação, renderiza novamente. Quando sai da loja, retorna ao mapa e o jogo continua — nenhuma ação foi perdida, nenhuma passagem de tempo ocorreu.

Esse padrão é chamado *state machine* (máquina de estados): o jogo tem múltiplos estados (exploração, combate, loja), e cada um tem seu próprio loop e lógica. A transição entre estados é explícita e controlada.

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
      // ← Comando: 'comprar 0' ou 'c 0' para comprar item na posição 0
       
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
        // ← Comando: 'vender 0' ou 'v 0' para vender
        // item do seu inventário
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
        // ← Define flag que interrompe o loop principal da loja
        emLoja = false;
        break;

      case 'status':
        print('Ouro: ${jogador.ouro} | '
            'HP: ${jogador.hp}/${jogador.maxHp}');
        break;

      default:
        print('Comando desconhecido. Digita "ajuda".');
    }
  }
}
```

## Saída Esperada

Quando você entra na loja e interage com o comerciante, a saída no terminal se parece com isto:

```text
════════════════════════════════════════════════════════════════════════
║ LOJA DO MESTRE ALDWIN                                              ║
════════════════════════════════════════════════════════════════════════

 COMPRAR NA LOJA
──────────────────────────────────────────

[0] Poção de vida --- 25 ouro (5)
[1] Poção de mana --- 15 ouro (3)
[2] Espada de aço --- 75 ouro (2)
[3] Armadura de couro --- 50 ouro (1)

 TEU INVENTÁRIO
──────────────────────────────────────────

[0] Moeda de ouro (⌬500 ouro)
[1] Adaga enferrujada (⌬10 ouro)
[2] Torção de corda (⌬5 ouro)

┌─ STATUS ─────────────────────────┐
│ Ouro:    850  HP: 40/50           │
│ Inventário: 3/10                  │
└────────────────────────────────────┘

Digita: [C]omprar [nº] | [V]ender [nº] | [S]air | [A]juda

> c 0

Poção de vida comprado por 25 ouro!

[Tela redraw com novo Ouro: 825, Inventário: 4/10]

> v 2

Torção de corda vendido por 2 ouro!

[Tela redraw: torção removida do inventário, item adicionado à loja]

> s

Você saiu da loja.
```

Este exemplo mostra:
- **Menu de compra** com índices, nomes e preços de cada item
- **Seu inventário** com índices e preços de venda (50% do preço original)
- **HUD de status** com ouro atual, HP, e espaço de mochila
- **Feedback de transação** ("Comprado!", "Vendido!") após cada ação
- **Estado dinâmico** que se atualiza a cada compra/venda

## Antes vs. Depois

### Antes: Loja Inexistente

```text
Jogador derrota inimigo → ganha item → item vai pro inventário
Não há chance de vender, trocar ou planejar.
Economia invisível: você não entende o valor dos itens.
```

### Depois: Loja Tangível

```text
Jogador derrota inimigo → ganha item → pode entrar na loja
Ao entrar: vê itens à venda, preços e seu ouro destacados
Pode vender itens desnecessários → ganha ouro → compra melhor
A economia é visual e decisória: cada compra é uma escolha estratégica.
Cada andar, loja muda de catálogo → cria senso de progressão e novidade.
```

## Por Que Não Uma Loja Automática? (Alternativa: Análise Crítica)

Você pode pensar: "Por que não a loja oferece itens automaticamente ao meu inventário?" Resposta: porque isso elimina **agência do jogador**. Uma loja deve ser um espaço de pausa e reflexão. Quando você entra na loja e vê aquela Espada Lendária custando 500 ouro, há conflito: "Tenho 450. Vale a pena vender 3 itens ruins para alcançar 500?" Essa decisão é o design. Uma loja automática que simplesmente despeja itens mata a tensão: você nunca escolhe, apenas aceita o que vem. Além disso, com uma loja manual, você controla quando entra — se quiser economizar ouro para depois, pode. Com automática, é sempre imediato. A escolha é design.

## Desafios da Masmorra

**Desafio 23.1. Estoque Rotativo: Itens Novos a Cada Andar.** Implemente um método `regenerarEstoque()` na loja que troca parte dos itens a cada andar. Use `import 'dart:math'` e `Random().nextInt()` para selecionar 2-3 itens novos de uma lista maior de possibilidades. Cada vez que o jogador retorna à loja (novo andar), alguns itens antigos saem do catálogo e aparecem novos. O mercador comenta: "Chegou mercadoria nova!" quando o estoque muda. Dica: guarde uma lista de `_itemsCatalogo` (todos os itens possíveis) e `_itensAtuais` (o que está na loja agora). Cada chamada a `regenerarEstoque()` remove itens aleatórios e adiciona novos do catálogo. Este padrão de *randomization* controlada é útil em qualquer jogo que queira variedade sem caos.

**Desafio 23.2. A Chave do Final.** No coração da loja aparece um item lendário: a Chave Dourada que abre a porta do boss final. Crie um `ItemVenda` com nome "Chave Dourada Rara", id `'chave_dourada'`, preço 500 ouro, estoque 1. Adicione à loja (método `_inventarioBase()` ou crie um método novo). Teste: navegue a loja, veja a chave, pergunte: tenho ouro suficiente para comprar? Dica: use a classe `ItemVenda` com seu construtor para não repetir dados.

**Desafio 23.3. O Roubo do Comerciante.** Você negocia com o comerciante: uma Espada de Aço de 75 ouro em compra. Quanto ele oferece quando você quer vender de volta? Calcule manualmente (resposta: 37.5 ouro com margem 50%, ou 22.5 com margem 30%). Depois implemente no código e valide. O comerciante te prejudica na venda? Quanto você perde em uma transação completa (compra e venda)? Dica: sinta a economia em ação.

**Desafio 23.4. O Tesouro da Profundeza.** Conforme você desce muito fundo (andar 10 e além), a loja recebe artefatos lendários. Crie um método `_inventarioAndarProfundo()` que retorna itens épicos: "Espada Ancestral" (+10 ataque, 5000 ouro), "Anel de Imortalidade" (impede morte uma vez, 8000 ouro), "Tomo de Poder" (+5 ao nível, 6000 ouro). Integre em `restoquear()` com uma condição: `if (andar >= 10)`. Teste descendo até o andar 10, entre na loja, veja os itens novos aparecerem. Dica: siga o padrão de `_inventarioAndarInicial()`.

**Desafio 23.5. Loja Segura com Exceções.** A loja não pode quebrar. Se você não tem ouro, lança exceção, não trava. Crie `LojaExcecao`, `OuroInsuficienteExcecao`, `MochilaCheia Excecao`. Refatore `Mercador.comprar()` para verificar e lançar exceções ao invés de retornar strings de erro. Na UI, capture exceções e exiba mensagens amigáveis. Teste tentando comprar sem ouro, com mochila cheia, etc. Código mais robusto = jogo mais confiável. Dica: use try/catch na loja. Exceções são a abordagem *idiomatic* em Dart para erros irrecuperáveis; retornar strings é anti-padrão.

**Desafio 23.6. (Desafio): Ofertas do Dia.** Todo dia, a loja tem 3 itens especiais em destaque com 50% de desconto. Use `DateTime.now()` para pegar a data e criar seed determinística (ex: `seed = DateTime.now().year * 10000 + DateTime.now().month * 100 + DateTime.now().day`). Assim, o mesmo dia sempre tem os mesmos deals. Teste: reinicie o jogo 2x no mesmo dia, verá os mesmos deals? Reinicie no dia seguinte, verá offers diferentes? Dica: isso recompensa jogadores diários.

**Boss Final 23.7. Itens Únicos e Valiosos.** Itens lendários não devem estar sempre em estoque. Implemente: itens marcados como "raro=true" têm estoque máximo 1 por andar. Após vender, volta a 1 no próximo andar. Teste: compre a "Espada Ancestral" do andar 10, vá para andar 11, retorne ao 10, item deve estar de novo disponível. Outros itens normais sempre têm restoque completo. Dica: separe a lógica de restoque para itens raros vs normais.

## Pergaminho do Capítulo

Neste capítulo, você aprendeu:

- **`ItemVenda`**: Encapsula um item com preço de compra, preço de venda (margem do comerciante), e quantidade em estoque. Oferece métodos para verificar disponibilidade e remover/adicionar unidades.
- **`Mercador`**: Gerencia todas as transações de compra e venda. Valida cada operação em ordem (índice → estoque → ouro → espaço → aplicar), retorna mensagens de sucesso ou falha, e reaplica o inventário quando muda de andar.
- **`LojaRenderer`**: Desenha a interface ASCII com cabeçalho decorado, colunas duplas (loja à esquerda, seu inventário à direita), preços visíveis, quantidades de estoque, e HUD com status (ouro, HP, espaço de mochila).
- **`ModoLoja`**: É uma máquina de estados independente que pausar o jogo principal. Renderiza a loja, lê comandos (comprar, vender, sair), processa transações, e volta a renderizar. Você não pode andar ou combater enquanto está aqui.
- **Padrão MVC**: A lógica (Mercador) é separada da visão (LojaRenderer) e do controle (ModoLoja). Isso permite reutilizar o Mercador em diferentes UIs (web, CLI alternativa, etc.).
- **Integração com Economia**: A loja usa `Economia.precoVenda()` e `Economia.precoCompra()` para calcular preços, conectando-se ao balanceamento definido no Capítulo 22. Drops de inimigos alimentam seu inventário; você vende itens extras na loja para financiar melhorias.
- **Restocking Dinâmico**: A loja muda de inventário a cada andar visitado. Andares 0-2 têm poções básicas, 3+ adicionam armas, 7+ adicionam lendárias. Isso cria senso de progressão: cada visita oferece novas oportunidades.
- **Feedback Visual e Clareza**: Cada transação devolve uma mensagem clara. O layout em colunas deixa evidente o que você tem versus o que pode comprar. Números são visíveis e contextualizados. Isto é design de produto: se o jogador não entende, não engaja.

A loja transforma a economia em interface tangível. Não é apenas números: é um espaço onde você estratégia, troca, planeja.

## Dica Profissional

::: dica
A UI é parte do design, não cosméticos. Uma loja bem desenhada faz o jogador querer entrar, explorar e decidir. Layout em colunas, números claros, feedback visual — tudo isto é design de produto. Se o jogador não sabe que pode comprar, não vai comprar. Invista tempo em feedback e formatação.
:::

## Próximo Capítulo

No Capítulo 24, vamos dar superpotência a esta economia através de generics e pattern matching em Dart 3. Criaremos um sistema de eventos tipado que dispara notificações quando itens são comprados, vendidos ou equipados. Cada evento tem sua própria estrutura e é processado com `switch` exaustivo.

***

