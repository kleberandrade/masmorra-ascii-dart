/// Cap. 12 / 21 — comandos como tipos (pattern matching no motor).
sealed class ComandoJogo {}

class CmdOlhar extends ComandoJogo {}

class CmdIr extends ComandoJogo {
  CmdIr(this.direcao);
  final String direcao;
}

class CmdInventario extends ComandoJogo {}

class CmdEquipar extends ComandoJogo {
  CmdEquipar(this.id);
  final String id;
}

class CmdAtacar extends ComandoJogo {}

class CmdMenu extends ComandoJogo {}

class CmdDescer extends ComandoJogo {}

class CmdSubir extends ComandoJogo {}

class CmdLojaListar extends ComandoJogo {}

class CmdComprar extends ComandoJogo {
  CmdComprar(this.id);
  final String id;
}

class CmdVender extends ComandoJogo {
  CmdVender(this.slot);
  final int slot;
}

class CmdDesconhecido extends ComandoJogo {
  CmdDesconhecido(this.trecho);
  final String trecho;
}
