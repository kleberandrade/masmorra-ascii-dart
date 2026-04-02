import '../model/item.dart';
import '../model/room.dart';
import 'text_world.dart';

/// Constrói o mundo demo dos primeiros capítulos.
TextWorld criarMundoVila() {
  final salas = <String, Room>{
    'praca': Room(
      id: 'praca',
      description:
          'Praça da vila. Há uma fonte seca. À norte vês a taverna; a sul, um portão de pedra.',
      saidas: const {'norte': 'taverna', 'sul': 'portao'},
    ),
    'taverna': Room(
      id: 'taverna',
      description:
          'Cheiro a cerveja e velas fracas. O taverneiro acena com desconfiança.',
      saidas: const {'sul': 'praca'},
      temLoja: true,
    ),
    'portao': Room(
      id: 'portao',
      description:
          'Um portão entreaberto. Além dele, escadas que descem para a masmorra (escreve "descer").',
      saidas: const {'norte': 'praca'},
      inimigoId: 'goblin',
    ),
  };
  return TextWorld(salas);
}

/// Stock da loja (Cap. 19–20).
List<Weapon> stockArmasLoja() => [
      Weapon(id: 'espada_curta', nome: 'Espada curta', dano: 3, preco: 15),
      Weapon(id: 'machadinha', nome: 'Machadinha', dano: 4, preco: 22),
    ];
