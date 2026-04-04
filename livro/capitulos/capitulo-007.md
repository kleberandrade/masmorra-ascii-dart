# Capítulo 7 - O game loop, o coração do jogo

> *O loop é o coração que bate no peito de todo jogo. Enquanto ele pulsa, o mundo respira; o jogador age, o jogo reage, a tela redesenha. Quando ele para, o jogo morre. Neste capítulo, construímos o coração.*

Nos seis capítulos anteriores, construímos peças separadas: input, output, funções, null safety, coleções e arte ASCII. Agora é hora de juntar tudo num programa coeso - uma aventura textual completa com salas conectadas, itens coletáveis, HUD visual e um loop principal bem organizado. Este é o marco da Parte I: o primeiro *roguelike* jogável.

## O que é um *game loop*

Todo jogo, de Pac-Man a Elden Ring, roda sobre o mesmo conceito: um *game loop* que se repete indefinidamente, executando três passos a cada iteração.

O primeiro passo é mostrar o estado atual: desenhar o mundo na tela (ou, no nosso caso, no terminal).

O segundo passo é receber input: ler o que o jogador quer fazer.

O terceiro passo é atualizar o estado: mover o jogador, resolver combate, coletar itens, mudar de sala.

E então o loop volta ao primeiro passo, mostrando o novo estado. Esse ciclo se repete até o jogo acabar. Em jogos gráficos, esse loop roda dezenas de vezes por segundo. Num jogo de texto por turnos como o nosso, o loop espera o jogador digitar algo antes de avançar. A filosofia é a mesma; o ritmo é que muda.

## Organizando o código, separar dados de lógica

Antes de montar o loop, precisamos organizar o código em seções bem definidas. Vamos separar o que é constante (variáveis que nunca mudam), o que é estado do mundo (dados das salas), o que é estado do jogador (HP, ouro, inventário) e o que são funções de processamento. Essa separação torna o código muito mais fácil de entender, manter e estender.

```dart
import 'dart:io';

// ══════════════════════════════════════
// CONSTANTES
// ══════════════════════════════════════

const larguraTela = 40;
const versao = '0.3.0';

// ══════════════════════════════════════
// DADOS DO MUNDO
// ══════════════════════════════════════

final mundoSalas = <String, Map<String, dynamic>>{
  'praca': {
    'nome': 'Praça Central',
    'descricao': 'Uma fonte de pedra murmura ao centro da praça.\n'
        'Tochas iluminam três passagens que se abrem\n'
        'nas paredes de pedra.',
    'saidas': {
      'norte': 'corredor',
      'leste': 'taverna',
      'sul': 'portao'
    },
    'itens': <String>['Tocha', 'Chave Enferrujada']
  },
  'corredor': {
    'nome': 'Corredor Escuro',
    'descricao': 'Um corredor estreito e frio. As paredes são\n'
        'cobertas de musgo. Água pinga do teto. Algo\n'
        'se move na escuridão à frente.',
    'saidas': {'sul': 'praca', 'norte': 'armaria'},
    'itens': <String>[]
  },
  'taverna': {
    'nome': 'Taverna do Javali',
    'descricao': 'Uma taverna aconchegante. O cheiro de cerveja\n'
        'e pão fresco preenche o ar. Um velho sábio\n'
        'cochila no canto junto à lareira.',
    'saidas': {'oeste': 'praca'},
    'itens': <String>['Poção de Vida']
  },
  'portao': {
    'nome': 'Portão da Masmorra',
    'descricao': 'Um portão de ferro enorme. Além dele, escuridão\n'
        'absoluta. Correntes de ar frio sopram de dentro.\n'
        'Você sente que não está pronto... ainda.',
    'saidas': {'norte': 'praca'},
    'itens': <String>['Moeda de Ouro']
  },
  'armaria': {
    'nome': 'Armaria Abandonada',
    'descricao': 'Armas enferrujadas penduradas nas paredes.\n'
        'A maioria está inútil, mas algo brilha\n'
        'debaixo de um pano rasgado.',
    'saidas': {'sul': 'corredor'},
    'itens': <String>['Adaga', 'Escudo de Madeira']
  }
};

final sinonimos = <String, String>{
  'n': 'norte', 's': 'sul', 'l': 'leste', 'o': 'oeste',
  'e': 'leste', 'w': 'oeste',
  'i': 'inventario', 'inv': 'inventario',
  'p': 'pegar', 'olhar': 'olhar', 'ver': 'olhar',
  'largar': 'largar', 'drop': 'largar',
  'h': 'ajuda', 'help': 'ajuda', '?': 'ajuda',
  'q': 'sair', 'quit': 'sair',
};

// ══════════════════════════════════════
// ESTADO DO JOGADOR
// ══════════════════════════════════════

var nomeJogador = 'Aventureiro';
var salaAtual = 'praca';
var inventario = <String>[];
// Rastreia salas visitadas para indicar novos lugares
var salasVisitadas = <String>{};
var ouro = 0;
var hp = 100;
var maxHp = 100;
var turno = 0;
```

Separamos claramente os dados do jogador. No Capítulo 8, essas variáveis soltas serão substituídas por uma classe `Jogador`. Por enquanto, essa organização em seções claras já é um grande avanço.

## Funções de renderização

Agora adicionamos as funções que constroem a interface visual do jogo. Essas funções recebem valores (nome do jogador, HP atual) e retornam strings formatadas prontas para imprimir. Reutilizaremos essas funções repetidamente: `exibirHUD()` sempre que precisamos mostrar o painel, `exibirSala()` quando o jogador entra numa sala nova.

```dart
// ══════════════════════════════════════
// RENDERIZAÇÃO
// ══════════════════════════════════════

String centralizar(String texto, int largura) {
  if (texto.length >= largura) return texto;
  var espacos = largura - texto.length;
  var esquerda = espacos ~/ 2;
  return texto.padLeft(texto.length + esquerda).padRight(largura);
}

String barraHP(int atual, int maximo, {int largura = 15}) {
  var prop = atual / maximo;
  var cheios = (prop * largura).round();
  var vazios = largura - cheios;
  return '${'█' * cheios}${'░' * vazios} $atual/$maximo';
}

void exibirHUD() {
  print('');
  print('  $nomeJogador');
  print('  HP: ${barraHP(hp, maxHp)}');
  print('  Ouro: ${ouro}g');
  print('');
}

void exibirSala() {
  var sala = mundoSalas[salaAtual]!;
  var nome = sala['nome'] as String;
  var descricao = sala['descricao'] as String;
  var saidas = sala['saidas'] as Map<String, String>;
  var itens = sala['itens'] as List<String>;

  var primeira = !salasVisitadas.contains(salaAtual);
  if (primeira) {
    salasVisitadas.add(salaAtual);
    print('');
    print('★ Lugar novo! ★');
  } else {
    print('');
    print('(Você já visitou este lugar)');
  }
  print(nome.toUpperCase());

  for (var linha in descricao.split('\n')) {
    print('  $linha');
  }

  var saidasTexto = saidas.keys.map((d) => '[$d]').join(' ');
  print('Saídas: $saidasTexto');

  if (itens.isNotEmpty) {
    print('No chão: ${itens.join(', ')}');
  }

  print('');
}

void exibirInventario() {
  print('');
  if (inventario.isEmpty) {
    print('Sua mochila está vazia.');
  } else {
    print('INVENTÁRIO');
    for (var i = 0; i < inventario.length; i++) {
      print('  ${i + 1}. ${inventario[i]}');
    }
  }
  print('');
}
```

## Funções de comando

Agora as funções que processam as ações do jogador. Cada uma delas representa um comando válido: `mover()` altera a sala atual, `pegarItem()` modifica o inventário e a sala, `largarItem()` faz o oposto. Essas funções encapsulam a lógica do jogo, tornando o loop principal limpo e legível.

```dart
// ══════════════════════════════════════
// COMANDOS
// ══════════════════════════════════════

void mover(String direcao) {
  var sala = mundoSalas[salaAtual]!;
  var saidas = sala['saidas'] as Map<String, String>;

  if (!saidas.containsKey(direcao)) {
    print('Não há saída para $direcao.');
    return;
  }

  salaAtual = saidas[direcao]!;
  turno++;
  print('Você vai para $direcao...');
  exibirSala();
}

void pegarItem(String nomeItem) {
  var sala = mundoSalas[salaAtual]!;
  var itens = sala['itens'] as List<String>;

  var encontrado = itens.where(
    (item) => item.toLowerCase().contains(nomeItem.toLowerCase())
  ).toList();

  if (encontrado.isEmpty) {
    print('Não há "$nomeItem" aqui.');
    return;
  }

  if (inventario.length >= 10) {
    print('Mochila cheia! Largue algo primeiro.');
    return;
  }

  var item = encontrado.first;
  itens.remove(item);

  // Moedas de Ouro vão direto para o contador de
  // ouro, não para o inventário
  if (item == 'Moeda de Ouro') {
    ouro += 10;
    print('Você pegou $item e ganhou 10g! (Total: ${ouro}g)');
  } else {
    inventario.add(item);
    print('Você pegou: $item.');
  }
  turno++;
}

void largarItem(String nomeItem) {
  var encontrado = inventario.where(
    (item) => item.toLowerCase().contains(nomeItem.toLowerCase())
  ).toList();

  if (encontrado.isEmpty) {
    print('Você não tem "$nomeItem".');
    return;
  }

  var item = encontrado.first;
  inventario.remove(item);
  var sala = mundoSalas[salaAtual]!;
  (sala['itens'] as List<String>).add(item);
  print('Você largou: $item.');
  turno++;
}
```

## O *game loop* principal

Finalmente, o loop que une tudo em `main()`. O `main()` é surpreendentemente simples agora: inicializa o jogo, mostra a cena inicial e depois entra num `while` que continua até o jogador sair. Em cada iteração, imprime um prompt, lê o comando, processa e renderiza. Esse é o padrão que vai funcionar para todos os nossos jogos por turnos.

```dart
import 'dart:io';

// ══════════════════════════════════════
// GAME LOOP
// ══════════════════════════════════════

void main() {
  print('');
  print('╔${'═' * larguraTela}╗');
  print('║${centralizar('M A S M O R R A   A S C I I', larguraTela)}║');
  print('║${centralizar('v$versao', larguraTela)}║');
  print('╚${'═' * larguraTela}╝');
  print('');

  stdout.write('Como devo chamá-lo? ');
  nomeJogador = (stdin.readLineSync() ?? '').trim();
  if (nomeJogador.isEmpty) nomeJogador = 'Aventureiro';

  print('\nBem-vindo, $nomeJogador! Sua aventura começa agora.\n');

  exibirHUD();
  exibirSala();

  while (true) {
    print('');
    stdout.write('Turno $turno > ');
    var input = (stdin.readLineSync() ?? '').trim().toLowerCase();

    if (input.isEmpty) continue;

    var partes = input.split(' ');
    var cmd = sinonimos[partes[0]] ?? partes[0];
    var argumento = partes.length > 1
        ? partes.sublist(1).join(' ')
        : '';

    switch (cmd) {
      case 'norte' || 'sul' || 'leste' || 'oeste':
        mover(cmd);

      case 'pegar':
        if (argumento.isEmpty) {
          print('Pegar o quê? Use: pegar <item>');
        } else {
          pegarItem(argumento);
        }

      case 'largar':
        if (argumento.isEmpty) {
          print('Largar o quê? Use: largar <item>');
        } else {
          largarItem(argumento);
        }

      case 'inventario':
        exibirInventario();

      case 'olhar':
        exibirSala();

      case 'status':
        exibirHUD();

      case 'ajuda':
        print('');
        print('Comandos disponíveis:');
        print('  norte/sul/leste/oeste (n/s/l/o), mover');
        print('  pegar <item> (p), pegar item do chão');
        print('  largar <item>, largar item no chão');
        print('  inventario (i), ver mochila');
        print('  olhar, ver sala atual');
        print('  status, ver HP e ouro');
        print('  ajuda (h/?), esta mensagem');
        print('  sair (q), encerrar o jogo');

      case 'sair':
        print('');
        print('╔${'═' * larguraTela}╗');
        var msgFinal = centralizar(
          'Até a próxima aventura!',
          larguraTela,
        );
        print('║$msgFinal║');
        final resumo = '$nomeJogador, $turno turnos, ${ouro}g';
        var resumoFormatado = centralizar(resumo, larguraTela);
        print('║$resumoFormatado║');
        print('╚${'═' * larguraTela}╝');
        return;

      default:
        print('Não entendi "$input". '
            'Digite "ajuda" para ver os comandos.');
    }
  }
}
```

## Uma sessão completa

Execute o programa e interaja como o exemplo abaixo:

```text

╔══════════════════════════════════════╗
║        M A S M O R R A   A S C I I  ║
║               v0.3.0                 ║
╚══════════════════════════════════════╝

Como devo chamá-lo? Aldric

Bem-vindo, Aldric! Sua aventura começa agora.

╔══════════════════════════════════════╗
║  Aldric                              ║
║  HP: ███████████████ 100/100        ║
║  Ouro: 0g                            ║
╚══════════════════════════════════════╝

★ Lugar novo! ★
PRAÇA CENTRAL

Uma fonte de pedra murmura ao centro
da praça. Tochas iluminam três
passagens que se abrem nas paredes.

Saídas: [norte] [leste] [sul]
No chão: Tocha, Chave Enferrujada

Turno 0 > p tocha
Você pegou: Tocha.

Turno 1 > n
Você vai para norte...

★ Lugar novo! ★
CORREDOR ESCURO

Um corredor estreito e frio. As
paredes são cobertas de musgo. Água
pinga do teto.

Saídas: [sul] [norte]

Turno 2 > status

╔══════════════════════════════════════╗
║  Aldric                              ║
║  HP: ███████████████ 100/100        ║
║  Ouro: 0g                            ║
╚══════════════════════════════════════╝

Turno 2 > sair

╔══════════════════════════════════════╗
║       Até a próxima aventura!        ║
║      Aldric, 2 turnos, 0g            ║
╚══════════════════════════════════════╝
```

Esse é o marco da Parte I. Você tem um jogo funcional: salas conectadas, itens que podem ser pegos e largados, um HUD com barra de HP, ouro que pode ser coletado, contador de turnos e um loop que roda até o jogador decidir sair. É simples, mas é completo, e tudo foi feito com Dart puro no terminal.

## Ponte para a Parte II: classes chegam

O jogo roda, mas repare num problema: os dados estão espalhados. O jogador é um monte de variáveis soltas (`nomeJogador`, `hp`, `maxHp`, `ouro`, `inventario`, `turno`). As salas são `Map<String, dynamic>`, sem segurança de tipo. Se você digitar `hpAtual` em vez de `hp`, o compilador não reclama até a execução falhar.

E há pior: o comportamento está separado dos dados. Renderizar o HUD é uma função `exibirHUD()` que lê variáveis globais. Coletar item é `pegarItem()` que manipula listas. Não há coesão. Imagine daqui a 10 capítulos com 100 funções, 50 variáveis globais e 20 classes de inimigos diferentes; isto seria um caos.

Na Parte II, vamos organizar tudo com classes. Seus dados soltos viram objetos tipados: `Jogador`, `Sala`, `Item`, `Inimigo`. Cada classe agrupa seus dados com os métodos que operam neles. O jogador _sabe_ como levar dano, equipar uma arma, ganhar XP. Uma sala _sabe_ como renderizar a si mesma. Um item _sabe_ seu peso e preço. O código fica limpo, reutilizável e pronto para crescer.

Comece o Capítulo 8. Está na hora de aprender orientação a objetos de verdade.

### O Jogo Até Aqui

Ao final desta parte, seu jogo no terminal se parece com isto:

```text

╔══════════════════════════════════════╗
║        M A S M O R R A   A S C I I  ║
║               v0.3.0                 ║
╚══════════════════════════════════════╝

Como devo chamá-lo? Aldric

Bem-vindo, Aldric! Sua aventura começa agora.

╔══════════════════════════════════════╗
║  Aldric                              ║
║  HP: ███████████████ 100/100        ║
║  Ouro: 0g                            ║
╚══════════════════════════════════════╝

★ Lugar novo! ★
PRAÇA CENTRAL

Uma fonte de pedra murmura ao centro
da praça. Tochas iluminam três
passagens que se abrem nas paredes.

Saídas: [norte] [leste] [sul]
No chão: Tocha, Chave Enferrujada

Turno 0 > p tocha
Você pegou: Tocha.

Turno 1 > n
Você vai para norte...

★ Lugar novo! ★
CORREDOR ESCURO

Um corredor estreito e frio. As
paredes são cobertas de musgo. Água
pinga do teto.

Saídas: [sul] [norte]

Turno 2 > status

╔══════════════════════════════════════╗
║  Aldric                              ║
║  HP: ███████████████ 100/100        ║
║  Ouro: 0g                            ║
╚══════════════════════════════════════╝

Turno 2 > sair

╔══════════════════════════════════════╗
║       Até a próxima aventura!        ║
║      Aldric, 2 turnos, 0g            ║
╚══════════════════════════════════════╝
```

Cada parte adiciona novas camadas ao jogo. Compare com o início e veja o quanto você evoluiu!

***

## Desafios da Masmorra

**Desafio 7.1. Eventos aleatórios (Suspense).** Adicione um evento aleatório a cada turno com 20% de probabilidade. Use `import 'dart:math'` e `Random().nextInt(100) < 20` para decidir. Exemplos: "Você ouve passos distantes...", "Um sopro frio passa por você", "Algo se move na sombra". Mostre apenas quando o evento ocorrer.

**Desafio 7.2. Comando examinar (Pistas escondidas).** Adicione um campo `detalhes` (texto longo) a cada sala além da descrição breve. O comando `"examinar"` ou `"x"` mostra esses detalhes. Serve para esconder pistas e informações extras para jogadores curiosos investigarem.

**Desafio 7.3. Ambiente hostil (HP dinâmico).** Cada vez que o jogador entrar numa sala com descrição contendo "escuro", "frio", "úmido" ou "perigoso", perca 5 HP automaticamente. Use `.contains()`. Se HP chegar a 0, exiba a tela de game over. Isso torna algumas salas mais perigosas que outras: ambiente vs jogador.

**Desafio 7.4. Tela de estatísticas finais.** Ao sair do jogo, exiba uma tabela formatada com: turnos jogados, salas visitadas (conte as únicas), itens coletados, ouro final e HP sobrevivido. Use box-drawing e formatação visual.

**Boss Final 7.5. Sistema de diálogo com NPC (Velho Sábio).** Adicione um NPC chamado "Velho Sábio" numa sala especial "Taverna". O comando `"falar"` inicia um diálogo com 3 opções de respostas (use número ou letra). Uma das respostas revela uma dica sobre uma sala secreta. Se o jogador tiver a "Chave Enferrujada" no inventário quando resolver voltar, uma nova saída aparece na "Câmara Secreta" com ouro ou uma arma valiosa.

*Dica do Mestre: Guarde uma flag `conversouComVelhoSabio = false` para saber se já falou com ele. O diálogo apresenta 3 opções; uma delas ('sabedoria') desbloqueia a dica. Depois, quando voltar à Taverna, a lógica de saídas verifica se tem a chave E já conversou: se sim, adiciona saída para "Câmara Secreta".*

## Pergaminho do Capítulo

Neste capítulo você construiu o *game loop* completo: ler input, processar comando, atualizar estado, redesenhar a tela. Organizou o código em seções claras (constantes, dados, estado, renderização, comandos, loop principal). Integrou todas as técnicas dos capítulos anteriores numa aventura textual jogável com 5 salas, inventário, ouro e HUD visual.

Este é o fim da Parte I. Você partiu de `print('Olá')` e chegou a um jogo funcional no terminal.

::: dica
**Dica do Mestre:** O *game loop* que construímos é síncrono: ele para e espera o jogador digitar. Isso é perfeito para um jogo por turnos. Mas quando adicionarmos persistência nos capítulos futuros, vamos precisar de `async`/`await` para operações de disco. Não se preocupe com isso agora. Quando chegar a hora, a transição será natural. O importante é que a estrutura do loop já está correta.
:::
