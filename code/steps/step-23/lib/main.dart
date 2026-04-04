import 'dart:io';
import 'jogador.dart';
import 'item.dart';
import 'mercador.dart';
import 'economia.dart';
import 'item_venda.dart';
import 'loja_renderer.dart';

void main() {
  print('╔════════════════════════════════════════╗');
  print('║   CAPÍTULO 23 - A LOJA DO MERCADOR     ║');
  print('╚════════════════════════════════════════╝\n');

  // Criar personagens
  final jogador = Jogador(nome: 'Aventureiro', ouro: 200);
  final economia = Economia();

  // Criar inventário da loja
  final inventarioLoja = [
    ItemVenda(
      item: Item(
        id: 'pocao_vida',
        nome: 'Poção de vida',
        descricao: 'Restaura saúde',
      ),
      precoCompra: 25,
      quantidade: 5,
    ),
    ItemVenda(
      item: Item(
        id: 'espada_aco',
        nome: 'Espada de aço',
        descricao: 'Arma poderosa',
      ),
      precoCompra: 75,
      quantidade: 2,
    ),
  ];

  final mercador = Mercador(
    inventario: inventarioLoja,
    economia: economia,
    nome: 'Mestre Aldwin',
  );

  final renderer = LojaRenderer();

  // Loop de loja
  bool emLoja = true;

  while (emLoja) {
    renderer.renderizar(jogador, mercador);

    stdout.write('\n> ');
    final comando = stdin.readLineSync() ?? 'help';
    final partes = comando.split(' ');
    final acao = partes[0].toLowerCase();

    switch (acao) {
      case 'comprar' || 'c':
        if (partes.length < 2) {
          print('Uso: comprar <número>');
          break;
        }
        final indice = int.tryParse(partes[1]);
        if (indice != null) {
          final mensagem = mercador.comprar(jogador, indice);
          print(mensagem);
        }
        break;

      case 'vender' || 'v':
        if (partes.length < 2) {
          print('Uso: vender <número>');
          break;
        }
        final indice = int.tryParse(partes[1]);
        if (indice != null) {
          final mensagem = mercador.vender(jogador, indice);
          print(mensagem);
        }
        break;

      case 'sair' || 's':
        emLoja = false;
        break;

      case 'status':
        print('Ouro: ${jogador.ouro} | HP: ${jogador.hp}/${jogador.maxHp}');
        break;

      default:
        print('Comando desconhecido. Digite "ajuda".');
    }

    print('');
  }

  print('\nVocê saiu da loja.');
}
