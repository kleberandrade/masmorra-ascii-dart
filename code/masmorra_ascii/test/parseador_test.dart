import 'package:masmorra_ascii/masmorra_ascii.dart';
import 'package:test/test.dart';

void main() {
  test('norte vira CmdIr norte', () {
    final c = analisarLinha('norte');
    expect(c, isA<CmdIr>());
    expect((c as CmdIr).direcao, 'norte');
  });

  test('inventario abreviado', () {
    final c = analisarLinha('inv');
    expect(c, isA<CmdInventario>());
  });
}
