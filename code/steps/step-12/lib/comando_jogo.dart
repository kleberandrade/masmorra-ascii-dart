import 'direcao.dart';

sealed class ComandoJogo {
  const ComandoJogo();

  String executar();
}

class ComandoMover extends ComandoJogo {
  final Direcao direcao;

  const ComandoMover(this.direcao);

  @override
  String executar() => 'Movendo para ${direcao.simbolo}';
}

class ComandoAtacar extends ComandoJogo {
  final String alvo;

  const ComandoAtacar(this.alvo);

  @override
  String executar() => 'Atacando $alvo!';
}

class ComandoPegar extends ComandoJogo {
  final String item;

  const ComandoPegar(this.item);

  @override
  String executar() => 'Pegando $item';
}

class ComandoInventario extends ComandoJogo {
  const ComandoInventario();

  @override
  String executar() => 'Mostrando inventário...';
}

class ComandoStatus extends ComandoJogo {
  const ComandoStatus();

  @override
  String executar() => 'Mostrando status...';
}

class ComandoOlhar extends ComandoJogo {
  const ComandoOlhar();

  @override
  String executar() => 'Observando a sala...';
}

class ComandoAjuda extends ComandoJogo {
  const ComandoAjuda();

  @override
  String executar() =>
      'Comandos: norte/sul/leste/oeste, atacar, pegar, inv, status, olhar, ajuda, sair';
}

class ComandoSair extends ComandoJogo {
  const ComandoSair();

  @override
  String executar() => 'Até logo!';
}

class ComandoDesconhecido extends ComandoJogo {
  final String entrada;

  const ComandoDesconhecido(this.entrada);

  @override
  String executar() => 'Não entendo "$entrada". Tente "ajuda".';
}
