# Apêndice D: Glossário {.unnumbered}

Este glossário reúne os termos técnicos mais importantes usados ao longo do livro e na jornada roguelike. Consulte-o sempre que encontrar uma palavra desconhecida: aqui você encontrará tanto a explicação técnica quanto o contexto do jogo.

**Abstract Class:** classe que não pode ser instanciada diretamente e serve como base para outras classes. Define uma interface que subclasses devem implementar, força um contrato de comportamento.

**Ahead-of-Time (AOT):** compilação que converte código Dart em código de máquina nativo antes da execução. Resulta em inicialização rápida e performance previsível, ideal para aplicações que precisam iniciar rapidamente.

**ANSI Escape Codes:** sequências de caracteres que controlam formatação, cor e posição do cursor no terminal. O jogo usa códigos como `\x1B[2J` para limpar a tela e `\x1B[31m` para texto vermelho.

**ASCII:** American Standard Code for Information Interchange. Padrão de codificação que representa caracteres usando números de 0 a 127. Essencial para jogos baseados em texto que utilizam caracteres para desenhar o mundo.

**Async/Await:** padrão em Dart para operações assíncronas não-bloqueantes. `async` marca uma função como assíncrona, `await` pausa a execução até o `Future` resolver. Essencial para I/O (save/load) sem congelar o game loop.

**BFS (Breadth-First Search):** algoritmo de busca em largura que explora todos os nós de uma distância antes de explorar nós mais afastados. Usado em pathfinding para encontrar o caminho mais curto entre dois pontos.

**Boss:** inimigo poderoso, geralmente único ou raro, que representa um desafio significativo. Frequentemente marca o final de uma seção ou dungeon e oferece recompensas maiores ao ser derrotado.

**Buffer:** área de memória que armazena dados temporariamente. Em renderização, o buffer guarda o estado de cada tile antes de exibir na tela.

**Command Pattern:** padrão de design que encapsula uma solicitação como um objeto, permitindo parametrizar clientes com diferentes requisições e implementar filas, desfazer e logging.

**Distância de Manhattan:** método de calcular distância entre dois pontos em grid contando passos horizontais e verticais: `|x1 - x2| + |y1 - y2|`. Mais rápido que distância euclidiana em jogos baseados em grid. Usada em cálculos de FOV, spawn seguro e IA.

**Dungeon Crawler:** tipo de jogo onde o jogador explora um calabouço ou série de andares subterrâneos, enfrentando monstros e coletando tesouro. Exemplos clássicos incluem Rogue e NetHack.

**DRY (Don't Repeat Yourself):** princípio que evita duplicação de código. Código duplicado é mais difícil de manter e mais propenso a bugs.

**Effective Dart:** conjunto de diretrizes e melhores práticas para escrever código Dart de alta qualidade, mantido pela equipe oficial do Dart.

**Enum:** tipo que define um conjunto fixo de constantes nomeadas. Útil para representar estados, direções ou tipos de entidades no jogo.

**Factory Constructor:** construtor especial em Dart que não necessariamente cria uma nova instância da classe, podendo retornar uma instância existente ou de uma subclasse.

**Field of View (FOV):** área que o jogador pode enxergar do seu ponto de vista atual. Implementada com algoritmos como shadowcasting para criar exploração realista. Diferente de Line of Sight (LOS), que verifica visibilidade entre dois pontos específicos.

**Future:** tipo Dart que representa um valor que será disponível no futuro. Retornado por operações assíncronas como leitura de arquivos. Aguardado com `await` ou gerenciado com `.then()`.

**Game Loop:** estrutura fundamental de um jogo que continuamente executa: processamento de entrada, atualização de estado e renderização. Garante comportamento consistente e responsivo.

**Golden Test:** teste que compara a saída de uma função com um resultado pré-gravado. Útil para testes de renderização ou geração procedural onde a saída é complexa.

**HUD (Heads-Up Display):** interface visual que exibe informações do jogo como vida, mana, inventário e mapa sem interromper o gameplay. Geralmente posicionado nas bordas da tela.

**JIT (Just-In-Time):** compilação que converte código durante a execução. Mais lento na inicialização mas pode otimizar código que está sendo executado frequentemente.

**JSON:** JavaScript Object Notation. Formato padrão para representar dados estruturados em texto. Usado para serializar estado do jogo em arquivos de save.

**Late:** palavra-chave Dart que permite declarar uma variável que será inicializada após a construção do objeto. Útil para valores que dependem de outros parâmetros mas são garantidos antes do primeiro uso.

**Linha de Visão (Line of Sight / LOS):** algoritmo que determina se um ponto é visível a partir de outro sem obstáculos bloqueando. Diferente de FOV, que calcula múltiplos pontos, LOS verifica uma linha reta entre dois objetos.

**Loot:** itens valiosos encontrados após derrotar inimigos ou explorar áreas. Inclui equipamentos, poções, ouro e outros objetos que melhoram o personagem.

**Level Up:** processo pelo qual o personagem do jogador ganha experiência e aumenta de nível, geralmente resultando em aumento de atributos e novas habilidades.

**Mixin:** mecanismo em Dart que permite reutilizar código de uma classe em múltiplas classes sem usar herança. Implementado com a palavra-chave `with`.

**Mob:** abreviação de mobile, refere-se a inimigos comuns e repetidos. Diferente de boss, que são únicos ou raros.

**MUD (Multi-User Dungeon):** jogo de texto multiplayer baseado em exploração de calabouço. Precursor dos roguelikes modernos, ainda popular na comunidade de jogadores.

**MST (Minimum Spanning Tree / Árvore Geradora Mínima):** estrutura de grafo que conecta todos os nós com peso total mínimo, sem ciclos. Usada em geração procedural para conectar salas ou áreas sem sobreposição desnecessária.

**Null Safety:** recurso do Dart que torna seguro trabalhar com valores nulos. O compilador garante que variáveis não nulas nunca recebam `null`, prevenindo uma classe inteira de bugs.

**NPC (Non-Player Character):** personagem controlado pelo jogo, não pelo jogador. Pode ser comerciante, quest-giver, aliado ou simples decoração.

**Observer Pattern:** padrão de design que estabelece uma relação um-para-muitos entre objetos, onde mudanças em um objeto notificam automaticamente seus observadores.

**Package:** unidade de código reutilizável em Dart. Publicado no `pub.dev` e pode ser incluído em outros projetos via arquivo `pubspec.yaml`.

**Pathfinding:** algoritmo que encontra o caminho mais curto ou viável entre dois pontos. Exemplos incluem BFS, A* e Dijkstra.

**Permadeath (Morte Permanente):** característica central de roguelikes onde a morte do personagem é irreversível. Não há salvação automática, continuar ou desfazer. O personagem morre e a partida acaba, criando tensão e significado em cada decisão.

**Pattern Matching:** recurso de linguagem que permite comparar valores contra padrões complexos. Em Dart, usado em switch expressions e destructuring.

**Procedural Generation:** técnica que cria conteúdo do jogo algoritmicamente ao invés de manualmente. Gera dungeons, itens e obstáculos de forma aleatória mas controlada.

**Pub:** gerenciador de pacotes oficial do Dart. Permite publicar e consumir bibliotecas da comunidade.

**Ray Casting:** técnica que lança raios para determinar visibilidade. Mais simples que shadowcasting mas menos preciso em FOV.

**Refatoração:** processo de reestruturar código sem alterar seu comportamento externo. Melhora qualidade, legibilidade e mantenibilidade.

**Render:** processo de converter estado do jogo em saída visual que o jogador pode ver. No jogo ASCII, significa colocar caracteres corretos nas posições corretas.

**Roguelike:** gênero de jogo caracterizado por exploração de dungeon, combate por turnos, morte permanente (permadeath) e progressão de personagem. Inspirado no clássico Rogue de 1980.

**Rooms and Corridors:** algoritmo de geração procedural que cria dungeons colocando salas retangulares e conectando-as com corredores. Simples e eficiente.

**Random Walk:** técnica de geração onde um ponto se move aleatoriamente, deixando um rastro. Cria paisagens naturais e cavernas.

**Sealed Class:** classe cuja herança é restrita a classes específicas definidas no mesmo arquivo. Garante que todos os subtipos são conhecidos e gerenciáveis.

**Seed (Semente):** valor inicial que alimenta um gerador de números aleatórios. Mesma seed produz mesma sequência de números, permitindo reproduzir mapas e combates idênticos para debug e testes.

**Serialização:** processo de converter objetos em um formato que pode ser armazenado ou transmitido, como JSON. Essencial para sistema de save/load.

**Shadowcasting:** algoritmo avançado que calcula campo de visão de forma rápida e realista, tratando linha de visão e obstáculos corretamente.

**Sprite:** imagem 2D que representa um objeto no jogo. Em jogos ASCII, um sprite é um ou alguns caracteres que representam uma entidade.

**SDK (Software Development Kit):** conjunto de ferramentas para desenvolver aplicações. O Dart SDK inclui compilador, runtime e bibliotecas padrão.

**SOLID:** acrônimo para cinco princípios de design: Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion. Promove código flexível e sustentável.

**Spawn:** ato de criar uma nova entidade no jogo, como inimigo aparecendo em uma localização específica.

**State Pattern:** padrão de design que permite um objeto alterar seu comportamento quando seu estado interno muda. Implementado naturalmente com sealed classes em Dart.

**Strategy Pattern:** padrão de design que define uma família de algoritmos, encapsula cada um e os torna intercambiáveis. Permite selecionar algoritmo em tempo de execução.

**Stream:** sequência de eventos assíncronos em Dart. `StreamController` emite eventos, `listen()` os observa. Usado com Observer Pattern para reação a eventos sem acoplamento direto.

**StringBuffer:** estrutura em Dart para construir strings eficientemente, acumulando caracteres sem recriação de objetos. Essencial em renderização ASCII para montar cada frame completo antes de exibir.

**Teste Unitário:** teste automatizado que verifica comportamento de uma unidade de código isoladamente. Fundamental para garantir qualidade e evitar regressões.

**Test-Driven Development (TDD):** metodologia que escreve testes antes do código. Garante cobertura de teste e design orientado a testes.

**Tile:** unidade de grid no mapa, geralmente representado por um caractere ASCII. Cada tile ocupa uma posição [x, y] no dungeon.

**Turn-Based:** sistema de jogo onde ações ocorrem em turnos sequenciais. O jogador faz uma ação, inimigos respondem, e o ciclo continua. Comum em roguelikes.

**UI (User Interface):** interface visual através da qual o jogador interage com o jogo. Inclui menus, HUD, diálogos e controles.

**XP (Experience Points):** pontos ganhos ao derrotar inimigos ou completar objetivos. Acumulam para permitir level up do personagem.

## Do Mundo Real à Masmorra

Além das entradas alfabéticas acima, esta lista traduz o vocabulário da masmorra para conceitos de programação (e vice-versa). Use-a para ver como mecânicas de roguelike se expressam em Dart e na arquitetura do jogo. É um mapa bidirecional: comece no RPG e encontre o código, ou comece no código e encontre a mecânica do jogo.

**Masmorra** → *Loop principal (game loop)*
: O ciclo que mantém o jogo vivo: entrada → processamento → saída. A cada turno, o jogo lê ações, atualiza o estado e desenha na tela.

**Turno** → *Iteração do loop*
: Um ciclo completo da masmorra: o jogador age, os inimigos reagem, o mapa é desenhado.

**Personagem** → *Classe, Objeto*
: O herói é uma instância de uma classe `Jogador`, com atributos (nome, HP, inventário) e métodos (sofrer dano, usar item).

**Atributos (HP, força, agilidade)** → *Campos/Propriedades*
: Dados que definem o estado do personagem. HP é um int, força é um int, nome é uma String.

**Inventário** → *Lista (List)*
: Coleção ordenada de itens. Você pega itens em sequência (índice 0, 1, 2...).

**Loja do Mercador** → *Mapa (Map)*
: Cada item tem um nome (chave) e um preço (valor). "Espada" → 50 ouro, "Poção" → 20 ouro.

**Salas visitadas (exploração)** → *Conjunto (Set)*
: Você marca quais salas já visitou. Não importa a ordem, só se foi lá ou não. Muito rápido para verificar.

**Morte permanente (permadeath)** → *Sem try/catch, sem undo*
: Erro no combate? Game over. Sem salvação, sem continuar. É a verdade dos roguelikes.

**Magia/Habilidades** → *Polimorfismo (@override)*
: Zumbi sofre dano diferente de Esqueleto. Cada inimigo tem seu próprio `descreverAcao()`.

**Herança de classes de inimigos** → *Herança (extends)*
: Zumbi, Esqueleto, Lobo são todos Inimigos. Compartilham HP, método `sofrerDano()`, mas cada um age diferente.

**Poder compartilhado (todos sangram)** → *Mixin*
: Toda criatura que respira tem um método `sofrerDano()`. Em vez de copiar em cada classe, usamos mixin `Combatente`.

**Escudo mágico (null safety)** → *Null Safety*
: Dart garante que uma variável nunca será null sem sua permissão. Nenhuma surpresa de NullPointerException no meio do combate.

**Conhecimento tardio (só sabe quando pegar)** → *late*
: Você declara uma variável mas só a inicializa depois, quando precisar. `late String nomeMasmorra;`

**Contrato da criatura** → *Classe abstrata (abstract class)*
: Uma classe `Inimigo` define o contrato: toda criatura viva tem HP, pode sofrer dano, descreve sua ação.

**FOV (campo de visão)** → *Algoritmo, Set<Point>*
: O que o herói enxerga. Calcula-se com raycasting ou shadowcasting. Resulta em um Set de tiles visíveis.

**Névoa de guerra** → *Rastreamento de estado*
: Tiles que você já visitou (explorados) vs. nunca visitou (nunca visto). Booleano ou enum.

**Pathfinding (caminho ao inimigo)** → *Algoritmo A* ou BFS*
: Dado dois pontos (herói e inimigo), encontra o caminho mais curto. BFS é simples, A* é otimizado.

**Geração procedural** → *Random + Algoritmo*
: MapaMasmorra gera salas e corredores aleatoriamente a cada partida. Mesma seed = mesmo mapa.

**Colisão (parede, inimigo)** → *Verificação booleana*
: Posição (x, y) está ocupada? if (tilemap[x][y].temParede) bloqueia movimento.

**Tile (célula do mapa)** → *Posição (x, y)*
: Cada quadrado do grid. Uma sala é um conjunto de tiles. ASCII é um sprite simples.

**Sprite ASCII** → *Caractere único (char)*
: Um personagem, um inimigo, uma parede. 'Z' para zumbi, '@' para herói, '#' para parede.

**Roguelike** → *Gênero com regras*
: Exploração de dungeon, combate por turnos, morte permanente, progressão de personagem, geração procedural.

**Save (salvar partida)** → *Serialização + JSON*
: Objeto Jogador → Map → String JSON → Arquivo em disco. Persistência.

**Load (carregar partida)** → *Desserialização + JSON*
: String JSON → Map → Objeto Jogador. Reconstruir tudo da memória persistente.

**Boss final** → *Padrão especial*
: Inimigo com mais HP, mais dano, comportamento único. Marca o fim de um andar.

**Experience points (XP)** → *Contador inteiro*
: int xp acumula. Ao atingir threshold, level up. Base para crescimento de personagem.

**Level up** → *Aumento de atributos*
: Força sobe, HP máximo sobe. Resultado de acumular XP.

**Factory construtor (criar inimigo de dados)** → *Factory Constructor*
: `Inimigo.deJSON(Map dados)` retorna Zumbi, Esqueleto, ou Lobo conforme dados. Lógica centralizada.

**Padrão Strategy** → *Strategy Pattern*
: Cada inimigo tem uma IA: `patrulhar()`, `perseguir()`, `atacar()`. Algoritmo intercambiável por tipo.

**Padrão Command** → *Command Pattern*
: Ação do jogador: move norte, ataca, pega item. Cada uma é um Command que pode ser desfeita, registrada, ou executada depois.

**Padrão State** → *State Pattern*
: Inimigo em estado Patrulha, Alerta, Perseguição. Muda de estado quando vê jogador. Sealed class implementa isso bem.

**Padrão Observer** → *Observer Pattern*
: Quando algo morre, log ouve, UI ouve, som ouve. Event bus + Stream<Evento>. Baixo acoplamento.

**Máquina de estados (FSM)** → *Enum + Switch ou Sealed Class*
: Estado da entidade: vivo, morrendo, morto. Switch no estado, executa ação apropriada.

**Testabilidade** → *Testes Unitários*
: `test('jogador sofre dano', () { ... })`. Garante que sofrerDano(10) diminui HP de 10.

**Análise estática** → *dart analyze*
: Verifica erros antes de rodar. Variáveis não usadas, tipos errados, imports desnecessários.

**Gerenciador de pacotes** → *pub, pubspec.yaml*
: Declare dependências (package:test, etc). pub.dev é o repositório.

**Sandbox seguro** → *DartPad*
: Experimente Dart no navegador sem instalar nada. Perfeito para aprender.

**Estrutura do projeto** → *lib/, bin/, test/*
: lib/ tem código reutilizável. bin/ tem main(). test/ tem testes.

**Configuração de análise** → *analysis_options.yaml*
: Regras estritas: evita patterns perigosos, força estilos. Lint é customizável.

**Distribuição do jogo** → *dart compile exe*
: Compila para executável nativo. pub global install para ferramentas.

**Geração de eventos** → *Enum + Pattern Matching*
: Comandos do jogador como enum. Switch expression extrai dados: `switch(cmd) { ... }`.

**Registros heterogêneos** → *Records*
: Retornar múltiplos valores: `(bool sucesso, String mensagem)`. Melhor que Tuple ou classe auxiliar.

**Extensão de linguagem** → *Extension*
: `extension IntUtils on int { ... }` adiciona método a int sem herança. `5.vezes(() { ... })`.

**Cascata de operações** → *Cascade Operator (..)*
: `jogador..hp = 100..ouro = 0..moverPara('inicio')`. Encadeamento.

**Condicional em coleção** → *Collection if*
: `[item1, if (condicao) item2, item3]`. Construir lista com lógica inline.

**Loop em coleção** → *Collection for*
: `[...lista1, for (item in lista2) item.upper()]`. Flatten/map inline.

**Type alias** → *typedef*
: `typedef Acao = void Function()`. Nome legível para assinatura complexa de função.

**Genérico** → *Generic<T>*
: `List<Item>`, `Map<String, Inimigo>`. Reutiliza estrutura, força tipo.

**Processamento paralelo** → *Isolate*
: Cada Isolate é uma thread Dart. Fork para computação pesada sem bloquear UI.

**Contexto de execução** → *Zone*
: Intercepta erros, logs, timers num escopo. Útil para testes e debugging.

**Padrão Factory** → *Factory Pattern*
: `DefinicaoItem` tem factory para criar Item concreto. Centraliza criação e validação.

**Abstração de dados** → *Interface (implements)*
: Contrato de métodos que uma classe deve ter. Em Dart, `class X implements Y` força cumprir interface de Y.

**Getters e setters** → *Propriedades computadas*
: `int get hp => _hp;` expõe leitura segura. `set hp(int v) { if (v >= 0) _hp = v; }` valida escrita.

**Sobrecarga de operadores** → *operator overload*
: `class Ponto { Ponto operator+(Ponto other) { ... } }`. Usar `+`, `-`, `==` em tipos custom.

**Tipo abstrato / contrato** → *Sealed class*
: `sealed class Entidade { }` garante que só subclasses conhecidas existem. Exaustividade em switch.

## Como Usar Este Mapa Conceitual

- **Conceitos de programação:** comece na coluna "Termo de Programação". Se não souber o que é um `Stream`, procure na tabela e encontre a linha correspondente ao jogo.
- **Mecânicas da masmorra:** comece na coluna "Termo RPG". Para saber como "morte permanente" se relaciona com código, veja a coluna do meio e a descrição.
- **Padrões de design:** use as linhas de Strategy, Command, State e Observer para ligar teoria ao que o livro implementa no combate e na IA.
- **Dúvidas durante o desenvolvimento:** se você está implementando um feature e não sabe qual padrão usar, procure na coluna "Termo RPG" para encontrar sugestões de código.
