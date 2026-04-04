# Notas do autor {.unnumbered}

## O que te espera no fundo da masmorra

Você vai aprender Dart construindo um roguelike funcional no terminal: exploração com campo de visão, combate tático por turnos, geração procedural de mapas, economia dinâmica, progressão através de múltiplos níveis, e uma interface completa feita exclusivamente com caracteres ASCII. Sem motor gráfico de terceiros, sem framework de jogo pronto, sem atalhos opacos que escondem como as coisas realmente funcionam. Tudo aquilo que aparece na tela está lá porque *você escreveu o código* que o coloca, linha após linha. E quando algo falha (e vai falhar) o stack trace aponta precisamente para você, para o seu código, que é exatamente onde um programador em formação precisa estar para crescer.

## Para quem é este livro

Foi escrito para quem já deu os primeiros passos em alguma linguagem de programação: alguém que entende variáveis, condicionais e funções, mas ainda não domina Dart ou nunca montou um jogo do zero ao teclado. Se você já escreveu um "Hello World" em Python, JavaScript, C# ou Ruby, está no lugar certo. Se veio do Flutter e só conhece Dart através do padrão dos widgets e da reatividade, vai descobrir a linguagem em seu habitat natural: rápida, tipada com rigor, exigente com o `null`, e terrivelmente satisfatória quando o `dart analyze` fica verde de saúde.

Você não precisa (absolutamente não precisa) de formação em design de jogos, algoritmos avançados, ou padrões de projeto memorizados em livros. Tudo isso emerge quando o jogo o exige, não como teoria isolada ou exercício escolar, mas como ferramenta concreta para construir o próximo marco jogável, o próximo degrau descido.

## Como o livro está organizado

O livro divide-se em seis partes, cada uma com um marco funcional que você pode executar, testar e mostrar a alguém com genuíno orgulho:

**A Parte I** (capítulos 1 a 7) assenta os fundamentos sólidos de Dart enquanto você constrói uma aventura textual viva: salas conectadas, itens que você manipula, comandos que o computador compreende. No fim desta jornada inicial, você navega entre locais reais, manipula estado que persiste, e o loop de jogo está fechado e estável.

**A Parte II** (capítulos 8 a 14) introduz orientação a objetos em profundidade e transforma o projeto num MUD-lite genuíno: combate tático por turnos, ouro que você acumula, armas que você equipa e desequipa, vários tipos de inimigo cada um com comportamentos e estratégias distintas.

**A Parte III** (capítulos 15 a 21) leva todo o mundo para uma grade bidimensional em puro ASCII: geração procedural de mapas que nunca são iguais, campo de visão realista, névoa de guerra que envolve o desconhecido, e um dungeon crawl completo descendo através de múltiplos andares sucessivos.

**A Parte IV** (capítulos 22 a 27) adiciona os sistemas sofisticados que transformam o jogo em experiência completa e coerente: economia funcional, loja interativa, progressão de nível com benefícios tangíveis, um boss final que assusta, e uma run inteira jogável do primeiro movimento até a vitória ou morte.

**A Parte V** (capítulos 28 a 32) é engenharia de verdade, refatoração profissional: organização modular, testes unitários que você escreve e que protegem seu código, async/await para operações não bloqueantes, e persistência com JSON para salvar a progressão entre sessões (sim, você pode sair e voltar).

**A Parte VI** (capítulos 33 a 36) aplica padrões de projeto clássicos à IA inimiga e à arquitetura do código: Strategy para comportamentos variáveis, Command para fila de ações, Factory para criação de entidades, Observer para sistemas de eventos, e State para máquinas de estados. Termina com uma síntese profunda que deixa você não apenas pronto para explorar o ecossistema oficial em `dart.dev`, mas também preparado para o salto natural rumo ao Flutter, se esse for o seu próximo andar na torre.

## Configuração do terminal

A Masmorra ASCII depende do terminal para sua apresentação visual: caracteres especiais, barras coloridas (com ANSI), arte ASCII. Para uma experiência ideal, você precisa de um terminal bem configurado.

**Windows**: Recomendamos **Windows Terminal** (versão moderna e rápida, disponível na Microsoft Store). O `cmd.exe` antigo e o PowerShell legado não suportam completamente ANSI ou caracteres box-drawing. Para habilitar suporte a ANSI, nenhuma configuração adicional é necessária no Windows Terminal moderno. Se quiser usar PowerShell, prefira a versão 7+.

**macOS**: O **Terminal.app** padrão funciona bem, mas **iTerm2** oferece renderização superior e melhor suporte a cores e caracteres especiais. Qualquer um dos dois renderizará a arte ASCII corretamente.

**Linux**: Praticamente todos os terminais funcionam (GNOME Terminal, Konsole, Alacritty). Nenhuma configuração especial é necessária. Se quiser máxima performance e renderização limpa, use Alacritty.

**Fonte**: Use uma **fonte monoespaçada** de qualidade. Recomendações: JetBrains Mono, Fira Code, Consolas ou DejaVu Sans Mono. Evite fontes proporcionais, pois elas quebram o alinhamento de arte ASCII.

**Teste rápido**: Execute `dart run` no projeto. Se ver saída colorida (se suportada) e caracteres box-drawing alinhados (╔═╗║), sua configuração está correta. Se os caracteres ficarem desalinhados ou ANSI não aparecer, verifique a fonte e o suporte ANSI do seu terminal.

## O repositório de código

Todo o código-fonte acompanha este livro com etiquetas Git (`step-01` até `step-36`), uma por capítulo, tornando fácil comparar estados em diferentes marcos da jornada. Você pode explorar diferenças entre etapas, voltar quando algo der inesperadamente errado, ou clonar um ponto específico e rodar antes de escrever uma linha sequer, apenas para entender. O pacote vive em `code/masmorra_ascii/`, estruturado com testes automatizados, análise estática rigorosa, e linting configurado conforme o livro prega.

## Como usar este livro

A experiência ideal é com o terminal aberto ao lado da leitura, lado a lado, sem distrações. Cada capítulo segue um ritmo cuidadosamente planejado: uma cena narrativa breve que motiva o conceito a vir; a explicação clara em Dart com exemplos concretos; a integração desse conceito no jogo vivo; desafios da masmorra para fixar e aprofundar o aprendizado; um boss final no fim de cada capítulo, um desafio maior que testa tudo que você aprendeu.

Não pule os desafios. Quebre-se neles. Não copie sem ler. Leia o código antes de rodar. Não tenha medo de quebrar o build: o Git e o compilador são seus aliados mais chatos e, paradoxalmente, mais úteis para aprender.

## Soluções dos desafios

As soluções completas de todos os desafios e boss finals propostos neste livro, juntamente com o código-fonte íntegro de todos os 36 passos da jornada de desenvolvimento da Masmorra ASCII, estão disponíveis online. Acesse o site abaixo para acompanhar sua própria evolução, comparar suas implementações com as soluções de referência, aprofundar seu entendimento através de múltiplas abordagens, e continuar aprendendo na criação de jogos com Dart.

**Site:** [masmorra.io](https://masmorra.io)

![Código QR para https://masmorra.io](qrcode-masmorra-io.png){width=4cm}

No site você encontrará muito mais: errata viva e correções sugeridas pela comunidade que estuda conosco, artigos profundos sobre tópicos que o livro toca em superfície, desafios bônus para expandir suas habilidades além dos capítulos, e comunidades onde se conectar com outros desenvolvedores Dart, pessoas que estão na mesma descida que você, construindo seus próprios roguelikes e compartilhando criações.

A aventura na Masmorra ASCII não termina quando você fecha este livro. Visite [masmorra.io](https://masmorra.io), explore as soluções, discuta com a comunidade, e continue evoluindo como programador e construtor de mundos Dart.

Boa descida, então. Que o seu `dart run` nunca lhe falte coragem, curiosidade, ou a teimosia necessária para depurar o impossível até que ele clique em lugar de quebrar.
