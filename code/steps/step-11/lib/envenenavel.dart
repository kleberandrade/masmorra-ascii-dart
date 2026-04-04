import 'combatente.dart';

mixin Envenenavel on Combatente {
  int veneno = 0;

  void envenenar(int quantidade) {
    veneno += quantidade;
    print('Veneno acumulado: $veneno!');
  }

  void aplicarDanoVeneno() {
    if (veneno > 0) {
      sofrerDano(veneno);
      veneno = 0;
    }
  }
}
