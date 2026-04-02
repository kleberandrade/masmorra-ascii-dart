import 'acao.dart';

/// Gerencia histórico de ações (undo/redo)
class GerenciadorAcoes {
  final List<Acao> historico = [];
  int indiceAtual = -1;

  void executar(Acao acao) {
    acao.executar();

    // Remove redo stack
    if (indiceAtual < historico.length - 1) {
      historico.removeRange(indiceAtual + 1, historico.length);
    }

    historico.add(acao);
    indiceAtual = historico.length - 1;
  }

  void desfazer() {
    if (indiceAtual >= 0) {
      historico[indiceAtual].desfazer();
      indiceAtual--;
    }
  }

  void refazer() {
    if (indiceAtual < historico.length - 1) {
      indiceAtual++;
      historico[indiceAtual].executar();
    }
  }

  List<String> obterHistorico() => historico
      .sublist(0, indiceAtual + 1)
      .map((acao) => acao.descricao)
      .toList();
}
