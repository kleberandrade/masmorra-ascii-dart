import 'comando_jogo.dart';
import 'direcao.dart';

ComandoJogo analisarLinha(String entrada) {
  final linha = entrada.trim().toLowerCase();

  if (linha.isEmpty) {
    return const ComandoDesconhecido('(vazio)');
  }

  final palavras = linha.split(RegExp(r'\s+'));
  final verbo = palavras[0];
  final args = palavras.length > 1 ? palavras.sublist(1) : [];

  switch (verbo) {
    case 'n':
    case 'norte':
      return const ComandoMover(Direcao.norte);

    case 's':
    case 'sul':
      return const ComandoMover(Direcao.sul);

    case 'e':
    case 'leste':
      return const ComandoMover(Direcao.leste);

    case 'o':
    case 'oeste':
      return const ComandoMover(Direcao.oeste);

    case 'atacar':
    case 'a':
      if (args.isEmpty) {
        return const ComandoDesconhecido('atacar o quê?');
      }
      final alvo = args.join(' ');
      return ComandoAtacar(alvo);

    case 'inv':
    case 'inventario':
    case 'i':
      return const ComandoInventario();

    case 'pegar':
    case 'p':
      if (args.isEmpty) {
        return const ComandoDesconhecido('pegar o quê?');
      }
      final item = args.join(' ');
      return ComandoPegar(item);

    case 'status':
      return const ComandoStatus();

    case 'olhar':
    case 'ver':
    case 'l':
      return const ComandoOlhar();

    case 'ajuda':
    case 'help':
    case '?':
      return const ComandoAjuda();

    case 'sair':
    case 'quit':
    case 'exit':
      return const ComandoSair();

    default:
      return ComandoDesconhecido(entrada);
  }
}
