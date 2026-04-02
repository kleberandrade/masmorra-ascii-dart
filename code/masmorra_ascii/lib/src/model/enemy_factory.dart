import 'enemy.dart';

/// Cap. 30 — fábrica simples (registo por id).
Enemy? criarInimigoPorId(String? id) {
  switch (id) {
    case 'goblin':
      return Goblin();
    case 'skeleton':
    case 'esqueleto':
      return Skeleton();
    case 'slime':
      return Slime();
    default:
      return null;
  }
}
