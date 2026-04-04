/// Boss Final Capítulo 2: Diálogo com NPC (Velho Sábio)
///
/// Objetivo: Comando "falar" inicia conversa com NPC que faz pergunta
/// e responde diferentemente baseado na escolha.
/// Integrar ao fluxo principal.
///
/// Conceitos abordados:
/// - Entrada do usuário (stdin)
/// - Estruturas condicionais
/// - Funções com retorno
/// - Strings e validação

import 'dart:io' show stdin, stdout;

void main() async {
  print('═══════════════════════════════════════════════════════════');
  print('  Boss Final Capítulo 2: Diálogo com NPC');
  print('═══════════════════════════════════════════════════════════');
  print('');

  // Simular o jogo
  await executarJogo();
}

Future<void> executarJogo() async {
  print('Você entra na Praça Central da masmorra.');
  print('Um velho sábio está sentado no banco.');
  print('');

  // Iniciar diálogo
  print('Digite "falar" para conversar com o Velho Sábio:');
  stdout.write('> ');

  var entrada = stdin.readLineSync() ?? '';

  if (entrada.toLowerCase() == 'falar') {
    await dialogoVelhoSabio();
  } else {
    print('Você não se sente com vontade de conversar agora.');
  }

  print('');
  print('─── Fim do Jogo ───');
}

/// Executa o diálogo com o Velho Sábio
Future<void> dialogoVelhoSabio() async {
  print('');
  print('╔═════════════════════════════════════════════════════════╗');
  print('║       VELHO SÁBIO                                       ║');
  print('╚═════════════════════════════════════════════════════════╝');
  print('');

  print('Velho Sábio: "Bem-vindo, jovem aventureiro...');
  print('             Observe meu rosto, vejo cicatrizes de muitos');
  print('             combates. Diga-me... qual é a sua maior')
  print('             virtude?"');
  print('');

  print('1 - Coragem');
  print('2 - Sabedoria');
  print('3 - Justiça');
  print('');

  stdout.write('Sua escolha (1-3): ');
  var escolha = stdin.readLineSync() ?? '';

  print('');

  switch (escolha) {
    case '1':
      // Coragem
      print('Velho Sábio: "Ah, a coragem! Uma virtude valiosa...');
      print('             Mas lembre-se: a bravura sem sabedoria');
      print('             é apenas imprudência. Os maiores guerreiros');
      print('             conhecem quando recuar."');
      print('');
      print('✨ +1 Nível de Ataque');
      break;

    case '2':
      // Sabedoria
      print('Velho Sábio: "Sabedoria! Você compreende que conhecimento');
      print('             é poder. Muito bem. Com esse entendimento,');
      print('             você verá caminhos que outros ignoram."');
      print('');
      print('✨ +1 Nível de Inteligência');
      print('📚 Você obtém uma Chave Enferrujada secreta!');
      break;

    case '3':
      // Justiça
      print('Velho Sábio: "Justiça... É raro encontrar quem a busque');
      print('             em tempos sombrios. Sua bondade não será');
      print('             esquecida. Os heróis são necessários."');
      print('');
      print('✨ +1 Nível de Carisma');
      break;

    default:
      print('Velho Sábio: "Você não respondeu. Uma escolha também.');
      print('             O silêncio fala volumes."');
  }

  print('');
  print('Velho Sábio: "Vá, jovem. A masmorra espera. Que você');
  print('             prospere em sua jornada."');
  print('');
}

/// Versão alternativa: Sistema de diálogo reutilizável
class NPC {
  final String nome;
  final String descricao;
  final Map<String, String> respostas;

  NPC({
    required this.nome,
    required this.descricao,
    required this.respostas,
  });

  /// Iniciar diálogo com NPC
  void iniciarDialogo() {
    print('');
    print('╔' + '═' * (nome.length + 4) + '╗');
    print('║ $nome ║');
    print('╚' + '═' * (nome.length + 4) + '╝');
    print('');
    print(descricao);
    print('');
  }

  /// Obter resposta baseada em escolha
  String obterResposta(String chave) {
    return respostas[chave] ?? 'Não tenho nada a dizer sobre isso.';
  }
}

/// Exemplo de uso com múltiplos NPCs
class Taverna {
  late NPC velhoSabio;
  late NPC comerciante;

  Taverna() {
    velhoSabio = NPC(
      nome: 'Velho Sábio',
      descricao:
          'Um homem idoso de barba longa observa você com interesse.',
      respostas: {
        'coragem': 'A coragem sem sabedoria é loucura.',
        'sabedoria': 'Você escolheu bem, jovem.',
        'justiça': 'Raro encontrar alguém que a busque.',
      },
    );

    comerciante = NPC(
      nome: 'Comerciante Gananciosos',
      descricao: 'Um homem robusto com um sorriso astucioso.',
      respostas: {
        'preco': 'Tudo tem um preço, amigo.',
        'ouro': 'Ouro! Meu favorito!',
        'desconto': 'Desconto? Nunca ouvi falar!',
      },
    );
  }

  NPC obterNPC(String nome) {
    if (nome.toLowerCase() == 'sabio') {
      return velhoSabio;
    } else if (nome.toLowerCase() == 'comerciante') {
      return comerciante;
    }
    throw ArgumentError('NPC não encontrado: $nome');
  }
}
