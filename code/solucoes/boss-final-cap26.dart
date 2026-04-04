/// Boss Final Capítulo 26: Troféu de Glória
///
/// Objetivo: Tela de vitória mostrando:
/// - Tempo total em minutos
/// - Ratio vitórias
/// - Andares conquistados
/// - Item mais valioso equipado
/// Com ASCII visual bonito.

import 'dart:async';

void main() {
  print('');
  exibirTrofeuGloria(
    nome: 'Aragorn, Rei de Gondor',
    tempoTotal: 125, // minutos
    inimigosDerrotados: 47,
    totalInimigos: 50,
    andaresConquistados: 10,
    itemMaisValioso: ItemEquipado(nome: 'Espada de Elendil', valor: 5000),
    tempoMinutos: 125,
  );
}

/// Exibe tela de vitória épica
void exibirTrofeuGloria({
  required String nome,
  required int tempoTotal,
  required int inimigosDerrotados,
  required int totalInimigos,
  required int andaresConquistados,
  required ItemEquipado itemMaisValioso,
  required int tempoMinutos,
}) {
  var ratio = (inimigosDerrotados / totalInimigos * 100).toStringAsFixed(1);
  var horas = tempoTotal ~/ 60;
  var minutos = tempoTotal % 60;

  print('╔═══════════════════════════════════════════════════════════╗');
  print('║                                                           ║');
  print('║                    *** VITÓRIA ***                       ║');
  print('║                                                           ║');
  print('║                      ⭐ 👑 ⭐                            ║');
  print('║                   VOCÊ PREVALECEU!                       ║');
  print('║                      ⭐ 👑 ⭐                            ║');
  print('║                                                           ║');
  print('╠═══════════════════════════════════════════════════════════╣');
  print('║                   ESTATÍSTICAS DA VITÓRIA                ║');
  print('╠═══════════════════════════════════════════════════════════╣');
  print('║                                                           ║');
  print('║  Herói: ${ _padDireita(nome, 45)}║');
  print('║                                                           ║');
  print('║  Tempo Total: ${ _padDireita('${horas}h ${minutos}m', 38)}║');
  print('║  Inimigos Derrotados: ${ _padDireita('$inimigosDerrotados / $totalInimigos', 35)}║');
  print('║  Taxa de Vitória: ${ _padDireita('$ratio%', 42)}║');
  print('║  Andares Conquistados: ${ _padDireita('$andaresConquistados', 37)}║');
  print('║                                                           ║');
  print('║  Artefato Mais Valioso: ${ _padDireita('${itemMaisValioso.nome}', 32)}║');
  print('║  Valor Estimado: ${ _padDireita('${itemMaisValioso.valor}g', 40)}║');
  print('║                                                           ║');
  print('╠═══════════════════════════════════════════════════════════╣');
  print('║                                                           ║');
  print('║         Sua saga será lembrada através dos tempos!       ║');
  print('║      Gerações vindouras clamam por sua grandeza.         ║');
  print('║                                                           ║');
  print('║                 VOCÊ FOI VERDADEIRAMENTE                 ║');
  print('║                    LENDÁRIO!                             ║');
  print('║                                                           ║');
  print('╚═══════════════════════════════════════════════════════════╝');
  print('');
}

/// Classe para item equipado
class ItemEquipado {
  final String nome;
  final int valor;

  ItemEquipado({
    required this.nome,
    required this.valor,
  });
}

/// Auxiliar para alinhar texto
String _padDireita(String texto, int tamanho) {
  if (texto.length >= tamanho) {
    return texto.substring(0, tamanho);
  }
  return texto + ' ' * (tamanho - texto.length);
}

/// Variação: Tela de vitória cinematográfica
void exibirCinematografiaCinematografia({
  required String nome,
  required int tempoTotal,
  required int andaresConquistados,
}) {
  print('');
  print('████████████████████████████████████████████████████████████');
  print('█                                                            █');
  print('█                    [CENA FINAL]                          █');
  print('█                                                            █');
  print('█  O herói ${ nome.padRight(42)}█');
  print('█  emerge do abismo. Acima, o primeiro raio de sol         █');
  print('█  em $tempoTotal minutos...                                     █');
  print('█                                                            █');
  print('█  Atrás dele, $andaresConquistados andares conquistados.           █');
  print('█  À frente, o mundo inteiro.                              █');
  print('█                                                            █');
  print('█                   [FIM]                                  █');
  print('█                                                            █');
  print('████████████████████████████████████████████████████████████');
  print('');
}
