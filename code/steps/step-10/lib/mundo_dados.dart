import 'zumbi.dart';
import 'esqueleto.dart';
import 'lobo.dart';
import 'sala.dart';
import 'mundo_texto.dart';

MundoTexto criarMundoVila() {
  final salas = {
    'praca': Sala(
      id: 'praca',
      nome: 'Praça da Vila',
      descricao: 'O coração da vila. Uma fonte antiga no centro.',
      saidas: {
        'norte': 'taverna',
        'leste': 'mercado',
      },
      inimigoPresente: null,
    ),
    'taverna': Sala(
      id: 'taverna',
      nome: 'Taverna do Galo Bravo',
      descricao: 'Fumo, som de risadas, cheiro a cerveja.',
      saidas: {
        'sul': 'praca',
        'norte': 'floresta',
      },
      inimigoPresente: Zumbi(),
    ),
    'mercado': Sala(
      id: 'mercado',
      nome: 'Mercado da Vila',
      descricao: 'Bancas de comida, armas, e poções.',
      saidas: {
        'oeste': 'praca',
        'norte': 'cripta',
      },
      temLoja: true,
      inimigoPresente: null,
    ),
    'floresta': Sala(
      id: 'floresta',
      nome: 'Floresta Escura',
      descricao: 'Árvores altas. Sons estranhos na escuridão.',
      saidas: {
        'sul': 'taverna',
        'norte': 'caverna',
      },
      inimigoPresente: Lobo(),
    ),
    'cripta': Sala(
      id: 'cripta',
      nome: 'Cripta Antiga',
      descricao: 'Lápides rotas. Silêncio assustador.',
      saidas: {
        'sul': 'mercado',
      },
      inimigoPresente: Esqueleto(),
    ),
    'caverna': Sala(
      id: 'caverna',
      nome: 'Caverna do Dragão',
      descricao: 'Escura demais. Você sente respiração quente.',
      saidas: {
        'sul': 'floresta',
      },
      inimigoPresente: null,
    ),
  };

  return MundoTexto(salas: salas);
}
