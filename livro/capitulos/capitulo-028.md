# Capítulo 28 - Refatoração Guiada: Code Smells e Limpeza Estrutural

*Você para e olha para trás. O jogo funciona, mas o código que o sustenta acumulou cicatrizes de batalha: funções longas demais, nomes confusos, lógica duplicada. Todo projeto real passa por isso e a diferença entre código amador e profissional é o que você faz depois. Nesta parte, você volta pelos andares que conquistou e refatora. Extrai métodos, renomeia variáveis, organiza arquivos em pastas que fazem sentido. Mais que limpar, você vai aprender a proteger seu trabalho. Testes unitários garantem que nada quebre enquanto você melhora. Save e load com JSON preservam o progresso do jogador entre sessões. E no final, o projeto terá a estrutura de um pacote Dart profissional: documentado, testado e organizado. O mesmo jogo, mas agora escrito como alguém que sabe o que está fazendo.*

> *Você empurra a porta de uma câmara antiga. O piso está cheio de escombros: pedaços de código que já não fazem sentido, funções gigantescas que ninguém compreende, números mágicos espalhados como moedas podres. Antes de vencer este calabouço, é hora de limpar a casa. Refatorar não é reescrever; melhora a estrutura sem mudar o comportamento.*

Você desceu vários andares. Derrotou zumbis, lobos, orcs. Acumulou ouro e experiência. Mas olhe para trás agora. O código que trouxe você até aqui está cicatrizado; funções gigantescas como dragões antigos, nomes confusos como runas esquecidas, duplicação espalhada como moedas podres pelo chão da masmorra. Isto é *code smell*: sinais de que algo está apodrecendo.

Em qualquer RPG clássico, há um momento em que o herói para na vila antes de descer para o próximo calabouço. Descansa, organiza seu inventário, conserta suas armas, descarta o que não precisa mais. Este capítulo é esse momento para o seu código. Você não vai adicionar novas funcionalidades. Você vai limpar a casa.

Refatoração é um investimento no futuro. Código limpo é código que você (e seus colaboradores) conseguem ler, testar e estender em semanas. Código sujo vira um calabouço real: cada mudança quebra algo, cada teste falha sem razão aparente, cada novo recurso demora o dobro do tempo.

## Reconhecer Code Smells

*Code smells* não são bugs. São avisos de alerta amarelo. Se você já jogou Dark Souls, sabe aquele cheiro quando entra num local novo? Algo está errado e você não sabe o quê. *Code smells* são assim.

### Smell #1: Métodos Gigantescos

Um método com 150 linhas. Imagine refatorar um Pokémon: o poder muda, mas a essência continua. Este método gigante é um Pokémon carregando cinco tipos de ataques diferentes ao mesmo tempo, incapaz de se focar.

Observe como um método que deveria orquestrar o jogo termina fazendo renderização, processamento de entrada, cálculo de movimento e combate tudo junto. Cada uma dessas responsabilidades deveria ser um método separado. Quando você precisa testar "o inimigo se move corretamente", não consegue testar isoladamente pois o método está acoplado ao resto do código.

```dart
// Ruim: executar() faz tudo simultaneamente
void executar() {
  while (true) {
    // Renderizar (20 linhas)
    tela.limpar();
    // ... código de render aqui

    // Processar input (10 linhas)
    final cmd = stdin.readLineSync();
    // ... processamento aqui

    // Mover (15 linhas)
    // ... lógica inteira aqui

    // Combate (30 linhas)
    // ... tudo junto

    // Salvar (15 linhas)
    // ... mais código aqui
  }
}
```

Problema: você não consegue testar `_moverJogador()` isoladamente. Você não consegue reutilizar a lógica de combate em outro lugar. Você não consegue ler o método em cinco minutos.

### Smell #2: Deus Classes

Uma classe que faz tudo. Renderiza, processa entrada, executa combate, gera mundos, gerencia economia, salva dados. É como um personagem de RPG que é mago, guerreiro, ladrão e clérigo simultaneamente.

O código abaixo é aquilo que você quer evitar no seu projeto. Veja como `DungeonCrawl` acumula responsabilidades: uma mudança na renderização quebra a lógica de combate e vice-versa. Não consegue reutilizar a renderização em outro lugar, ou a lógica de combate em um editor de mapa. Cada responsabilidade "compete" com as outras pelo espaço e atenção.

```dart
// Ruim: uma classe com 50 métodos desconexos
class DungeonCrawl {
  // Renderização
  void mostrarMapa() { }
  void mostrarStatus() { }
  void mostrarInventario() { }

  // Lógica de combate
  void moverJogador(Offset d) { }
  void executarCombate(Inimigo e) { }
  void ganharXP(int x) { }

  // Geração
  void gerarMapa() { }
  void gerarInimigos() { }

  // Persistência
  void salvarJogo() { }
  void carregarJogo() { }

  // ... 30 métodos depois
}
```

Você tira um método para refatorar, e três outros quebram. Você muda o renderizador, e a lógica de combate fica confusa. Cada responsabilidade compete com as outras.

### Smell #3: Números Mágicos

Números espalhados pelo código são armadilhas clássicas. Você vê um `17` aqui, um `80` ali, um `5` em outro lugar. Ninguém consegue entender por quê. Foi sorte? Fórmula? Um erro antigo que ninguém tocou? O pior é quando o contexto muda (você aumenta o HP máximo do jogador para 100) e você esquece de atualizar um desses números mágicos em algum lugar; o jogo fica quebrado de forma sutil.

```dart
// Ruim: o que significam estes números?
if (jogador.hp < 17) print('crítico!');
if (mapa.largura > 80) { }
for (int i = 0; i < 5; i++) { }
```

Seis meses depois você olha e pensa: "por quê 17? Por quê 80? Por quê 5?" Descobre que 17 era metade de 34, alguém mudou o HP máximo para 50 mas esqueceu de atualizar aqui. Agora o código está quebrado.

### Smell #4: Código Duplicado

O código abaixo é a armadilha clássica: você precisa desenhar a mesma linha separadora em três lugares diferentes. Status, inventário, loja. Parece simples copiar e colar, é verdade. Mas quando você quer mudar o visual (use caracteres diferentes, ou ajuste a largura), você precisa lembrar de todos os três (cinco, dez) lugares. É garantido que você esquecerá um, deixando o jogo visualmente inconsistente.

```dart
print('─' * 20);
print('Status');
print('─' * 20);

// ... 100 linhas depois
print('─' * 20);
print('Inventário');
print('─' * 20);

// ... 100 linhas depois
print('─' * 20);
print('Loja');
print('─' * 20);
```

Aí você quer mudar a estética. Precisa encontrar todos os três lugares (ou cinco, ou dez). Muda um, esquece dos outros. O jogo ficou feio.

### Smell #5: Nomes Ruins

Nomes vagos ou genéricos tornam o código incompreensível. O "x" pode ser coordenada, dano, quantidade de ouro; você não sabe. O "a" pode ser uma lista de itens, inimigos ou qualquer coisa. Seis meses depois, você olha e pensa "o que era isso?" Pior ainda é quando tira esse código para testá-lo isoladamente ou reutilizá-lo em outro lugar: sem contexto, é impossível entender o que cada variável significa.

```dart
// Ruim: o que é x? o que é a?
int x = 5;
List<String> a = [];
var temp = mapa[0][0];

// Bom:
int danoBase = 5;
List<String> inimigosNaDungeon = [];
var tilePrincipal = mapa[0][0];
```

Nomes ruins são como uma masmorra sem sinalização; você se perde. Nomes bons são tochas iluminando o caminho.

## Extract Method: Quebrando Funções Longas

O método `executar()` é o pior culpado. Vamos extrair responsabilidades em métodos menores.

### Antes (Ruim)

```dart
class DungeonCrawl {
  void executar() {
    while (true) {
      // 20 linhas de renderização
      tela.limpar();
      jogador.mostrarStatus();
      mapa.desenhar();

      // 10 linhas de input
      stdout.write('> ');
      final cmd = stdin.readLineSync() ?? 'sair';

      // 30 linhas de lógica
      if (cmd == 'w') {
        final novaPos = jogador.pos + Offset(0, -1);
        if (mapa.estaValido(novaPos)) {
          jogador.pos = novaPos;
        }
      }
    }
  }
}
```

Não consegue testar `_moverJogador()` separadamente. A lógica está espalhada. Impossível ler.

### Depois (Bom)

```dart
class DungeonCrawl {
  void executar() {
    while (true) {
      renderizar();
      final comando = processarInput();
      executarComando(comando);
    }
  }

  void renderizar() {
    tela.limpar();
    jogador.mostrarStatus();
    mapa.desenhar();
  }

  Comando processarInput() {
    stdout.write('> ');
    final texto = stdin.readLineSync() ?? 'sair';
    return parser.parse(texto);
  }

  void executarComando(Comando cmd) {
    if (cmd is CmdMover) {
      _moverJogador(cmd.direcao);
    }
  }

  void _moverJogador(Offset direcao) {
    final nova = jogador.pos + direcao;
    if (!mapa.estaValido(nova)) return;
    jogador.pos = nova;
  }
}
```

Agora `executar()` é legível em um segundo. Cada método faz UMA coisa. Consegue testar `_moverJogador()` isoladamente.

## Extract Class: Separando Deus Classes

### Antes: Tudo Junto

```dart
class DungeonCrawl {
  // Renderização
  void mostrarMapa() { }
  void mostrarStatus() { }

  // Lógica de jogo
  void moverJogador(Offset d) { }
  void executarCombate(Inimigo e) { }

  // Geração
  void gerarMapa() { }
  void gerarInimigos() { }
}
```

### Depois: Responsabilidades Separadas

Crie pastas temáticas:

```text
lib/
  modelos/
    jogador.dart
    inimigo.dart
  ui/
    telaascii.dart
    renderizador.dart
  jogo/
    dungeonCrawl.dart
    loopJogo.dart
  combate/
    combate.dart
```

Exemplo:

```dart
// lib/ui/renderizador.dart
class Renderizador {
  void mostrarMapa(Jogador j, MapaMasmorra m) { }
  void mostrarStatus(Jogador j) { }
}

// lib/combate/combate.dart
class Combate {
  bool executar(Jogador j, Inimigo i) { }
}

// lib/jogo/dungeonCrawl.dart
class DungeonCrawl {
  late Renderizador renderizador;
  late Combate combate;

  void executar() {
    renderizador.mostrarStatus(jogador);
    combate.executar(jogador, inimigo);
  }
}
```

Cada classe é testável isoladamente.

## Replace Magic Numbers com Constants

### Antes (Ruim)

```dart
if (jogador.hp < 17) print('crítico!');
if (mapa.largura > 80) redimensionar();
for (int i = 0; i < 5; i++) tentarGerarMapa();
```

### Depois (Bom)

Crie `lib/config/constantes.dart`:

```dart
class Constantes {
  // Saúde
  static const int hpMinimoCritico = 17;
  static const int hpMaximoRecuperacao = 50;

  // Mapa
  static const int larguraTelaMax = 80;
  static const int alturaTelaMax = 24;

  // Geração
  static const int tentativasGeracaoMapa = 5;
  static const int inimigosMinimos = 3;
}
```

Uso:

```dart
if (jogador.hp < Constantes.hpMinimoCritico) {
  print('crítico!');
}

if (mapa.largura > Constantes.larguraTelaMax) {
  redimensionar();
}
```

Mudar um número agora significa mudar num único lugar. E é óbvio o que significa.

## Rename Refactoring: Clareza Total

A maioria das IDEs (VSCode, Android Studio) tem "Rename Symbol":

```dart
// Antes: o que é 'e'?
for (final e in entidades) {
  e.executarTurno();
}

// Clica em 'e', pressiona F2 (ou Cmd+Shift+R em Mac)
// Digite "inimigoAtual" e pressione Enter

// Depois: perfeitamente claro
for (final inimigoAtual in entidades) {
  inimigoAtual.executarTurno();
}
```

Todos os usos mudam simultaneamente. Zero risco de esquecer um.

## Single Responsibility Principle (SRP)

SRP diz: uma classe, uma razão para mudar.

Se `Jogador` faz:
- Renderizar HUD
- Lógica de movimento
- Cálculo de dano
- Salvar em JSON

Ela tem 4 razões para mudar. Separar:

```dart
// lib/modelos/jogador.dart — apenas dados
class Jogador {
  int hp;
  int ataque;
  Offset pos;
  List<Item> inventario;
}

// lib/ui/renderizadorJogador.dart — renderização
class RenderizadorJogador {
  void mostrarStatus(Jogador j) { }
}

// lib/combate/calculadorDano.dart — combate
class CalculadorDano {
  int calcular(Jogador j, Inimigo i) { }
}

// lib/persistencia/salvadorJogador.dart — save/load
class SalvadorJogador {
  void salvar(Jogador j, String caminho) { }
  Jogador carregar(String caminho) { }
}
```

Agora cada classe tem UMA razão para mudar:
- `Jogador` muda quando mudam os atributos
- `RenderizadorJogador` muda quando muda a UI
- `CalculadorDano` muda quando mudam as regras
- `SalvadorJogador` muda quando muda o formato de save

## Reorganizar Pastas por Responsabilidade

### Antes: Caos

```text
lib/
  jogador.dart
  inimigo.dart
  dungeonCrawl.dart
  telaAscii.dart
  item.dart
  combate.dart
  gerador.dart
  (25 arquivos misturados)
```

### Depois: Organizado

```text
lib/
  modelos/
    jogador.dart
    inimigo.dart
    item.dart
  ui/
    telaAscii.dart
    renderizador.dart
  jogo/
    dungeonCrawl.dart
    loopJogo.dart
    estadoJogo.dart
  combate/
    combate.dart
    calculadorDano.dart
  mundo/
    mapaMasmorra.dart
    gerador.dart
  config/
    constantes.dart
```

### Atualizar Imports

Quando reorganiza pastas, atualiza imports:

```dart
// Antes (tudo junto em lib/)
import 'jogador.dart';
import 'inimigo.dart';

// Depois (organizado em subpastas de lib/)
import 'modelos/jogador.dart';
import 'modelos/inimigo.dart';
import 'combate/combate.dart';
```

Dentro de `lib/` use imports relativos. Em `test/` use `package:` imports (convenção Dart).

## Exemplo Completo: Antes e Depois

### Antes: Monolítico

```dart
// lib/dungeonCrawl.dart — 200 linhas, faz tudo
class DungeonCrawl {
  late Jogador jogador;
  late MapaMasmorra mapa;
  late List<Inimigo> entidades;

  void executar() {
    while (jogador.estaVivo) {
      // Renderizar (20 linhas)
      tela.limpar();
      print('${jogador.nome} HP: ${jogador.hp}');

      // Desenhar mapa (15 linhas)
      for (int y = 0; y < mapa.altura; y++) {
        String linha = '';
        for (int x = 0; x < mapa.largura; x++) {
          if (Offset(x.toDouble(), y.toDouble()) == jogador.pos) {
            linha += '@';
          } else {
            linha += '.';
          }
        }
        print(linha);
      }

      // Input (10 linhas)
      stdout.write('> ');
      final cmd = stdin.readLineSync() ?? 'sair';

      // Executar (50 linhas)
      if (cmd == 'w') {
        final nova = jogador.pos + Offset(0, -1);
        if (nova.dx >= 0 && nova.dx < mapa.largura &&
            nova.dy >= 0 && nova.dy < mapa.altura) {
          jogador.pos = nova;
          // Combate inline aqui também (30 linhas)
          // ... tudo junto e misturado
        }
      } else if (cmd == 'a') {
        // ... mais movimento
      }
      // ... mais 50 linhas de switch
    }
  }
}
```

### Depois: Refatorado

```dart
// lib/jogo/dungeonCrawl.dart — 40 linhas, orquestra
class DungeonCrawl {
  late Jogador jogador;
  late MapaMasmorra mapa;
  late List<Inimigo> entidades;
  late Renderizador render;

  void executar() {
    while (jogador.estaVivo) {
      render.renderizar(jogador, mapa, entidades);
      final cmd = processarInput();
      executarComando(cmd);
    }
  }

  void executarComando(Comando cmd) {
    if (cmd is CmdMover) {
      _moverJogador(cmd.direcao);
    }
  }

  void _moverJogador(Offset direcao) {
    final nova = jogador.pos + direcao;
    if (!mapa.estaValido(nova)) return;
    jogador.pos = nova;
    final inimigo = entidades.firstWhereOrNull((e) =>
      e.pos == nova);
    if (inimigo != null) iniciarCombate(inimigo);
  }
}

// lib/ui/renderizador.dart — 30 linhas, renderiza
class Renderizador {
  void renderizar(Jogador j, MapaMasmorra m,
    List<Inimigo> entidades) {
    tela.limpar();
    _renderizarStatus(j);
    _renderizarMapa(m, j, entidades);
  }

  void _renderizarStatus(Jogador j) {
    print('${j.nome} HP: ${j.hp}');
  }

  void _renderizarMapa(MapaMasmorra m, Jogador j,
    List<Inimigo> entidades) {
    for (int y = 0; y < m.altura; y++) {
      String linha = '';
      for (int x = 0; x < m.largura; x++) {
        final pos = Offset(x.toDouble(), y.toDouble());
        if (pos == j.pos) {
          linha += '@';
        } else if (entidades.any((e) => e.pos == pos)) {
          linha += 'E';
        } else {
          linha += '.';
        }
      }
      print(linha);
    }
  }
}
```

Diferença clara:
- DungeonCrawl antes: 200 linhas, 1 arquivo, impossível testar
- DungeonCrawl depois: 40 + 30 linhas, 2 arquivos, cada um testável

## Executar dart analyze

Depois de refatorar, verifique que nada quebrou:

```bash
$ cd seu_projeto
$ dart analyze
```

Esperado:

```text
No issues found!
```

Se houver erros, corrige os tipos (provavelmente um import foi esquecido):

```text
error: The argument type 'String' can't be assigned
to parameter type 'Offset' at ...
```

## Desafios da Masmorra

**Desafio 28.1. Audit de Saúde.** Seu código cresceu. Tempo de diagnóstico. Abra o arquivo principal e identifique problemas: (1) Qual método tem mais linhas? (2) A classe principal faz quantas coisas? (3) Existem números mágicos soltos (17, 100, 0.5)? (4) Vê código duplicado? Liste 5 problemas. Execute `dart analyze` para autochecar. Dica: transparência é primeiro passo para melhoria.

**Desafio 28.2. Cirurgião de Código.** Encontre um método com 40+ linhas (ex: `executarTurno()`). Está fazendo demais: renderizar, ler input, combate. Extraia em 3 submétodos: `_renderizarTela()`, `_lerAcaoJogador()`, `_processarAcao()`. Cada responsável por uma coisa. Refatore e teste: jogo deve funcionar igual, mas código fica legível. Dica: retire uma responsabilidade por vez, teste, depois a próxima.

**Desafio 28.3. Constantes Nomeadas.** Espalhados pelo código estão valores como 20 (HP crítico), 80 (largura tela), 5 (raio visão). Crie `lib/config/constantes.dart`: `const hpMinimoDePerigo = 20`, `const larguraTelaMax = 80`, `const raioVisaoJogador = 5`. Substitua todos. Execute `dart analyze` (sem warnings). Execute jogo (sem mudanças). Agora alterar valores é fácil e centralizado. Dica: constantes documentam intenção.

**Desafio 28.4. Organização Profissional.** Seu `lib/` é caos—tudo junto. Crie estrutura: `lib/modelos/` (dados), `lib/ui/` (renderização), `lib/jogo/` (loop), `lib/combate/` (batalha), `lib/mundo/` (geração), `lib/config/` (configuração). Mova `Jogador` → modelos, `TelaAscii` → ui, `MapaMasmorra` → mundo, etc. Atualize imports de `'jogador.dart'` para `'package:masmorra/modelos/jogador.dart'`. Execute `dart analyze` (zero erros). Dica: qualidade de vida enormemente melhor.

**Boss Final 28.5. Quebra da Deus Classe.** Sua classe `Jogador` provavelmente faz 5 coisas: gerencia stats, renderiza, faz combate, salva, carrega. Viola SRP. Quebre em: (1) `JogadorModel` (HP, ataque, nível), (2) `RenderizadorJogador` (desenha barra HP), (3) `LogicaCombateJogador` (calcula dano). Mova métodos apropriados. Atualize `main` para usar 3 classes em lugar de uma. Teste tudo. Código mais limpo = bugs mais fáceis de caçar. Dica: faça um refactor por vez para não enlouquecer.

***

## Pergaminho do Capítulo

Você aprendeu a reconhecer code smells: métodos gigantescos, deus classes, números mágicos, código duplicado, nomes ruins. Aprendeu a limpar:

- Extract Method quebra métodos longos
- Extract Class separa responsabilidades
- Replace Magic Numbers torna intenção clara
- SRP garante que cada classe tem uma razão para mudar
- Organização em pastas temáticas torna o projeto navegável
- dart analyze verifica que nada quebrou

Refatoração é investimento no futuro. Código limpo é código que você lê em cinco minutos. Código sujo vira um calabouço real: cada mudança quebra algo, cada teste falha, cada novo recurso demora o dobro.

Um roguelike com 30 funcionalidades e código sujo é impossível de manter. Um com 5 funcionalidades e código limpo é uma base sólida para crescer.

## Dica Profissional

::: dica
Refatore incrementalmente, não de uma vez. Se tentar refatorar 50 arquivos simultaneamente:

1. Quebra coisas
2. Fica impossível debugar (muita coisa muda ao mesmo tempo)
3. Demora semanas

Em vez disso:

1. Refatore uma classe de cada vez
2. Execute `dart analyze` após cada mudança
3. Teste que o jogo funciona
4. Faça commit com git: `git commit -m "refactor: extract Renderizador de DungeonCrawl"`

Cada passo é reversível. Um refactor grande demora 2—3 semanas de commits pequenos, mas fica perfeito. Exemplo de sequência:

```text
refactor: extract Renderizador
refactor: extract Combate
refactor: move jogador.dart para model/
refactor: move inimigo.dart para model/
refactor: replace magic numbers com Constantes
refactor: atualizar imports para package:
```

Cada commit é pequeno, testável, reversível.
:::

No próximo capítulo você vai escrever testes unitários com `package:test`. Testes garantem que refatorações não quebraram nada e que comportamentos complexos funcionam como esperado. É a segurança de rede enquanto você dança na corda bamba. Seu código merece proteção.
