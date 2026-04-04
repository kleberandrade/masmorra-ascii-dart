import '../modelos/item.dart';
import '../modelos/sala.dart';
import 'mundo_texto.dart';

/// Constrói o mundo demo dos primeiros capítulos.
MundoTexto criarMundoVila() {
  final salas = <String, Sala>{
    'praca': Sala(
      id: 'praca',
      descricao:
          'Praça da vila. Há uma fonte seca. À norte vês a taverna; a sul, um portão de pedra.',
      saidas: const {'norte': 'taverna', 'sul': 'portao'},
    ),
    'taverna': Sala(
      id: 'taverna',
      descricao:
          'Cheiro a cerveja e velas fracas. O taverneiro acena com desconfiança.',
      saidas: const {'sul': 'praca'},
      temLoja: true,
    ),
    'portao': Sala(
      id: 'portao',
      descricao:
          'Um portão entreaberto. Além dele, escadas que descem para a masmorra (escreve "descer").',
      saidas: const {'norte': 'praca'},
      inimigoId: 'goblin',
    ),
  };
  return MundoTexto(salas);
}

/// Stock da loja (Cap. 19–20).
List<Arma> stockArmasLoja() => [
      Arma(id: 'espada_curta', nome: 'Espada curta', dano: 3, preco: 15),
      Arma(id: 'machadinha', nome: 'Machadinha', dano: 4, preco: 22),
    ];
