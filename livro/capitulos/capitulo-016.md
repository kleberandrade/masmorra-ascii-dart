# Capítulo 16 - TelaAscii: O Buffer de Renderização

> *Uma página em branco. Você desenha o mundo nela, linha por linha, caractere por caractere. Depois envia tudo para o papel de uma vez. Isso é o buffer. Não é magia. É eficiência. A tela em si é apenas leitura final. O verdadeiro trabalho acontece atrás das cortinas, em estruturas de dados limpas e organizadas.*


## O Que Vamos Aprender

Neste capítulo você vai aprender a separar totalmente modelo e visão usando a classe TelaAscii. Este é o padrão MVC simplificado que profissionais usam.

Especificamente:
- Entender por que separar renderização da lógica do jogo: flexibilidade, reutilização, testes
- Criar a classe TelaAscii com um buffer 2D de caracteres
- Implementar métodos: `limpar()`, `desenharChar()`, `desenharString()`, `renderizar()`
- Usar StringBuffer para construir a frame eficientemente
- Renderizar a camada de fundo (tiles do mapa)
- Sobrepor entidades (jogador `@`, inimigos `G`, itens `!`)
- Desenhar uma HUD abaixo do mapa (HP, ouro, nível, turno)
- Aplicar códigos de escape ANSI para limpar tela
- Entender o conceito de frame rate: ciclo limpar → desenhar → renderizar
- Exemplo completo: MapaMasmorra + Jogador + HUD através de TelaAscii

Ao final, você terá um sistema de renderização profissional e escalável.


## Parte 1: Por Que TelaAscii? — MVC e Separação

### O Problema do Enfoque Anterior

No capítulo anterior, MapaMasmorra.renderizarComJogador() faz renderização. Isso funciona, mas tem problemas:

1. Acoplamento: mapa sabe como renderizar. E se quiser renderizar em arquivo em vez de terminal?
2. Difícil testar: não pode verificar se o output é correto sem capturar stdout
3. Difícil estender: adicionar HUD, efeitos visuais, múltiplas entidades fica complicado
4. Performance: renderiza cada linha assim que é gerada

### Padrão **MVC** (Simplificado)

```text
Dados do Jogo           Modelo
├─ MapaMasmorra
├─ Jogador
├─ Entidades
└─ EstadoJogo
      ↓
┌─────────────────────┐
│   TelaAscii         │ Visão
│ (Buffer 2D)         │
└─────────────────────┘
      ↓
┌─────────────────────┐
│  Terminal (stdout)  │ Apresentação
└─────────────────────┘
```

Benefícios: Modelo não sabe que é renderizado. Pode renderizar em várias "views". É fácil testar lógica sem UI. Pode adicionar efeitos sem mexer no modelo.


## Parte 2: Classe TelaAscii — Estrutura Base

A `TelaAscii` é um buffer 2D simples: uma `List<List<String>>` onde cada célula é um caractere. Em vez de escrever direto em stdout, você desenha no buffer, depois chama `renderizar()` para enviar tudo de uma vez. Isso é eficiente e permite efeitos como limpar a tela sem cintilação. Note os códigos ANSI: `\x1B[2J` limpa, `\x1B[H` posiciona cursor no topo.

```dart
// tela_ascii.dart

import 'dart:io';

class TelaAscii {
  final int largura;
  final int altura;
  late List<List<String>> _buffer;

  TelaAscii({required this.largura, required this.altura}) {
    _inicializarBuffer();
  }

  void _inicializarBuffer() {
    _buffer = List<List<String>>.generate(
      altura,
      (y) => List<String>.generate(largura, (x) => ' '),
    );
  }

  void limpar() {
    for (int y = 0; y < altura; y++) {
      for (int x = 0; x < largura; x++) {
        _buffer[y][x] = ' ';
      }
    }
  }

  void desenharChar(int x, int y, String char) {
    if (x < 0 || x >= largura || y < 0 || y >= altura) {
      return;
    }
    _buffer[y][x] = char;
  }

  void desenharString(int x, int y, String texto) {
    for (int i = 0; i < texto.length; i++) {
      final charX = x + i;
      if (charX >= largura) break;
      desenharChar(charX, y, texto[i]);
    }
  }

  void renderizar() {
    stdout.write('\x1B[2J\x1B[H'); // Limpar tela ANSI

    final sb = StringBuffer();
    for (int y = 0; y < altura; y++) {
      for (int x = 0; x < largura; x++) {
        sb.write(_buffer[y][x]);
      }
      sb.write('\n');
    }

    stdout.write(sb.toString());
  }

  String obterChar(int x, int y) {
    if (x < 0 || x >= largura || y < 0 || y >= altura) {
      return ' ';
    }
    return _buffer[y][x];
  }
}
```

Notas importantes:
- `\x1B[2J\x1B[H` são códigos de escape ANSI: `\x1B[2J` limpa a tela, `\x1B[H` move cursor para (0, 0)
- `StringBuffer` é eficiente para construir strings longas
- `desenharString()` itera caractere por caractere, mais flexível que `print()`


## Parte 3: Renderizando o Mapa

Integrar `MapaMasmorra` com `TelaAscii` é simples: o mapa itera sobre seus tiles e chama `tela.desenharChar()` para cada um. Isto desacopla a renderização da lógica; `MapaMasmorra` não sabe que está desenhando num buffer ou escrevendo em stdout. Segue o princípio da injeção de dependência.

```dart
// dungeon.dart (adição)

import 'tela_ascii.dart';

class MapaMasmorra {
  // ... código anterior ...

  void renderizarNaTela(TelaAscii tela) {
    for (int y = 0; y < altura; y++) {
      for (int x = 0; x < largura; x++) {
        final tile = tileEm(x, y);
        tela.desenharChar(x, y, tileParaChar(tile));
      }
    }
  }
}
```

Simples! O mapa desenha-se no buffer da TelaAscii.


## Parte 4: Renderizando Entidades

Sobrepor entidades (jogador, inimigos, itens) requer que você desenhe em camadas, em ordem específica. Desenhe o fundo primeiro, depois items, depois inimigos, depois o jogador no topo. Se você desenhar o jogador primeiro, os inimigos vão sobrepô-lo visualmente (não é o que quer). A `abstract class Entidade` permite que qualquer entidade saiba desenhar-se numa `TelaAscii`.

```dart
// Ordem de renderização (muito importante):
// 1. Background (tiles)
// 2. Items (itens no chão)
// 3. Enemies (inimigos)
// 4. Player (jogador no topo)

abstract class Entidade {
  int x;
  int y;
  String simbolo;

  Entidade({required this.x, required this.y, required this.simbolo});

  void renderizarNaTela(TelaAscii tela) {
    tela.desenharChar(x, y, simbolo);
  }
}

class Jogador extends Entidade {
  String nome;
  int hpMax;
  int hpAtual;
  int ouro;

  Jogador({
    required this.nome,
    required int x,
    required int y,
    required this.hpMax,
    required this.ouro,
  })  : hpAtual = hpMax,
        super(x: x, y: y, simbolo: '@');

  bool mover(int novoX, int novoY, MapaMasmorra mapa) {
    if (!mapa.ehPassavel(novoX, novoY)) return false;
    x = novoX;
    y = novoY;
    return true;
  }

  void moverEmDirecao(String direcao, MapaMasmorra mapa) {
    int novoX = x, novoY = y;
    switch (direcao.toLowerCase()) {
      case 'w': novoY--;
      case 's': novoY++;
      case 'a': novoX--;
      case 'd': novoX++;
      default: return;
    }
    mover(novoX, novoY, mapa);
  }
}

class Inimigo extends Entidade {
  String nome;
  int hpMax;
  int hpAtual;

  Inimigo({
    required this.nome,
    required int x,
    required int y,
    required this.hpMax,
    required String simbolo,
  })  : hpAtual = hpMax,
        super(x: x, y: y, simbolo: simbolo);
}

class Item extends Entidade {
  String nome;

  Item({
    required this.nome,
    required int x,
    required int y,
  }) : super(x: x, y: y, simbolo: '!');
}
```


## Parte 5: HUD — Interface do Usuário

Desenhar uma barra de informações (HUD) abaixo do mapa. A `SessaoJogo` é responsável por renderizar toda a frame: modelo (mapa, jogador, inimigos, itens), depois HUD. O `renderizarFrame()` segue a sequência: limpar buffer, desenhar camadas em ordem, renderizar. Note que `renderizarFrame()` é o loop de renderização em sua forma mais pura.

```dart
// game.dart

class SessaoJogo {
  final MapaMasmorra mapa;
  final Jogador jogador;
  final List<Inimigo> inimigos;
  final List<Item> itens;
  final TelaAscii tela;

  int turnoAtual = 0;

  SessaoJogo({
    required this.mapa,
    required this.jogador,
    required this.inimigos,
    required this.itens,
    required this.tela,
  });

  String _construirBarraHP(int atual, int maximo) {
    const totalBlocos = 10;
    final blocos = (atual / maximo * totalBlocos).toInt();
    final cheios = '█' * blocos;
    final vazios = '░' * (totalBlocos - blocos);
    return '$cheios$vazios';
  }

  void renderizarHUD() {
    final hudY = mapa.altura + 1;

    tela.desenharString(0, hudY, '═' * tela.largura);

    final hpBar = _construirBarraHP(jogador.hpAtual, jogador.hpMax);
    final linha1 = 'HP: $hpBar ${jogador.hpAtual}/${jogador.hpMax} | '
        'Ouro: ${jogador.ouro} | Turno: $turnoAtual';
    tela.desenharString(0, hudY + 1, linha1);

    final linha2 = '[W]cima [A]esq [S]baixo [D]dir [Q]uit';
    tela.desenharString(0, hudY + 2, linha2);

    tela.desenharString(0, hudY + 3, '═' * tela.largura);
  }

  void renderizarFrame() {
    tela.limpar();

    // Camada 1: Mapa
    mapa.renderizarNaTela(tela);

    // Camada 2: Itens
    for (final item in itens) {
      item.renderizarNaTela(tela);
    }

    // Camada 3: Inimigos
    for (final inimigo in inimigos) {
      inimigo.renderizarNaTela(tela);
    }

    // Camada 4: Jogador (no topo)
    jogador.renderizarNaTela(tela);

    // Camada 5: HUD
    renderizarHUD();

    // Enviar tudo para tela
    tela.renderizar();
  }
}
```


## Parte 6: Loop Principal Refinado

O loop principal é agora limpíssimo graças à `SessaoJogo`: você simplesmente chama `renderizarFrame()` e depois processa input. Todo o estado visual (quem está onde, que cor, que camada) é delegado à sessão. Isso é profissional: a lógica do loop principal é simples e legível, enquanto detalhes de renderização vivem em classes próprias.

```dart
// main.dart

import 'dart:io';

void main() {
  final mapa = MapaMasmorra(largura: 30, altura: 15);

  // Construir mapa
  for (int y = 0; y < 15; y++) {
    for (int x = 0; x < 30; x++) {
      if (x == 0 || x == 29 || y == 0 || y == 14) {
        mapa.definirTile(x, y, Tile.parede);
      }
    }
  }

  for (int y = 5; y <= 10; y++) {
    mapa.definirTile(15, y, Tile.parede);
  }

  final jogador = Jogador(
    nome: 'Aldric',
    x: 5,
    y: 5,
    hpMax: 100,
    ouro: 50,
  );

  final inimigos = [
    Inimigo(
      nome: 'Zumbi',
      x: 20,
      y: 10,
      hpMax: 30,
      simbolo: 'G',
    ),
    Inimigo(
      nome: 'Lobo',
      x: 10,
      y: 8,
      hpMax: 50,
      simbolo: 'S',
    ),
  ];

  final itens = [
    Item(nome: 'Ouro', x: 15, y: 5),
    Item(nome: 'Poção', x: 25, y: 12),
  ];

  final tela = TelaAscii(largura: 30, altura: 20);

  final sessao = SessaoJogo(
    mapa: mapa,
    jogador: jogador,
    inimigos: inimigos,
    itens: itens,
    tela: tela,
  );

  print('=== MASMORRA ASCII: Renderização Profissional ===\n');

  bool rodando = true;
  while (rodando) {
    sessao.renderizarFrame();

    stdout.write('> ');
    final entrada = stdin.readLineSync() ?? '';

    switch (entrada.toLowerCase()) {
      case 'w' || 'a' || 's' || 'd':
        jogador.moverEmDirecao(entrada, mapa);
        sessao.turnoAtual++;
      case 'q':
        print('Adeus, ${jogador.nome}!');
        rodando = false;
      default:
        if (entrada.isNotEmpty) {
          // Ignorar silenciosamente
        }
    }
  }
}
```


***
## Desafios da Masmorra

**Desafio 16.1. Cores para o Caos (ANSI).** Adicione cores ANSI ao TelaAscii: `\x1B[31m` vermelho (inimigos, perigo), `\x1B[32m` verde (jogador, vida), `\x1B[33m` amarelo (ouro), `\x1B[37m` branco (paredes), `\x1B[0m` reset. Crie um método `colorir(String char, String cor)` que envolve o caractere. Renderize o mapa com cores: jogador verde, inimigos vermelhos, ouro amarelo, paredes brancas. Compare antes e depois visualmente.

**Desafio 16.2. HUD do Sobrevivente Expandida.** Expanda a HUD para mostrar: (1) quantos inimigos visíveis, (2) quantos itens próximos (dentro de raio 3), (3) qual andar (ex: "Andar 5 de 10"), (4) efeitos ativos (se envenenado, maldito, etc). Organize como uma coluna de status estruturada. Use `StringBuffer` e cálculos em tempo real dos valores.

**Desafio 16.3. Minimapa do andador.** No canto superior direito, renderize um minimap 12x8: `@` jogador, `E` inimigos, `$` ouro, `.` chão, `#` parede. Escale o mapa grande para pequeno dividindo coordenadas por 2. Mantenha sincronizado enquanto caminha: o `@` deve se mover no minimap em tempo real.

**Desafio 16.4. Visão com oclusão (Line of Sight).** Implemente verdadeira linha de visão: só renderize inimigos se (1) estiverem dentro de 7 tiles DO jogador E (2) não houver parede blocando a linha entre vocês. Crie `bool temObstaculo(Pos do, Pos ate)` que traça uma linha simples e verifica paredes. Inimigos bloqueados aparecem como `?` no minimap.

**Boss Final 16.5. Números flutuantes (Feedback animado).** Quando o jogador pega ouro, um `"+50g"` aparece na posição e flutua para cima durante 3 frames, desaparecendo depois. Use uma `List<NumeroFlutante>` com dados: `{pos, numero, frame}`. Cada frame incrementa `frame` e muda Y-1. Crie também `+HP` em verde para cura, `-dano` em vermelho para ataques. Isso dá feedback visual satisfatório sem palavras.


## Pergaminho do Capítulo

Neste capítulo você aprendeu:

- Padrão MVC: separar modelo (lógica), visão (renderização), apresentação (tela)
- Classe TelaAscii: buffer 2D de caracteres para desenho eficiente
- Métodos de desenho: `limpar()`, `desenharChar()`, `desenharString()`, `renderizar()`
- Renderização em camadas: background → items → enemies → player → HUD
- Códigos de escape ANSI: limpar tela e posicionar cursor
- StringBuffer: construir strings longas eficientemente
- Arquitetura profissional: modelo e visão separados

Seu jogo agora tem uma arquitetura profissional. Modelo e visão estão separados. Você pode testar lógica sem UI e trocar renderização sem afetar o jogo.

No próximo capítulo (17), você aprenderá aleatoriedade com propósito: usar `Random` para gerar mapas, itens e inimigos variáveis de forma controlada via seeds.


::: dica
**Dica do Mestre:** Debugging de buffer: se algo renderiza errado, inspecione o buffer:

```dart
void debugBuffer(TelaAscii tela) {
  for (int y = 0; y < tela.altura; y++) {
    for (int x = 0; x < tela.largura; x++) {
      final char = tela.obterChar(x, y);
      if (char != ' ') {
        print('Char em ($x, $y): "$char"');
      }
    }
  }
}
```

Performance: se o game ficar lento com muitos inimigos, use viewport (renderize só área ao redor do jogador) ou dirty flag pattern (só re-renderize se algo mudou).
:::
