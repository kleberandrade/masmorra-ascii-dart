import '../model/item.dart';
import '../model/player.dart';

/// Caps. 19–20 — compra e venda na taverna.
bool tentarComprar(Player jogador, Weapon arma) {
  if (jogador.ouro < arma.preco) {
    return false;
  }
  jogador.ouro -= arma.preco;
  jogador.inventario.add(arma);
  return true;
}

bool tentarVender(Player jogador, int indice) {
  if (indice < 0 || indice >= jogador.inventario.length) {
    return false;
  }
  final it = jogador.inventario.removeAt(indice);
  if (identical(it, jogador.armaEquipada)) {
    jogador.armaEquipada = null;
  }
  final valor = (it.preco / 2).floor().clamp(1, 999);
  jogador.ouro += valor;
  return true;
}
