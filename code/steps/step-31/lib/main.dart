import 'dart:convert';
import 'modelos/jogador.dart';
import 'persistencia/gerenciador_salve.dart';

void main() async {
  print('╔═══════════════════════════════════════════╗');
  print('║  MASMORRA ASCII - Step 30: Persistência  ║');
  print('║  Async, Await e Serialização JSON        ║');
  print('╚═══════════════════════════════════════════╝\n');

  await GerenciadorSalve.inicializar();

  // Criar um jogador
  final jogador = Jogador(
    nome: 'Aragorn',
    hpMax: 50,
    ataque: 10,
    defesa: 2,
  );

  jogador.ganharXp(150);
  jogador.adicionarItem('Espada');
  jogador.adicionarItem('Pocao');

  print('Jogador criado:');
  print('  Nome: ${jogador.nome}');
  print('  HP: ${jogador.hpAtual}/${jogador.hpMax}');
  print('  Nível: ${jogador.nivel}');
  print('  XP: ${jogador.xp}');
  print('  Inventário: ${jogador.inventario.join(", ")}');
  print('');

  // Salvar
  print('Salvando em slot 0...');
  await GerenciadorSalve.salvar(jogador, 0);
  print('✓ Salvo!\n');

  // Listar salves
  print('Listando salves:');
  final salves = await GerenciadorSalve.listarSalves();
  for (int i = 0; i < salves.length; i++) {
    if (salves[i] != null) {
      print('  Slot $i: ${salves[i]}');
    } else {
      print('  Slot $i: [Vazio]');
    }
  }
  print('');

  // Carregar
  print('Carregando do slot 0...');
  final carregado = await GerenciadorSalve.carregar(0);
  if (carregado != null) {
    print('✓ Carregado!');
    print('  Nome: ${carregado.nome}');
    print('  HP: ${carregado.hpAtual}/${carregado.hpMax}');
    print('  Nível: ${carregado.nivel}');
    print('  XP: ${carregado.xp}');
    print('  Inventário: ${carregado.inventario.join(", ")}');
  }
  print('');

  // Mostrar JSON
  print('JSON salvo:');
  final json = jsonEncode({
    'jogador': jogador.toJson(),
    'timestamp': DateTime.now().toIso8601String(),
  });
  print(json);
  print('');

  print('Execute "dart test" para rodar testes de persistência!');
}
