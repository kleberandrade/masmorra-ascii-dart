import 'package:masmorra_ascii/masmorra_ascii.dart';
import 'package:test/test.dart';

void main() {
  test('clear preenche linhas com a largura definida', () {
    final s = AsciiScreen(width: 5, height: 2);
    s.clear('*');
    expect(s.toString(), '*****\n*****');
  });

  test('write respeita limites horizontais', () {
    final s = AsciiScreen(width: 4, height: 1);
    s.clear();
    s.write(1, 0, 'abcdef');
    expect(s.toString(), ' abc');
  });

  test('drawBox desenha retângulo mínimo', () {
    final s = AsciiScreen(width: 6, height: 4);
    s.clear(' ');
    s.drawBox(0, 0, 6, 4);
    expect(
      s.toString(),
      '+--+\n'
      '|  |\n'
      '|  |\n'
      '+--+',
    );
  });
}
