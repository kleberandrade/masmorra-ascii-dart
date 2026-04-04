/// Biblioteca do livro *Masmorra ASCII* — modelo, UI textual e sessão de jogo.
library;

// Combate
export 'src/combate/combate.dart';

// Economia
export 'src/economia/loja.dart';

// IA
export 'src/ia/acao_combate.dart';
export 'src/ia/estado_ia.dart';

// Jogo
export 'src/jogo/sessao_jogo.dart';

// Modelos
export 'src/modelos/fabrica_inimigo.dart';
export 'src/modelos/inimigo.dart';
export 'src/modelos/item.dart';
export 'src/modelos/jogador.dart';
export 'src/modelos/sala.dart';

// Mundo
export 'src/mundo/dados_mundo.dart';
export 'src/mundo/mapa_masmorra.dart';
export 'src/mundo/mundo_texto.dart';

// Parse
export 'src/parse/comando_jogo.dart';
export 'src/parse/parseador.dart';

// Persistência
export 'src/persistencia/gerenciador_salve.dart';

// UI
export 'src/tela_ascii.dart';
export 'src/ui/banner.dart';
