import 'dart:io';
import 'explorador_masmorra.dart';
import 'game_state.dart';

class GerenciadorTransicao {
  void descerParaProximoAndar(
    ExploradorMasmorra explorador,
    GerenciadorEstado estado,
  ) {
    // 1. Efeito visual: "Você desce as escadas..."
    _mostrarTransicao(explorador.andarNumero, explorador.andarNumero + 1);

    // 2. Atualizar estado
    explorador.andarNumero++;
    estado.transicionar(EstadoJogo.transicaoAndar);

    // 3. Gerar novo andar (com mais dificuldade)
    explorador.gerarAndar();

    // 4. Recuperar um pouco de HP (tensão + recompensa)
    explorador.jogador.hpAtual = (explorador.jogador.hpAtual + 15)
        .clamp(0, explorador.jogador.hpMax);

    // 5. Voltar à exploração
    estado.transicionar(EstadoJogo.exploracao);

    // ignore: avoid_print
    print('Você desceu para o andar ${explorador.andarNumero}');
  }

  void _mostrarTransicao(int andarAtual, int proximoAndar) {
    // ignore: avoid_print
    print('\n...');
    sleep(Duration(milliseconds: 300));
    // ignore: avoid_print
    print('Você desce as escadas...');
    sleep(Duration(milliseconds: 500));
    // ignore: avoid_print
    print('...');
    sleep(Duration(milliseconds: 300));
    // ignore: avoid_print
    print('Andar $proximoAndar alcançado!\n');
  }
}
