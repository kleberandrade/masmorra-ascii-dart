import 'comando_jogo.dart';

/// Cap. 12 — parser estilo MUD (primeira palavra + resto).
ComandoJogo analisarLinha(String linha) {
  final t = linha.trim().toLowerCase();
  if (t.isEmpty) {
    return CmdDesconhecido('(vazio)');
  }
  final partes = t.split(RegExp(r'\s+'));
  final verbo = partes.first;
  final resto = partes.length > 1 ? partes.sublist(1).join(' ') : '';

  switch (verbo) {
    case 'olhar':
    case 'l':
      return CmdOlhar();
    case 'norte':
    case 'n':
      return CmdIr('norte');
    case 'sul':
    case 's':
      return CmdIr('sul');
    case 'este':
    case 'leste':
    case 'e':
      return CmdIr('este');
    case 'oeste':
    case 'o':
      return CmdIr('oeste');
    case 'inventario':
    case 'inv':
    case 'i':
      return CmdInventario();
    case 'equipar':
    case 'eq':
      if (resto.isEmpty) {
        return CmdDesconhecido('equipar precisa de id (ex.: equipar espada_curta)');
      }
      return CmdEquipar(resto);
    case 'atacar':
    case 'a':
      return CmdAtacar();
    case 'menu':
    case 'voltar':
      return CmdMenu();
    case 'descer':
      return CmdDescer();
    case 'subir':
      return CmdSubir();
    case 'loja':
      return CmdLojaListar();
    case 'comprar':
    case 'buy':
      if (resto.isEmpty) {
        return CmdDesconhecido('comprar <id>');
      }
      return CmdComprar(resto);
    case 'vender':
    case 'sell':
      final slot = int.tryParse(resto);
      if (slot == null) {
        return CmdDesconhecido('vender <índice>');
      }
      return CmdVender(slot);
    default:
      return CmdDesconhecido(verbo);
  }
}
