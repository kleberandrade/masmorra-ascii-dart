# Apêndice E - Terminal, ANSI e Solução de Problemas

> *Metade dos bugs de um roguelike ASCII não estão no código: estão no terminal que o executa. Este apêndice é o seu kit de primeiros socorros quando o jogo roda mas aparece torto, colorido demais, colorido de menos, ou quando caracteres viram losangos misteriosos.*

Você já tem o jogo funcionando. Ele compila, os testes passam, o `dart run` não reclama. Mesmo assim, uma hora alguém (você ou um amigo que você convidou para jogar) vai abrir o terminal e ver: códigos estranhos tipo `\x1B[31m` em vez de cor vermelha, caixas quebradas em vez de molduras (`â•”â•â•—` em vez de `╔═╗`), ou emojis e ícones que viraram quadrados vazios. Este apêndice reúne os problemas mais comuns e suas soluções.

## Entendendo códigos ANSI

ANSI escape codes são sequências especiais começando com `\x1B[` (o caractere ESC) que o terminal interpreta como comandos: mudar cor, mover cursor, limpar tela. Quando você vê `\x1B[31mTexto\x1B[0m` literalmente na tela, significa que o terminal **não está interpretando** ANSI — está imprimindo os códigos como texto cru.

```dart
const vermelho = '\x1B[31m';
const reset = '\x1B[0m';
print('${vermelho}HP crítico!$reset');
```

Em um terminal que suporta ANSI, a frase aparece vermelha. Em um que não suporta, você vê literalmente `←[31mHP crítico!←[0m`.

## Problemas comuns e soluções

### Problema 1: códigos ANSI aparecem como texto

**Sintoma:** Você vê `\x1B[31m` ou `←[31m` no terminal em vez das cores.

**Causa:** Terminal sem suporte ANSI (`cmd.exe` antigo, PowerShell 5.x sem configuração).

**Soluções:**

- **Windows:** Instale Windows Terminal da Microsoft Store (gratuito). Suporta ANSI nativamente e é rápido.
- **PowerShell:** Use versão 7+. A versão 5 que vem com o Windows tem suporte ANSI limitado.
- **Fallback em código:** Detecte o terminal e desabilite cores quando necessário.

```dart
import 'dart:io';

bool get suportaAnsi {
  if (Platform.isWindows) {
    // Windows Terminal define WT_SESSION; cmd.exe antigo não
    return Platform.environment.containsKey('WT_SESSION') ||
           Platform.environment['TERM'] != null;
  }
  return stdout.hasTerminal;
}

String colorir(String texto, String codigoAnsi) {
  if (!suportaAnsi) return texto;
  return '$codigoAnsi$texto\x1B[0m';
}
```

### Problema 2: caracteres box-drawing quebrados

**Sintoma:** Você escreveu `╔═══╗` no código e vê `â•”â•â•â•â•—` no terminal, ou aparece `???`, ou quadrados vazios.

**Causa:** Encoding errado. O terminal não está lendo UTF-8.

**Soluções:**

- **Windows:** Antes de rodar `dart run`, execute `chcp 65001` no mesmo terminal. Isso muda a página de código para UTF-8.
- **Verifique o arquivo:** Confirme que seus `.dart` estão salvos em UTF-8 (sem BOM). Quase todos os editores modernos fazem isso por padrão.
- **Fonte do terminal:** Algumas fontes não têm todos os caracteres Unicode. Troque para JetBrains Mono, Fira Code, DejaVu Sans Mono ou Consolas.

### Problema 3: alinhamento quebrado

**Sintoma:** A arte ASCII aparece torta, colunas desalinhadas, bordas que não fecham.

**Causa:** Fonte proporcional (não monoespaçada).

**Solução:** Troque para fonte monoespaçada nas configurações do terminal:

- Windows Terminal: Settings → Profile → Appearance → Font face.
- macOS Terminal.app: Preferences → Profiles → Text → Font.
- iTerm2: Preferences → Profiles → Text → Font.
- Linux GNOME Terminal: Preferences → Profile → Text → Custom font.

### Problema 4: emojis e ícones viram quadrados

**Sintoma:** Você usa um emoji colorido no código (por exemplo, símbolo de moeda), mas aparece `□` ou `?`.

**Causa:** A fonte do terminal não tem os glifos dos emojis.

**Soluções:**

- Use fontes com suporte a emojis: JetBrains Mono com Nerd Fonts, Cascadia Code, ou similar.
- Evite emojis e use caracteres ASCII simples: `$` para ouro, `*` para item, `@` para jogador.
- Crie uma camada de abstração que troca emojis por ASCII quando detectar falta de suporte.

```dart
// Prefira ASCII no terminal (evita quadrados se a fonte não tiver emoji):
String get iconeOuro => '\$';
String get iconeInimigo => 'X';
```

### Problema 5: cores muito fracas ou invertidas

**Sintoma:** Vermelho parece rosa, azul invisível sobre fundo escuro, texto ilegível.

**Causa:** Tema do terminal com paleta ruim, ou contraste insuficiente.

**Soluções:**

- Troque para um tema com alto contraste: Solarized Dark, Dracula, One Dark, Gruvbox.
- Use cores **brilhantes** (códigos 90-97) em vez das normais (30-37) para fundo escuro:
  - `\x1B[91m` (vermelho brilhante) em vez de `\x1B[31m` (vermelho normal).
- Evite combinações ruins: azul escuro em fundo preto é quase invisível.

### Problema 6: tela pisca ou cursor desaparece

**Sintoma:** Ao redesenhar o mapa a cada turno, a tela pisca visivelmente, ou o cursor some.

**Causa:** Você está limpando a tela com `print` de muitas linhas em branco.

**Solução:** Use ANSI para limpar tela e reposicionar cursor:

```dart
void limparTela() {
  stdout.write('\x1B[2J\x1B[H'); // limpa tela + cursor no topo
}

void esconderCursor() => stdout.write('\x1B[?25l');
void mostrarCursor()  => stdout.write('\x1B[?25h');
```

Chame `esconderCursor()` no início do jogo e `mostrarCursor()` ao sair. Redesenhe com `limparTela()` antes de imprimir o novo frame.

### Problema 7: `stdin.readLineSync()` bloqueia tudo

**Sintoma:** Você quer input sem Enter (pressionar W e já mover), mas `readLineSync` exige Enter.

**Causa:** `stdin` está em modo **line mode** por padrão.

**Solução:** Coloque o terminal em modo raw:

```dart
import 'dart:io';

stdin.echoMode = false;
stdin.lineMode = false;

int byte = stdin.readByteSync(); // lê uma tecla só, sem Enter
```

Lembre-se de **restaurar** os modos antes de sair, ou o terminal do usuário fica estranho depois:

```dart
void sairLimpo() {
  stdin.echoMode = true;
  stdin.lineMode = true;
  mostrarCursor();
  exit(0);
}
```

## Teste rápido do terminal

Rode este snippet para diagnosticar seu terminal em 5 segundos:

```dart
void main() {
  print('\x1B[31mVermelho\x1B[0m \x1B[32mVerde\x1B[0m \x1B[34mAzul\x1B[0m');
  print('Box: ╔═════╗');
  print('      ║ OK  ║');
  print('      ╚═════╝');
  print('Emoji: ❤️');
  print('UTF: ção — áéíóú');
}
```

Se você vê cores, caixa alinhada com cantos arredondados bonitos e acentos corretos, seu terminal está pronto. Se algum desses falhar, volte à seção correspondente acima.

## Recomendações finais por sistema

**Windows:** Windows Terminal + PowerShell 7 + fonte Cascadia Code ou JetBrains Mono.

**macOS:** iTerm2 + zsh + fonte JetBrains Mono.

**Linux:** Alacritty ou Kitty (performance) ou GNOME Terminal (padrão do Ubuntu) + fonte JetBrains Mono.

**Qualquer sistema:** se o terminal não quiser cooperar, ative um modo "plain" no seu jogo que desliga cores ANSI e troca caracteres Unicode por ASCII puro. Assim o jogo funciona em qualquer canto, mesmo em um servidor SSH precário ou num CI que não sabe o que é cor.

## Mais fundo do que isso

Se quiser se aprofundar, existem bibliotecas Dart específicas para manipulação de terminal que abstraem muito do que foi mostrado aqui: `dart_console`, `ansi_styles`, `tint`. Elas resolvem detecção de suporte ANSI, paletas de cores e input raw de forma portável. Mas, para este livro, trabalhamos com o que a biblioteca padrão `dart:io` oferece — porque entender o que acontece em baixo nível deixa você pronto para usar qualquer biblioteca depois.
