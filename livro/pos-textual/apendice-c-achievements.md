# Apêndice C: Achievements do Aventureiro {.unnumbered}

Que tal tornar sua jornada ainda mais épica? Cada seção do livro traz uma série de conquistas que você pode desbloquear conforme avança. Marque o checkbox ao lado assim que completar o desafio. Alguns achievements são bem diretos: código escrito, teste rodando, feature funcionando. Outros exigem um toque extra de criatividade e pensamento além do esperado. A diversão está em conseguir todos antes de cravar a melhor pontuação possível na masmorra final.

Prepare-se: há alguns achievements secretos escondidos pela floresta. Se você os encontrar, você merece um prêmio especial (spoiler: é a satisfação intelectual de saber que subiu mais fundo do que a maioria).

## Primeiros Passos

Capítulos 1–7: A jornada começa aqui. Você está aprendendo os fundamentos de Dart e ganhando confiança com cada linha de código. Critério: código compila sem erros.

[ ] **Hello, World!** – Compilou e rodou seu primeiro programa Dart no terminal. Critério: `print('Hello, World!')` aparece na tela.

[ ] **Que Comece o Jogo!** – Criou a estrutura básica do jogo com input e output funcionando. Critério: pode digitar um comando e receber resposta.

[ ] **Guerreiro Iniciante** – Definiu a classe `Jogador` com propriedades básicas (nome, vida, ataque). Critério: classe compila e pode criar uma instância com `Jogador('teste', 100, 10)`.

[ ] **Conhecedor de Tipos** – Usou corretamente pelo menos 5 tipos primitivos diferentes de Dart (int, double, String, bool, List). Critério: todas as variáveis typadas corretamente, sem erros de análise estática.

[ ] **Organizador de Código** – Criou sua primeira classe e instanciou um objeto com sucesso. Critério: classe instantiada e método chamado nela sem erro.

[ ] **Mestre das Variáveis** – Declarou corretamente variáveis nulas e não-nulas usando null safety. Critério: sem avisos de análise estática sobre null safety; código permite `?` onde apropriado.

[ ] **Desafio Extra: Personagem Único** – Criou uma classe `Jogador` com 3 atributos customizados além dos básicos (nome, vida, ataque). Critério: novos atributos aparecem em `toString()` ou getter.

[ ] **Konami Code** — Implementou uma sequência secreta de inputs no jogo (↑↑↓↓←→←→BA). Não dá vida extra, mas dá respeito.

## Orientação a Objetos

Capítulos 8–14: O código ganha profundidade. Herança, polimorfismo e abstrações tornam seu jogo muito mais elegante. Critério: padrão OOP implementado e testado.

[ ] **Construtor Primordial** – Implementou um construtor nomeado em uma classe. Critério: `Jogador.iniciante(String nome)` existe e funciona sem `new`.

[ ] **Getter Dos Deuses** – Usou seu primeiro getter para encapsular uma propriedade privada. Critério: propriedade prefixada com `_`, acesso via getter público.

[ ] **Herança Domada** – Criou uma classe que estende outra (ex: `Guerreiro extends Jogador`). Critério: subclasse compila, herda propriedades, pode fazer `super()`.

[ ] **Polimorfismo em Ação** – Override de um método da classe pai na classe filha com `@override`. Critério: subclasse sobrescreve método; comportamento diferencia conforme tipo.

[ ] **Classes Abstratas Decifradas** – Criou uma classe abstrata e implementou suas funções obrigatórias. Critério: `abstract class Inimigo` existe; subclasses implementam todos os métodos abstratos.

[ ] **Inimigo Forjado** – Criou pelo menos 3 tipos de inimigos diferentes com comportamentos distintos. Critério: `Zumbi`, `Esqueleto`, `Lobo` existem e cada um age diferente em combate.

[ ] **Mixin do Poder** – Usou um mixin para adicionar funcionalidade a uma classe. Critério: `mixin Combatente { ... }` ou similar existe; classe usa `with Combatente`.

[ ] **Desafio Extra: Hierarquia Completa** – Criou uma árvore de herança com 4+ classes relacionadas. Critério: `Inimigo` → `ZumbiComum`, `Esqueleto`, `Boss`, `Dragão` (ou similar).

## A Masmorra Ganha Vida

Capítulos 15–21: A masmorra deixa de ser teoria e vira um mundo real. Salas, itens, monstros e sistema de combate entram em cena.

[ ] **Cartógrafo da Masmorra** – Criou um sistema de salas conectadas. Critério: mapa com 10+ salas navináveis via comando `mover norte/sul/leste/oeste`.

[ ] **Gerador de Mundos** – Implementou a geração procedural de masmorras. Critério: novo `dart run` gera mapa diferente; usando algoritmo ou `Random`.

[ ] **Primeira Espada** – Criou o sistema de itens com uma arma funcionando. Critério: classe `Arma` ou `Item` existe; pode ser equipada e usada em combate.

[ ] **Poção Curativa** – Implementou um item que cura dano. Critério: poção aumenta HP do jogador quando usada; `receberCura(50)` funciona.

[ ] **Combate Realizado** – Fez seu primeiro combate entre jogador e inimigo. Critério: combate por turnos ocorre; jogador e inimigo trocam ataques.

[ ] **Vitória Épica** – Derrotou um inimigo no combate (vida chegou a 0). Critério: inimigo morre; seu HP exibe `0` ou sai do jogo.

[ ] **Sobrevivente** – Tomou dano, se recuperou com uma poção e continuou vivo. Critério: `jogador.vida < max`, usou poção, `jogador.vida > 0` após.

[ ] **Desafio Extra: Boss de Andar** – Criou um inimigo especial mais forte que aparece a cada 5 andares. Critério: boss tem 3x+ HP e ataque; aparece em andar 5, 10, 15, etc.

## Economia e Combate

Capítulos 22–27: Moedas de ouro, loot, balanceamento e tática entram na equação. Seu jogo fica viciante.

[ ] **Primeira Moeda de Ouro** – Ganhou sua primeira moeda derrotando um inimigo. Critério: `jogador.ouro` aumenta após matar inimigo.

[ ] **Caçador de Tesouro** – Coletou ao menos 100 moedas de ouro em uma sessão. Critério: `jogador.ouro >= 100` antes de salvar/sair.

[ ] **Loot Épico** – Um inimigo dropou um item raro (chance < 25%). Critério: inimigo morre, item raro aparece (ex: anel mágico, poção rara).

[ ] **Comerciante Experiente** – Comprou um item em uma loja ou vendeu algo. Critério: transação completa; ouro transferido, inventário modificado.

[ ] **Armadura Forjada** – Equipou uma peça de armadura que reduz dano recebido. Critério: defesa aumenta; dano sofrido é menor após equipar.

[ ] **Estratégia Vencedora** – Usou tática no combate escolhendo ataque vs defesa. Critério: combate tem opções (não apenas ataque automático); suas escolhas afetam o resultado.

[ ] **Derrotado e Revivido** – Morreu, carregou save anterior e venceu a masmorra. Critério: game over ocorreu; recarregou save; continuou e venceu.

[ ] **Desafio Extra: Fortuna de um Rei** – Reuniu 1000+ moedas de ouro sem gastar nada. Critério: `jogador.ouro >= 1000` em uma partida contínua.

## Código Profissional

Capítulos 28–32: Testes, tratamento de erro, I/O de arquivos e code smell desaparecem. Seu jogo é mantível.

[ ] **Testador Devotado** – Escreveu seu primeiro teste unitário usando `package:test`. Critério: arquivo `.test.dart` ou em `test/`, teste passa.

[ ] **Cobertura Completa** – Escreveu testes para 3+ métodos diferentes. Critério: 3+ funções testadas; cada teste valida comportamento específico.

[ ] **Exceção Tratada** – Implementou `try/catch` para lidar com um erro de forma elegante. Critério: exceção capturada, mensagem amigável exibida, jogo continua.

[ ] **Save and Load** – Salvou um progresso em arquivo e carregou de volta com sucesso. Critério: `salvar()` cria arquivo; `carregar()` reconstrói estado idêntico.

[ ] **JSON Dominado** – Serializou uma classe complexa para JSON e desserializou. Critério: `Jogador.toJson()` e `Jogador.fromJson()` funcionam corretamente.

[ ] **Debug Eficiente** – Usou `print` ou debugger para encontrar e corrigir um bug. Critério: bug identificado via logs; correção aplicada; teste passa.

[ ] **I Am Error** — Encontrou e corrigiu um bug em código alheio antes de ser avisado. Zelda II manda lembranças.

[ ] **Desafio Extra: Teste de Integração** – Escreveu um teste que valida combate completo. Critério: teste simula combate início→fim; verifica HP, morte, loot.

## Mestre dos Padrões

Capítulos 33–36: Strategy, Factory, Observer, Command, State. Você agora pensa em padrões. Seu código respira elegância.

[ ] **Factory Fundamental** – Implementou uma Factory para criar inimigos. Critério: `InimigoFactory.criar(tipo, andar)` existe; retorna tipo correto conforme parâmetros.

[ ] **Strategy Sutil** – Diferentes inimigos usam estratégias de IA diferentes. Critério: `enum Estrategia` ou `abstract class Estrategia`; `Zumbi`, `Lobo` comportam-se diferente.

[ ] **Observer Atento** – Usou `Stream` para notificar múltiplos listeners de um evento. Critério: `StreamController` emite; múltiplos `.listen()` recebem.

[ ] **Command Armazenado** – Implementou Command pattern com `execute()` e `desfazer()`. Critério: comando executável e revertível; histórico mantido.

[ ] **Estado Máquina** – Usou State pattern para estado de combate ou comportamento de inimigo. Critério: `enum EstadoCombate` ou sealed class; estados mudam corretamente.

[ ] **Sealed Class Power** – Usou `sealed class` e pattern matching. Critério: `sealed class Comando { ... }` com subclasses; `switch` exaustivo funciona.

[ ] **Desafio Extra: Todos os Padrões** – Integrou todos os 6 padrões em um jogo funcionando. Critério: jogo roda; cada padrão aparece no código; nenhum é dummy.

## Achievements Secretos

Desafios especiais que requerem um pouco de criatividade e pensamento lateral. Se você encontrar um, você merece bragging rights; uma história para contar.

[ ] **A Verdade está Aqui** – Encontrou uma mensagem de easter egg escondida no código. Critério: mensagem de humor ou referência dentro de classe, comentário ou saída.

[ ] **Programador Filosófico** – Refletiu sobre sua própria arquitetura e refatorou por vontade própria. Critério: refator não pedido no livro; melhora legibilidade/performance.

[ ] **Mentorado** – Ajudou alguém a entender um conceito do livro ou resolveu uma dúvida deles. Critério: conversou com alguém; explicou padrão ou conceito; pessoa aprendeu.

[ ] **Open Source Spirit** – Compartilhou seu código em repositório público (GitHub, GitLab). Critério: repositório acessível, código visível, pelo menos 1 commit.

[ ] **Extensão Criativa** – Adicionou uma feature completamente original não mencionada no livro. Critério: feature funciona; não é apenas copy-paste; você a desenhou.

[ ] **Performance Optimizado** – Identificou um gargalo de performance e otimizou. Critério: benchmark antes/depois; melhora mensurável (geração mais rápida, render mais suave).

[ ] **Documentação Impecável** – Documentou suas classes com docstrings explicativas. Critério: `///` comments em todas as classes públicas e métodos públicos.

[ ] **Hackathon Pessoal** – Completou o livro inteiro em menos de 30 dias. Critério: timestamp de criação para capitulo final antes de 30 dias do primeiro.

[ ] **Desafio Ultra: MUD Multiplayer** – Seguiu o Apêndice B e implementou versão em rede. Critério: servidor WebSocket roda; 2+ clientes conectam simultaneamente; sincronização funciona.

[ ] **Void Spirit** – Entendeu completamente `null safety` sem pensar mais uma vez. Critério: Seu código não tem avisos de null safety; você usa `?`, `??`, `late` corretamente por reflexo.

[ ] **Do a Barrel Roll** — Implementou rotação ou transformação de mapa. Peppy Hare aprovaria.

[ ] **The Cake Is a Lie** — Descobriu que um save corrompido não é o que parece. GLaDOS ficaria orgulhosa.

[ ] **It's Dangerous to Go Alone** ⚔️ — Completou o MUD multiplayer do Apêndice B. Agora leve um amigo.

[ ] **There Is No Spoon** — Dominou null safety a ponto de nunca precisar do operador `!`. Neo aprovaria.

---

**Parabéns!** Se você chegou aqui e marcou tudo (ou mesmo a maioria), você não apenas leu um livro. Você aprendeu Dart de verdade, engenharia de software em contexto, e criou um jogo que respira inteligência. Você não é apenas um programador agora. Você é um verdadeiro construtor de mundos. E a próxima masmorra que você explorar (seja em código ou em vida) você entra diferente.
