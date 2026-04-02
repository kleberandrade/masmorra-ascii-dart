/// Cap. 12 / 21 — comandos como tipos (pattern matching no motor).
sealed class GameCommand {}

class CmdOlhar extends GameCommand {}

class CmdIr extends GameCommand {
  CmdIr(this.direcao);
  final String direcao;
}

class CmdInventario extends GameCommand {}

class CmdEquipar extends GameCommand {
  CmdEquipar(this.id);
  final String id;
}

class CmdAtacar extends GameCommand {}

class CmdMenu extends GameCommand {}

class CmdDescer extends GameCommand {}

class CmdSubir extends GameCommand {}

class CmdLojaListar extends GameCommand {}

class CmdComprar extends GameCommand {
  CmdComprar(this.id);
  final String id;
}

class CmdVender extends GameCommand {
  CmdVender(this.slot);
  final int slot;
}

class CmdDesconhecido extends GameCommand {
  CmdDesconhecido(this.trecho);
  final String trecho;
}
