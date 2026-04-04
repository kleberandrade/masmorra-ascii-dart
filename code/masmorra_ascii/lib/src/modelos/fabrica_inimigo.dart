import 'inimigo.dart';

/// Cap. 30 — fábrica simples (registo por id).
Inimigo? criarInimigoPorId(String? id) {
  switch (id) {
    case 'goblin':
      return Goblin();
    case 'skeleton':
    case 'esqueleto':
      return Esqueleto();
    case 'slime':
      return Gosma();
    default:
      return null;
  }
}
