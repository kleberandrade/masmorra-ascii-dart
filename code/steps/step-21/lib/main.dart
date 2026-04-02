import 'package:step_21_dungeon_crawl/explorador_masmorra.dart';
import 'package:step_21_dungeon_crawl/entidade.dart';

void main() {
  final jogador = Jogador(
    nome: 'Aventureiro',
    x: 10,
    y: 10,
    hpMax: 100,
    ouro: 0,
  );

  final explorador = ExploradorMasmorra(
    jogador: jogador,
    larguraMapa: 60,
    alturaMapa: 20,
    andarFinal: 3,
  );

  explorador.executar();
}
