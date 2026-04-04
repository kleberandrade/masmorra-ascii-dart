/// Capítulo 14 - Combate por turnos
/// Boss Final 14.6 - Poções dinâmicas com integração ao sistema de combate
///
/// Sistema de combate completo com diferentes tipos de poções,
/// itens que herdam de uma classe base e integração com inventário.

import 'dart:io';
import 'dart:math';

// ══════════════════════════════════════
// SISTEMA DE ITENS E POÇÕES
// ══════════════════════════════════════

abstract class Item {
  final String id;
  final String nome;
  final String descricao;

  Item({
    required this.id,
    required this.nome,
    required this.descricao,
  });

  String descrever() => '$nome - $descricao';

  @override
  String toString() => nome;
}

class ItemComum extends Item {
  ItemComum({
    required super.id,
    required super.nome,
    required super.descricao,
  });
}

abstract class Pocao extends Item {
  final int curaHP;

  Pocao({
    required super.id,
    required super.nome,
    required super.descricao,
    required this.curaHP,
  });

  void usar(Jogador jogador) {
    final vidaAnterior = jogador.hp;
    jogador.curar(curaHP);
    final curaReal = jogador.hp - vidaAnterior;
    print('💊 ${jogador.nome} bebe ${nome} e recupera $curaReal HP!');
  }

  @override
  String descrever() => '$nome (cura $curaHP HP) - $descricao';
}

class PocaoPequena extends Pocao {
  PocaoPequena()
      : super(
          id: 'pocao-pequena',
          nome: 'Poção Pequena',
          descricao: 'Cura levemente os ferimentos.',
          curaHP: 10,
        );
}

class PocaoMedia extends Pocao {
  PocaoMedia()
      : super(
          id: 'pocao-media',
          nome: 'Poção Média',
          descricao: 'Cura moderadamente os ferimentos.',
          curaHP: 25,
        );
}

class PocaoGrande extends Pocao {
  PocaoGrande()
      : super(
          id: 'pocao-grande',
          nome: 'Poção Grande',
          descricao: 'Cura significativamente os ferimentos.',
          curaHP: 50,
        );
}

// ══════════════════════════════════════
// JOGADOR
// ══════════════════════════════════════

class Jogador {
  String nome;
  int hp;
  int maxHp;
  int ataque;
  List<Item> inventario = [];

  Jogador({
    required this.nome,
    this.hp = 100,
    this.maxHp = 100,
    this.ataque = 8,
  });

  void sofrerDano(int dano) {
    hp -= dano;
    if (hp < 0) hp = 0;
  }

  void curar(int quantidade) {
    hp += quantidade;
    if (hp > maxHp) hp = maxHp;
  }

  bool get estaVivo => hp > 0;

  String construirBarra() {
    const totalBlocos = 15;
    final blocos = ((hp / maxHp) * totalBlocos).toInt();
    return '${'█' * blocos}${'░' * (totalBlocos - blocos)} $hp/$maxHp';
  }

  void mostrarInventario() {
    print('\n📦 INVENTÁRIO:');
    if (inventario.isEmpty) {
      print('   Vazio');
    } else {
      for (var i = 0; i < inventario.length; i++) {
        final item = inventario[i];
        final desc = item is Pocao ? ' (cura ${item.curaHP} HP)' : '';
        print('   ${i + 1}. ${item.nome}$desc');
      }
    }
    print('');
  }

  @override
  String toString() => 'Jogador($nome, HP: ${construirBarra()}, Atq: $ataque)';
}

// ══════════════════════════════════════
// INIMIGO
// ══════════════════════════════════════

abstract class Inimigo {
  final String nome;
  final String simbolo;
  int hp;
  final int maxHp;
  final int ataque;

  Inimigo({
    required this.nome,
    required this.simbolo,
    required this.hp,
    required this.maxHp,
    required this.ataque,
  });

  void sofrerDano(int dano) {
    hp -= dano;
    if (hp < 0) hp = 0;
  }

  bool get estaVivo => hp > 0;

  int calcularDano() {
    final variacao = (ataque * 0.15).toInt();
    return ataque - variacao + Random().nextInt(variacao * 2);
  }

  String construirBarra() {
    const totalBlocos = 15;
    final blocos = ((hp / maxHp) * totalBlocos).toInt();
    return '${'█' * blocos}${'░' * (totalBlocos - blocos)} $hp/$maxHp';
  }

  void executarHabilidadeEspecial() {
    print('🔮 ${nome} usa uma habilidade especial!');
  }

  @override
  String toString() => '$nome [$simbolo] - HP: ${construirBarra()}';
}

class Zumbi extends Inimigo {
  Zumbi()
      : super(
          nome: 'Zumbi Pilhador',
          simbolo: 'Z',
          hp: 30,
          maxHp: 30,
          ataque: 6,
        );
}

class Esqueleto extends Inimigo {
  Esqueleto()
      : super(
          nome: 'Esqueleto Antigo',
          simbolo: 'E',
          hp: 25,
          maxHp: 25,
          ataque: 7,
        );
}

class Lobo extends Inimigo {
  Lobo()
      : super(
          nome: 'Lobo Selvagem',
          simbolo: 'L',
          hp: 20,
          maxHp: 20,
          ataque: 5,
        );
}

// ══════════════════════════════════════
// SISTEMA DE COMBATE
// ══════════════════════════════════════

class Combate {
  final Jogador jogador;
  final Inimigo inimigo;
  final List<String> log = [];
  final Random random = Random();

  int turno = 0;
  bool defesaAtiva = false;

  Combate({required this.jogador, required this.inimigo});

  void _registrar(String mensagem) {
    log.add(mensagem);
    print(mensagem);
  }

  void mostrarStatus() {
    print('\n⚔️  COMBATE ⚔️');
    print('${jogador.nome.padRight(20)} vs ${inimigo.nome}');
    print('${jogador.construirBarra().padRight(40)} ${inimigo.construirBarra()}');
    print('');
  }

  void atacar() {
    final variacao = (jogador.ataque * 0.2).toInt();
    final dano = jogador.ataque - variacao + random.nextInt(variacao * 2);

    _registrar('⚔️  ${jogador.nome} ataca! Dano: $dano');
    inimigo.sofrerDano(dano);

    if (!inimigo.estaVivo) {
      _registrar('💀 ${inimigo.nome} foi derrotado!');
    }

    defesaAtiva = false;
  }

  void defender() {
    _registrar('🛡️  ${jogador.nome} assume posição defensiva!');
    defesaAtiva = true;
  }

  bool fugir() {
    if (random.nextDouble() < 0.4) {
      _registrar('✈️  ${jogador.nome} conseguiu fugir!');
      return true;
    } else {
      _registrar('❌ ${jogador.nome} não conseguiu escapar!');
      return false;
    }
  }

  void usarItem(int indice) {
    if (indice < 0 || indice >= jogador.inventario.length) {
      _registrar('❌ Item não encontrado!');
      return;
    }

    final item = jogador.inventario[indice];

    if (item is Pocao) {
      item.usar(jogador);
      jogador.inventario.removeAt(indice);
      _registrar('Item consumido! HP agora: ${jogador.hp}/${jogador.maxHp}');
    } else {
      _registrar('❌ Você não pode usar isso em combate!');
    }
  }

  void turnoInimigo() {
    if (!inimigo.estaVivo) return;

    if (inimigo.hp < inimigo.maxHp / 2 && random.nextDouble() < 0.2) {
      inimigo.executarHabilidadeEspecial();
      return;
    }

    final dano = inimigo.calcularDano();
    int danoFinal = dano;

    if (defesaAtiva) {
      danoFinal = (dano * 0.5).toInt();
      _registrar('🛡️  Defesa reduz o ataque para $danoFinal!');
    }

    _registrar('⚔️  ${inimigo.nome} contra-ataca! Dano: $danoFinal');
    jogador.sofrerDano(danoFinal);

    if (!jogador.estaVivo) {
      _registrar('💀 ${jogador.nome} foi derrotado...');
    }

    defesaAtiva = false;
  }

  void executar() {
    print('\n═══════════════════════════════════');
    print('Um ${inimigo.nome} [$simbolo] está aqui!');
    print('═══════════════════════════════════');

    while (jogador.estaVivo && inimigo.estaVivo) {
      turno++;
      mostrarStatus();

      print('Opções:');
      print('1 - Atacar');
      print('2 - Defender');
      print('3 - Fugir');
      print('4 - Usar item');
      print('');

      stdout.write('Sua escolha (1-4): ');
      var escolha = stdin.readLineSync() ?? '1';

      switch (escolha.trim()) {
        case '1':
          atacar();
          break;
        case '2':
          defender();
          break;
        case '3':
          if (fugir()) {
            return;
          }
          break;
        case '4':
          jogador.mostrarInventario();
          stdout.write('Qual item usar? (0-${jogador.inventario.length - 1}): ');
          final indiceStr = stdin.readLineSync() ?? '0';
          usarItem(int.tryParse(indiceStr) ?? 0);
          break;
        default:
          _registrar('❌ Ação desconhecida!');
          continue;
      }

      if (inimigo.estaVivo) {
        turnoInimigo();
      }
    }

    if (jogador.estaVivo) {
      _registrar('\n🎉 [VITÓRIA] Você venceu o combate!');
      _registrar('Ganhou 50 XP e 100 ouro!');
    } else {
      _registrar('\n💀 [DERROTA] Você caiu em combate...');
    }
  }

  void mostrarLog() {
    print('\n═══════════════════════════════════');
    print('LOG DE COMBATE');
    print('═══════════════════════════════════');
    for (final msg in log) {
      print(msg);
    }
    print('');
  }

  String get simbolo => inimigo.simbolo;
}

// ══════════════════════════════════════
// DEMONSTRAÇÃO
// ══════════════════════════════════════

void main() {
  print('');
  print('╔════════════════════════════════════╗');
  print('║   MASMORRA ASCII - Combate v2.0    ║');
  print('║  com Poções Dinâmicas e Itens      ║');
  print('╚════════════════════════════════════╝');
  print('');

  final jogador = Jogador(
    nome: 'Aldric',
    maxHp: 100,
    hp: 100,
    ataque: 8,
  );

  // Adiciona poções ao inventário
  jogador.inventario.add(PocaoPequena());
  jogador.inventario.add(PocaoMedia());
  jogador.inventario.add(PocaoGrande());
  jogador.inventario.add(ItemComum(
    id: 'moeda',
    nome: 'Moeda de Ouro',
    descricao: 'Valor: 10 ouro',
  ));

  print('Bem-vindo, ${jogador.nome}!');
  print('');
  jogador.mostrarInventario();

  print('Você encontra um Zumbi!');
  print('');

  final inimigo = Zumbi();
  final combate = Combate(jogador: jogador, inimigo: inimigo);
  combate.executar();

  combate.mostrarLog();

  print('\n═══════════════════════════════════');
  print('Inventário após combate:');
  jogador.mostrarInventario();

  print('Status final:');
  print(jogador.toString());
}
