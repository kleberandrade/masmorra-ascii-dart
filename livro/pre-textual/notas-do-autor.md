# Notas do autor {.unnumbered}

## O que te espera no fundo da masmorra

Você vai aprender Dart construindo um roguelike no terminal: exploração, combate por turnos, geração procedural, economia, níveis e uma interface feita só com caracteres ASCII. Sem motor gráfico, sem framework de jogo, sem atalhos opacos. O que aparece na tela está lá porque você escreveu o código que o coloca, e quando algo falha, o stack trace aponta para você, que é exatamente onde um programador em formação quer estar.

## Para quem é este livro

Foi escrito para quem já deu os primeiros passos em outra linguagem, como variáveis, condicionais e funções, mas ainda não domina Dart ou nunca ligou um jogo do zero ao teclado. Se você já fez um "Hello World" em Python, JavaScript ou C#, está no lugar certo. Se veio do Flutter e só conhece Dart atrás dos widgets, vai ver a linguagem no seu habitat natural: rápida, tipada, exigente com o null, e terrivelmente satisfatória quando o `dart analyze` fica verde.

Não precisa de formação em jogos, algoritmos avançados ou padrões de projeto. Tudo isso aparece quando o jogo precisa, não como teoria isolada, mas como ferramenta para o próximo marco jogável.

## Como o livro está organizado

O livro divide-se em seis partes, cada uma com um marco que você pode executar e mostrar a alguém:

A Parte I (capítulos 1 a 7) assenta os fundamentos de Dart enquanto você constrói uma aventura textual com salas, itens e comandos. No fim, navega entre locais, manipula estado e fecha um loop de jogo estável.

A Parte II (capítulos 8 a 14) introduz orientação a objetos e transforma o projeto num MUD-lite com combate por turnos, ouro, armas equipáveis e vários tipos de inimigo com comportamentos distintos.

A Parte III (capítulos 15 a 21) leva o mundo para uma grade 2D em ASCII: mapa procedural, campo de visão, névoa de guerra e um dungeon crawl completo com múltiplos andares.

A Parte IV (capítulos 22 a 27) adiciona os sistemas que transformam o jogo em experiência completa: economia, loja, progressão de nível, boss final e uma run jogável do início ao fim.

A Parte V (capítulos 28 a 32) é engenharia de verdade: refatoração, testes unitários, organização de pacote, async/await e persistência com JSON para salvar o progresso entre sessões.

A Parte VI (capítulos 33 a 36) aplica padrões de projeto à IA e à estrutura do código: Strategy, Command, Factory, Observer e State. Termina com uma síntese que deixa você pronto para o ecossistema oficial (`dart.dev`) e para o salto natural rumo ao Flutter, se for esse o seu próximo andar.

## O repositório de código

Todo o código acompanha o livro com etiquetas Git (`step-01` a `step-36`), uma por capítulo. Você pode comparar estados, voltar quando algo der errado, ou clonar e rodar antes de escrever uma linha. O pacote vive em `code/masmorra_ascii/`, com testes, análise estática e linting alinhados ao que o livro prega.

## Como usar este livro

A melhor leitura é com o terminal aberto ao lado. Cada capítulo segue um ritmo: uma cena curta que motiva o conceito; a explicação em Dart com exemplos; a integração no jogo; desafios da masmorra para fixar o assunto, com um boss final no fim de cada capítulo.

Não pule os desafios. Não copie sem ler. Não tenha medo de quebrar o build: o Git e o compilador são os seus aliados mais chatos e mais úteis.

## Soluções dos desafios

As soluções de todos os desafios e boss finals propostos neste livro, juntamente com o código-fonte completo de todos os 36 passos da jornada de desenvolvimento da Masmorra ASCII, estão disponíveis online. Acesse o site abaixo para acompanhar sua evolução, comparar suas implementações e aprofundar seu aprendizado na criação de jogos com Dart.

**Site:** [masmorra.io](https://masmorra.io)

![Código QR para https://masmorra.io](qrcode-masmorra-io.png){width=4cm}

No site você também encontrará conteúdo adicional: errata e correções sugeridas pela comunidade, artigos e desafios bônus para expandir suas habilidades, e links para se conectar com outros desenvolvedores Dart e compartilhar suas criações.

A aventura na Masmorra ASCII não termina aqui. Visite [masmorra.io](https://masmorra.io), explore as soluções e continue evoluindo como programador Dart!

Boa descida. Que o seu `dart run` nunca lhe falte coragem nem curiosidade.
