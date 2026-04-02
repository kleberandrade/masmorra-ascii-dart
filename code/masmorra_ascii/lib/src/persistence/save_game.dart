import 'dart:convert';
import 'dart:io';

import '../model/item.dart';
import '../model/player.dart';

/// Cap. 26 — persistência simples em JSON.
///
/// [salasLimpas] — IDs das salas já desbloqueadas (sem inimigos).
Future<void> guardarJogo(Player jogador, String caminho, {Set<String>? salasLimpas}) async {
  final inventario = <Map<String, dynamic>>[];
  for (final it in jogador.inventario) {
    if (it is Weapon) {
      inventario.add({
        'id': it.id,
        'tipo': 'arma',
        'nome': it.nome,
        'dano': it.dano,
        'preco': it.preco,
      });
    } else {
      inventario.add({'id': it.id, 'tipo': 'item', 'nome': it.nome, 'preco': it.preco});
    }
  }
  final mapa = <String, dynamic>{
    'name': jogador.name,
    'hp': jogador.hp,
    'ouro': jogador.ouro,
    'roomId': jogador.roomId,
    'emMasmorra': jogador.emMasmorra,
    'inventario': inventario,
    'armaId': jogador.armaEquipada?.id,
    if (salasLimpas != null && salasLimpas.isNotEmpty)
      'salasLimpas': salasLimpas.toList(),
  };
  final arquivo = File(caminho);
  await arquivo.writeAsString(const JsonEncoder.withIndent('  ').convert(mapa));
}

/// Resultado de [carregarJogo], agrupando jogador e salas limpas.
class SaveData {
  SaveData({required this.jogador, required this.salasLimpas});

  final Player jogador;
  final Set<String> salasLimpas;
}

Future<SaveData?> carregarJogo(String caminho) async {
  final arquivo = File(caminho);
  if (!await arquivo.exists()) {
    return null;
  }
  final m = jsonDecode(await arquivo.readAsString()) as Map<String, dynamic>;
  final p = Player(
    name: m['name'] as String,
    hp: m['hp'] as int,
    ouro: m['ouro'] as int,
    roomId: m['roomId'] as String,
  );
  p.emMasmorra = m['emMasmorra'] as bool? ?? false;
  final inv = m['inventario'] as List<dynamic>? ?? [];
  for (final e in inv) {
    final map = e as Map<String, dynamic>;
    final tipo = map['tipo'] as String?;
    if (tipo == 'arma') {
      p.inventario.add(
        Weapon(
          id: map['id'] as String,
          nome: map['nome'] as String,
          dano: map['dano'] as int,
          preco: map['preco'] as int? ?? 0,
        ),
      );
    } else {
      p.inventario.add(
        Item(
          id: map['id'] as String,
          nome: map['nome'] as String? ?? map['id'] as String,
          preco: map['preco'] as int? ?? 0,
        ),
      );
    }
  }
  final aid = m['armaId'] as String?;
  if (aid != null) {
    p.equiparArmaPorId(aid);
  }
  final limpas = (m['salasLimpas'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toSet() ??
      <String>{};
  return SaveData(jogador: p, salasLimpas: limpas);
}
