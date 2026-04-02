# Capítulo 6 - Arte ASCII e StringBuffer

> *O artesão da masmorra não usa pincéis, usa caracteres. Um `╔` no canto, um `║` na lateral, um `═` no topo. Linha por linha, o texto bruto vira interface. Neste capítulo, você se torna o artesão.*

O jogo já tem salas, inventário e navegação. Mas a apresentação visual ainda é primitiva, prints soltos, sem moldura consistente, sem alinhamento. Neste capítulo vamos aprender a construir telas ASCII de forma programática com **sprites ASCII**: molduras, barras de HP, caixas de texto e banners, tudo usando **StringBuffer** para montar o desenho eficientemente antes de exibi-lo.

## Por que não usar print diretamente?

Até agora usamos `print()` para cada linha de saída. Funciona, mas tem dois problemas conforme o jogo cresce.

O primeiro é performance. Quando seu mapa tiver 20 linhas por 40 colunas e precisar ser redesenhado a cada turno, chamar `print()` 20 vezes causa cintilação visível. É mais eficiente montar toda a saída numa única string e imprimir de uma vez.

O segundo é organização. Quando você quer construir uma moldura cujo tamanho depende do texto dentro dela, precisa calcular larguras, preencher espaços e alinhar colunas. Fazer isso com `print()` separados é confuso. Com `StringBuffer`, você monta o desenho inteiro em uma única variável e só depois exibe.

## StringBuffer, o bloco de construção

A classe `StringBuffer` acumula texto de forma eficiente. Em vez de criar strings intermediárias com `+` (o que é lento porque cria novas strings o tempo todo), você vai escrevendo pedaços e no final extrai o resultado como uma única string. Para telas complexas, `StringBuffer` é essencial: você constrói tudo em memória e imprime de uma vez, evitando cintilação no terminal.

```dart
var buffer = StringBuffer();
buffer.writeln('╔══════════════════╗');
buffer.writeln('║  Masmorra ASCII  ║');
buffer.writeln('╚══════════════════╝');
print(buffer.toString());
```

Os dois métodos principais são `write()` (adiciona texto sem quebra de linha) e `writeln()` (adiciona texto com quebra de linha).

```dart
var buffer = StringBuffer();
buffer.write('HP: ');
buffer.write('████████');
buffer.writeln('░░ 80%');
print(buffer.toString());
```

## String manipulation, as ferramentas do artesão

Para construir arte ASCII programática, precisamos dominar os métodos de manipulação de strings.

**Repetição com `*`:**

```dart
print('═' * 30);
print('#' * 10);
```

**Preenchimento com `padLeft()` e `padRight()`:**

```dart
var texto = 'Aldric';
print(texto.padRight(20));
print(texto.padLeft(20));
print(texto.padRight(20, '.'));
```

A função `padRight(20)` garante que a string tenha pelo menos 20 caracteres, preenchendo com espaços à direita. Isso é essencial para alinhar colunas em tabelas.

**Centralizar texto** (Dart não tem método nativo, mas podemos criar):

```dart
String centralizar(String texto, int largura) {
  if (texto.length >= largura) return texto;
  var espacos = largura - texto.length;
  var esquerda = espacos ~/ 2;
  return texto.padLeft(texto.length + esquerda).padRight(largura);
}

print(centralizar('MENU', 30));
```

O operador `~/` é a divisão inteira, retorna um `int` em vez de `double`. Por exemplo, `7 ~/ 2` retorna `3`, não `3.5`.

## Construindo uma moldura dinâmica

Agora que dominamos `StringBuffer`, vamos criar uma função mais sofisticada: uma moldura que se ajusta dinamicamente ao conteúdo. Esse é um excelente exercício de manipulação de strings. Calcular tamanhos programaticamente, preencher espaços e construir strings complexas são habilidades fundamentais.

```dart
String moldura(String titulo, List<String> linhas, {int minLargura = 30}) {
  var maxTexto = titulo.length;
  for (var linha in linhas) {
    if (linha.length > maxTexto) maxTexto = linha.length;
  }
  var larguraInterna = maxTexto + 4;
  if (larguraInterna < minLargura) larguraInterna = minLargura;

  var buffer = StringBuffer();

  buffer.write('╔');
  buffer.write('═' * larguraInterna);
  buffer.writeln('╗');

  var tituloFormatado = centralizar(titulo, larguraInterna);
  buffer.writeln('║$tituloFormatado║');

  buffer.write('╠');
  buffer.write('═' * larguraInterna);
  buffer.writeln('╣');

  for (var linha in linhas) {
    var conteudo = '  $linha'.padRight(larguraInterna);
    buffer.writeln('║$conteudo║');
  }

  buffer.write('╚');
  buffer.write('═' * larguraInterna);
  buffer.writeln('╝');

  return buffer.toString();
}
```

Exemplo de uso:

```dart
print(moldura('TAVERNA', [
  'Uma taverna aconchegante.',
  'Cheiro de cerveja e pão.',
  '',
  'Saídas: [oeste]',
  'NPC: Velho Sábio'
]));
```

Resultado:

```text
╔══════════════════════════════╗
║           TAVERNA            ║
╠══════════════════════════════╣
║  Uma taverna aconchegante.  ║
║  Cheiro de cerveja e pão.   ║
║                              ║
║  Saídas: [oeste]             ║
║  NPC: Velho Sábio            ║
╚══════════════════════════════╝
```

A função `moldura()` é um ótimo exercício de manipulação de strings. No nosso jogo, porém, vamos usar saídas mais simples no terminal para manter o código limpo e focado na lógica do roguelike.

## Barras de HP e XP

Barras visuais são o tipo mais icônico de interface em jogos de texto. Uma barra bem desenhada comunica informações em millisegundos: um relance na proporção de blocos preenchidos e o jogador sabe exatamente em que estado seu personagem está. Vamos construir uma barra de HP reutilizável que usa caracteres Unicode para representar a vida de forma visual.

```dart
String barraHP(int atual, int maximo, {int largura = 20}) {
  var proporcao = atual / maximo;
  var preenchidos = (proporcao * largura).round();
  var vazios = largura - preenchidos;

  var barra = '█' * preenchidos + '░' * vazios;
  var porcentagem = (proporcao * 100).toInt();

  return '$barra $atual/$maximo ($porcentagem%)';
}

print('HP: ${barraHP(75, 100)}');
print('HP: ${barraHP(20, 100)}');
print('HP: ${barraHP(100, 100)}');
```

Podemos adicionar rótulos semânticos usando palavras:

```dart
String barraComStatus(String rotulo, int atual, int maximo) {
  var barra = barraHP(atual, maximo, largura: 15);
  var status = atual < maximo * 0.25
      ? '** PERIGO! **'
      : atual < maximo * 0.5
          ? '(cuidado)'
          : '';
  return '$rotulo: $barra $status';
}
```

## Tabelas ASCII

Para listas de itens, lojas ou comparar stats entre armas, tabelas ASCII estruturadas são essenciais. Uma tabela bem construída permite que o jogador absorva informações complexas num relance. Vamos montar uma função que cria uma tabela com bordas alinhadas automaticamente, sem que você tenha que calcular os espaços manualmente.

```dart
String tabela(List<String> cabecalhos, List<List<String>> linhas) {
  var larguras = List<int>.filled(cabecalhos.length, 0);
  for (var i = 0; i < cabecalhos.length; i++) {
    larguras[i] = cabecalhos[i].length;
  }
  for (var linha in linhas) {
    for (var i = 0; i < linha.length && i < larguras.length; i++) {
      if (linha[i].length > larguras[i]) {
        larguras[i] = linha[i].length;
      }
    }
  }

  var buffer = StringBuffer();
  var separador = '+${larguras.map((l) => '-' * (l + 2)).join('+')}+';

  buffer.writeln(separador);
  var cab = cabecalhos
      .asMap()
      .entries
      .map((e) => ' ${e.value.padRight(larguras[e.key])} ')
      .join('|');
  buffer.writeln('|$cab|');
  buffer.writeln(separador);

  for (var linha in linhas) {
    var row = linha
        .asMap()
        .entries
        .map((e) => ' ${e.value.padRight(larguras[e.key])} ')
        .join('|');
    buffer.writeln('|$row|');
  }
  buffer.writeln(separador);

  return buffer.toString();
}
```

Exemplo de uso:

```dart
print(tabela(
  ['Item', 'Preço', 'Dano'],
  [
    ['Adaga', '30g', '+5'],
    ['Espada Curta', '80g', '+8'],
    ['Machado', '120g', '+12']
  ]
));
```

Resultado:

```text
+--------------+-------+------+
| Item         | Preço | Dano |
+--------------+-------+------+
| Adaga        | 30g   | +5   |
| Espada Curta | 80g   | +8   |
| Machado      | 120g  | +12  |
+--------------+-------+------+
```

## Aplicação no jogo, **HUD** composto

Agora vamos integrar tudo: molduras, barras e alinhamento. Um bom **HUD** (Head-Up Display) comunica a saúde do jogador, recursos disponíveis e equipamento atual tudo num pequeno espaço. Vamos montar um HUD que combina as técnicas de moldura, preenchimento e barra para criar uma tela profissional.

```dart
String montarHUD(String nome, int hp, int maxHp, int ouro, String? arma) {
  var buffer = StringBuffer();
  var largura = 38;

  buffer.write('╔');
  buffer.write('═' * largura);
  buffer.writeln('╗');

  var nomeFormatado = '  $nome'.padRight(largura);
  buffer.writeln('║$nomeFormatado║');

  buffer.write('╠');
  buffer.write('═' * largura);
  buffer.writeln('╣');

  var hpBarra = barraHP(hp, maxHp, largura: 15);
  var hpLinha = '  HP: $hpBarra'.padRight(largura);
  buffer.writeln('║$hpLinha║');

  var ouroLinha = '  Ouro: ${ouro}g'.padRight(largura);
  buffer.writeln('║$ouroLinha║');

  var armaTexto = arma ?? 'Nenhuma';
  var armaLinha = '  Arma: $armaTexto'.padRight(largura);
  buffer.writeln('║$armaLinha║');

  buffer.write('╚');
  buffer.write('═' * largura);
  buffer.writeln('╝');

  return buffer.toString();
}

print(montarHUD('Aldric', 75, 100, 42, 'Espada Curta'));
```

Resultado:

```text
╔══════════════════════════════════════╗
║  Aldric                              ║
╠══════════════════════════════════════╣
║  HP: ███████████░░░░ 75/100 (75%)   ║
║  Ouro: 42g                           ║
║  Arma: Espada Curta                  ║
╚══════════════════════════════════════╝
```

***

## Desafios da Masmorra

**Desafio 6.1. Moldura com título e rodapé.** Modifique a função `moldura()` para aceitar um parâmetro opcional `rodape`. Se fornecido, adicione uma linha separadora (com `─`) entre o conteúdo e o rodapé, depois exiba o rodapé com alinhamento. Por exemplo: uma caixa de inventário com "Mochila Vazia" como rodapé.

**Desafio 6.2. Barra de XP customizada.** Crie uma função `barraXP(int xpAtual, int xpProximoNivel, int nivel)` que mostra uma barra diferente da de HP: use `▓` (preenchido) e `░` (vazio), similar à de HP mas com cores diferentes (conceitualmente). Ao lado, mostre "Nível X" e a percentagem de progresso.

**Desafio 6.3. Caixa de diálogo de NPC (Com bordas especiais).** Crie uma função `dialogoNPC(String nomeNPC, String fala)` que exibe uma caixa estilizada: o nome do NPC em negrito (ou destacado com cores se em suporte a ANSI) no topo, a fala envolvida com uma borda especial diferente da HUD (use caracteres como `╭`, `╰`, `│`).

**Desafio 6.4. Mini-mapa do mundo.** Usando `StringBuffer`, desenhe um mini-mapa 5x5 onde `@` é o jogador, `#` são paredes (limites da masmorra), `.` é chão livre e `?` são salas não visitadas. Use a sala atual e salas vizinhas para popular o mapa.

**Boss Final 6.5. Tela de morte épica (Game Over).** Crie uma função `telaGameOver(String nome, int turnos, int ouro)` que monta uma tela de game over elaborada. Inclua: arte ASCII de um túmulo ou caveira, nome do herói caído, quantos turnos sobreviveu, ouro acumulado, e uma última mensagem do tipo "Descansa em paz, herói." Use box-drawing para tornar impressionante.

## O próximo passo: organizando o caos com classes

Você agora domina `StringBuffer`, strings interpoladas, alinhamento e arte ASCII. São ferramentas sólidas para desenhar qualquer tela. Mas há um problema que vai aparecer conforme o jogo cresce: o código fica espalhado. Você tem funções `moldura()`, `barraHP()`, `tabela()`, `montarHUD()`. Depois vêm mais 20 funções para combate, inventário, equipamento, magia. Tudo solto, sem relação clara.

No Capítulo 5 aprendemos que coleções (List, Map, Set) agrupam _dados_. Mas dados sozinhos não bastam. Você precisa agrupar _dados e comportamento_. Seu jogador tem HP, nome, ouro, inventário. Seu inventário tem itens. Cada item tem dano, preço, descrição. Hoje isso é feito com Map e variáveis globais. Amanhã, com classes, você agrupa tudo: dados + métodos que operam naqueles dados.

Parte II começa a essa jornada. Suas salas soltas em `mundoSalas` viram objetos `Sala`. Seus itens em listas viram objetos `Item`. Seu personagem vira `Jogador`. E cada classe organiza seus dados e suas funções de forma clara e reutilizável.

***

## Pergaminho do Capítulo

Neste capítulo você aprendeu a usar `StringBuffer` para montar texto complexo de forma eficiente, os métodos `padLeft`, `padRight` e `*` para alinhamento e repetição, a construir molduras dinâmicas que se ajustam ao conteúdo, barras de HP visuais com caracteres de bloco, tabelas ASCII com colunas alinhadas, e a divisão inteira `~/` para cálculos de posicionamento.

Essas são as ferramentas visuais que vamos usar pelo resto do livro. Toda interface do jogo será construída com essas mesmas técnicas. No Capítulo 7, vamos unificar tudo num game loop completo e bem organizado.

::: dica
**Dica do Mestre:** Ao desenhar interfaces ASCII, escolha uma largura padrão (como 40 ou 50 caracteres) e mantenha-a consistente em todas as telas. Nada quebra mais a imersão do que molduras de tamanhos diferentes aparecendo em sequência. Defina uma constante `const larguraTela = 40;` e use-a em todas as funções de desenho.
:::
