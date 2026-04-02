import 'dart:math';
import 'inimigo.dart';

/// Fases do chefão durante o combate
enum FaseChefao {
  normal,        // HP > 66%
  furia,         // 33% < HP <= 66%
  desesperado,   // HP <= 33%
}

/// Boss final com sistema de fases
class Chefao extends Inimigo {
  late int hpMaxOriginal;
  FaseChefao faseAtual = FaseChefao.normal;
  int ataqueBaseOriginal = 0;
  int modificadorDanoFase = 0;
  int turnosNaFase = 0;
  bool usouAtaqueEspecial = false;

  Chefao({
    String nome = 'Rei da Masmorra',
    int hpMax = 150,
    int danoBase = 12,
  }) : super(
    nome: nome,
    hpMax: hpMax,
    ataque: danoBase,
    descricao: 'O senhor ancião da masmorra. Seus olhos brilham com malevolência.',
  ) {
    hpMaxOriginal = hpMax;
    ataqueBaseOriginal = danoBase;
  }

  void atualizarFase() {
    final percentualHp = (hp / hpMax) * 100;

    if (percentualHp > 66) {
      if (faseAtual != FaseChefao.normal) {
        print('├─ O Rei permanece em controle...');
      }
      faseAtual = FaseChefao.normal;
      modificadorDanoFase = 0;
    } else if (percentualHp > 33) {
      if (faseAtual != FaseChefao.furia) {
        print('\n[FÚRIA] O Rei entra em FÚRIA! Seus ataques se tornam devastadores!');
        print('   Dano aumentado em 50%!\n');
      }
      faseAtual = FaseChefao.furia;
      modificadorDanoFase = (ataqueBaseOriginal * 0.5).toInt();
    } else {
      if (faseAtual != FaseChefao.desesperado) {
        print('\n[DESESPERADO] Enfraquecido e DESESPERADO, o Rei tenta um ataque final!');
        print('   Chance de ataque crítico aumenta!\n');
      }
      faseAtual = FaseChefao.desesperado;
      modificadorDanoFase = (ataqueBaseOriginal * 0.75).toInt();
    }

    turnosNaFase++;
  }

  @override
  void executarTurno() {
    atualizarFase();

    print('\n--- Turno do $nome ---');

    if (faseAtual == FaseChefao.desesperado &&
        !usouAtaqueEspecial &&
        Random().nextDouble() < 0.4) {
      _ataqueEspecial();
      usouAtaqueEspecial = true;
    } else {
      final dano = ataqueBaseOriginal + modificadorDanoFase;
      final variacao = (dano * 0.15).toInt();
      final danoFinal =
          dano - variacao + Random().nextInt(variacao * 2);

      print('> $nome ataca com fúria!');

      if (faseAtual == FaseChefao.normal) {
        print('   (Ataque normal: $danoFinal dano)');
      } else if (faseAtual == FaseChefao.furia) {
        print('   (Ataque furioso: $danoFinal dano!)');
      } else {
        print('   (Ataque desesperado: $danoFinal dano!!!)');
      }
    }
  }

  void _ataqueEspecial() {
    print('\n* O Rei invoca um poder ancestral!');
    print('   > RAIO ANCESTRAL!');

    final danoCritico = (ataqueBaseOriginal * 2.5).toInt();
    print('   Dano crítico: $danoCritico!');
  }

  String descreverStatus() {
    final percentualHp = (hp / hpMax) * 100;
    final faseTexto = switch (faseAtual) {
      FaseChefao.normal => '[OK] Normal',
      FaseChefao.furia => '[FÚRIA] Fúria (+50% dano)',
      FaseChefao.desesperado => '[CRITICO] Desesperado (+crítico)',
    };

    return '''
╔════════════════════════════════════════╗
║         REI DA MASMORRA                ║
╠════════════════════════════════════════╣
║ HP: $hp / $hpMax (${percentualHp.toStringAsFixed(0)}%)
║ Fase: $faseTexto
║ Descrição: $descricao
╚════════════════════════════════════════╝
    ''';
  }

  @override
  String descreverAcao() {
    return switch (faseAtual) {
      FaseChefao.normal => '$nome respira profundamente.',
      FaseChefao.furia => '$nome RUGE e chamas envolvem a sala!',
      FaseChefao.desesperado =>
        '$nome invoca poder ancestral! O ar se torna tenso!',
    };
  }
}
