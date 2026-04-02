import 'dart:io';
import 'dart:convert';
import '../modelos/jogador.dart';

/// Gerencia salvamento e carregamento de partidas
class GerenciadorSalve {
  static const String dirSalves = 'salves';
  static const int numSlots = 5;

  /// Inicializa o diretório de salves
  static Future<void> inicializar() async {
    final dir = Directory(dirSalves);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  /// Salva o estado do jogador em um slot
  static Future<void> salvar(Jogador jogador, int slot) async {
    if (slot < 0 || slot >= numSlots) {
      throw ArgumentError('Slot inválido: $slot');
    }

    final arquivo = File('$dirSalves/salve_$slot.json');

    try {
      final json = jsonEncode({
        'jogador': jogador.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      await arquivo.writeAsString(json);
      print('Jogo salvo no slot $slot');
    } catch (e) {
      print('Erro ao salvar: $e');
      rethrow;
    }
  }

  /// Carrega o jogador de um slot
  static Future<Jogador?> carregar(int slot) async {
    if (slot < 0 || slot >= numSlots) {
      throw ArgumentError('Slot inválido: $slot');
    }

    final arquivo = File('$dirSalves/salve_$slot.json');

    if (!arquivo.existsSync()) {
      return null;
    }

    try {
      final json = await arquivo.readAsString();
      final map = jsonDecode(json) as Map<String, dynamic>;
      final jogadorMap = map['jogador'] as Map<String, dynamic>;
      return Jogador.fromJson(jogadorMap);
    } catch (e) {
      print('Erro ao carregar: $e');
      return null;
    }
  }

  /// Lista informações dos salves (timestamp ou null se vazio)
  static Future<List<DateTime?>> listarSalves() async {
    final slots = <DateTime?>[];

    for (int i = 0; i < numSlots; i++) {
      final arquivo = File('$dirSalves/salve_$i.json');

      if (arquivo.existsSync()) {
        try {
          final json = await arquivo.readAsString();
          final map = jsonDecode(json) as Map<String, dynamic>;
          final timestamp = DateTime.parse(map['timestamp'] as String);
          slots.add(timestamp);
        } catch (_) {
          slots.add(null);
        }
      } else {
        slots.add(null);
      }
    }

    return slots;
  }

  /// Apaga um salve de um slot
  static Future<void> apagarSalve(int slot) async {
    if (slot < 0 || slot >= numSlots) {
      throw ArgumentError('Slot inválido: $slot');
    }

    final arquivo = File('$dirSalves/salve_$slot.json');
    if (arquivo.existsSync()) {
      await arquivo.delete();
      print('Salve $slot apagado');
    }
  }
}
