import 'dart:async';
import 'dart:io';
import 'dart:math';

import '../combat/combat.dart';
import '../economy/shop.dart';
import '../model/enemy_factory.dart';
import '../model/item.dart';
import '../model/player.dart';
import '../model/room.dart';
import '../parse/commands.dart';
import '../parse/parser.dart';
import '../persistence/save_game.dart';
import '../ui/banner.dart';
import '../world/dungeon_map.dart';
import '../world/text_world.dart';
import '../world/world_data.dart';

/// Caps. 7+ — menu, exploração, loja, masmorra, save/load, log em stream.
class GameSession {
  GameSession({this.sementeMasmorra = 42, this.caminhoSave = 'masmorra_save.json'});

  final int sementeMasmorra;
  final String caminhoSave;

  late Player _jogador;
  late TextWorld _mundo;
  late List<Weapon> _stockLoja;
  final Set<String> _salasLimpas = {};

  final StreamController<String> _eventos = StreamController<String>.broadcast();
  Stream<String> get eventos => _eventos.stream;

  void _log(String m) {
    // ignore: avoid_print
    print(m);
    if (!_eventos.isClosed) {
      _eventos.add(m);
    }
  }

  Weapon? _armaNaLoja(String id) {
    for (final w in _stockLoja) {
      if (w.id == id) {
        return w;
      }
    }
    return null;
  }

  Future<void> run() async {
    // ignore: avoid_print
    print(montarBannerTitulo());
    stdout.write('Como te chamas? ');
    final nome = stdin.readLineSync()?.trim() ?? 'viajante';
    _jogador = Player(name: nome);
    _jogador.inventario.add(
      Weapon(id: 'punhal', nome: 'Punhal enferrujado', dano: 2, preco: 5),
    );
    _jogador.equiparArmaPorId('punhal');
    _mundo = criarMundoVila();
    _stockLoja = stockArmasLoja();
    _log('Olá, ${_jogador.name}. HP ${_jogador.hp} | Ouro ${_jogador.ouro}');

    while (true) {
      _mostrarMenuPrincipal();
      stdout.write('Opção: ');
      final raw = stdin.readLineSync();
      if (raw == null) {
        _log('Fim de entrada. Adeus!');
        break;
      }
      final op = int.tryParse(raw.trim()) ?? -1;
      if (op == 0) {
        _log('Até breve!');
        await _eventos.close();
        return;
      }
      if (op == 1) {
        _loopExploracao();
      } else if (op == 2) {
        _mostrarAjuda();
      } else if (op == 3) {
        await _guardar();
      } else if (op == 4) {
        await _carregar();
      } else {
        _mostrarAviso('Usa 0–4.');
      }
    }
    await _eventos.close();
  }

  void _mostrarMenuPrincipal() {
    // ignore: avoid_print
    print('');
    print('+----------------------------+');
    print('|  MENU PRINCIPAL            |');
    print('+----------------------------+');
    print('|  1 - Explorar (texto/MUD)  |');
    print('|  2 - Ajuda                 |');
    print('|  3 - Guardar jogo          |');
    print('|  4 - Carregar jogo         |');
    print('|  0 - Sair                  |');
    print('+----------------------------+');
  }

  void _mostrarAviso(String msg) {
    final t = msg.length > 26 ? '${msg.substring(0, 23)}...' : msg;
    final a = t.padRight(26);
    print('+----------------------------+');
    print('|  $a|');
    print('+----------------------------+');
  }

  void _mostrarAjuda() {
    _log('Exploração: olhar, n/s/e/o, inventario, equipar <id>, atacar,');
    _log('loja, comprar <id>, vender <n>, descer (no portão), menu.');
    _log('Masmorra: n/s/e/o ou WASD; * é a saída; "menu" interrompe.');
  }

  String _hud() =>
      '[${_jogador.name}] HP ${_jogador.hp} | Ouro ${_jogador.ouro} | Sala ${_jogador.roomId} | Dano ${_jogador.danoAtual}';

  void _loopExploracao() {
    while (true) {
      final sala = _mundo.obterSala(_jogador.roomId);
      print('');
      _log(_hud());
      _log(sala.description);
      if (sala.temLoja) {
        _log('Há comércio aqui. Escreve "loja".');
      }
      if (sala.inimigoId != null && !_salasLimpas.contains(sala.id)) {
        _log('Algo hostil espreita (usa "atacar").');
      }
      stdout.write('> ');
      final raw = stdin.readLineSync();
      if (raw == null) {
        return;
      }
      final cmd = analisarLinha(raw);
      final continuar = _tratarComando(cmd, sala);
      if (!continuar) {
        return;
      }
      if (_jogador.hp <= 0) {
        _log('Você morreu. Reinicie o programa.');
        return;
      }
    }
  }

  /// `false` = voltar ao menu principal.
  bool _tratarComando(GameCommand cmd, Room sala) {
    switch (cmd) {
      case CmdMenu():
        return false;
      case CmdOlhar():
        return true;
      case CmdIr(:final direcao):
        final destino = sala.saidas[direcao];
        if (destino == null) {
          _mostrarAviso('Não há saída por aí.');
        } else {
          _jogador.roomId = destino;
        }
        return true;
      case CmdInventario():
        if (_jogador.inventario.isEmpty) {
          _log('Inventário vazio.');
        } else {
          for (var i = 0; i < _jogador.inventario.length; i++) {
            final it = _jogador.inventario[i];
            final extra = it is Weapon ? ' (dano ${it.dano})' : '';
            _log('  $i) ${it.nome}$extra [${it.id}]');
          }
          if (_jogador.armaEquipada != null) {
            _log('Equipada: ${_jogador.armaEquipada!.nome}');
          }
        }
        return true;
      case CmdEquipar(:final id):
        if (_jogador.equiparArmaPorId(id)) {
          _log('Equipou $id.');
        } else {
          _mostrarAviso('Você não tem essa arma.');
        }
        return true;
      case CmdAtacar():
        _tentarCombateNaSala();
        return true;
      case CmdDescer():
        if (_jogador.roomId == 'portao') {
          _correrMasmorra();
        } else {
          _mostrarAviso('Só há escadas no portão.');
        }
        return true;
      case CmdSubir():
        _mostrarAviso('Já estás na superfície.');
        return true;
      case CmdLojaListar():
        if (!sala.temLoja) {
          _mostrarAviso('Não há loja aqui.');
        } else {
          _log('--- Loja ---');
          for (final w in _stockLoja) {
            _log('${w.id} — ${w.nome} (+${w.dano}) : ${w.preco} ouro');
          }
        }
        return true;
      case CmdComprar(:final id):
        if (!sala.temLoja) {
          _mostrarAviso('Não há loja aqui.');
        } else {
          final arma = _armaNaLoja(id);
          if (arma == null) {
            _mostrarAviso('Item desconhecido.');
          } else if (tentarComprar(_jogador, arma)) {
            _log('Comprou ${arma.nome}.');
          } else {
            _mostrarAviso('Ouro insuficiente.');
          }
        }
        return true;
      case CmdVender(:final slot):
        if (!sala.temLoja) {
          _mostrarAviso('Não há loja aqui.');
        } else if (tentarVender(_jogador, slot)) {
          _log('Vendeu o item $slot.');
        } else {
          _mostrarAviso('Índice inválido.');
        }
        return true;
      case CmdDesconhecido(:final trecho):
        _mostrarAviso('Comando? ($trecho)');
        return true;
    }
  }

  void _tentarCombateNaSala() {
    final s = _mundo.obterSala(_jogador.roomId);
    if (s.inimigoId == null || _salasLimpas.contains(s.id)) {
      _mostrarAviso('Nada para atacar.');
      return;
    }
    final e = criarInimigoPorId(s.inimigoId);
    if (e == null) {
      _mostrarAviso('Inimigo desconhecido.');
      return;
    }
    final venceu = executarCombate(jogador: _jogador, inimigo: e, log: _log);
    if (venceu) {
      _salasLimpas.add(s.id);
    }
  }

  void _correrMasmorra() {
    _jogador.emMasmorra = true;
    final rng = Random(sementeMasmorra);
    final mapa = DungeonMap.gerar(rng);
    _log('--- Masmorra (grade). Semente $sementeMasmorra ---');
    _log('n/s/e/o ou WASD. Célula * = saída. "menu" volta.');
    while (_jogador.hp > 0) {
      print(mapa.paraEcran());
      _log('HP ${_jogador.hp} | Ouro ${_jogador.ouro}');
      if (mapa.naSaida) {
        _log('Saiu da masmorra.');
        _jogador.roomId = 'portao';
        _jogador.emMasmorra = false;
        return;
      }
      stdout.write('masmorra> ');
      final raw = stdin.readLineSync()?.trim().toLowerCase() ?? '';
      if (raw.isEmpty) {
        continue;
      }
      if (raw == 'menu') {
        _jogador.emMasmorra = false;
        return;
      }
      var dx = 0;
      var dy = 0;
      if (raw == 'n' || raw == 'norte' || raw == 'w') {
        dy = -1;
      } else if (raw == 's' || raw == 'sul' || raw == 'x') {
        dy = 1;
      } else if (raw == 'e' || raw == 'este' || raw == 'leste' || raw == 'd') {
        dx = 1;
      } else if (raw == 'o' || raw == 'oeste' || raw == 'a') {
        dx = -1;
      } else {
        _mostrarAviso('Usa n/s/e/o ou WASD.');
        continue;
      }
      final passo = mapa.tentarMover(dx, dy);
      if (!passo.ok) {
        _mostrarAviso('Bloqueado.');
      } else if (passo.ouro > 0) {
        _jogador.ouro += passo.ouro;
        _log('+${passo.ouro} ouro.');
      }
    }
    _jogador.emMasmorra = false;
  }

  Future<void> _guardar() async {
    try {
      await guardarJogo(_jogador, caminhoSave, salasLimpas: _salasLimpas);
      _log('Guardado em $caminhoSave');
    } catch (e) {
      _mostrarAviso('Erro ao guardar: $e');
    }
  }

  Future<void> _carregar() async {
    try {
      final data = await carregarJogo(caminhoSave);
      if (data == null) {
        _mostrarAviso('Sem arquivo de save.');
      } else {
        _jogador = data.jogador;
        _salasLimpas
          ..clear()
          ..addAll(data.salasLimpas);
        _log('Carregado, ${data.jogador.name}.');
      }
    } catch (e) {
      _mostrarAviso('Erro ao carregar: $e');
    }
  }
}
