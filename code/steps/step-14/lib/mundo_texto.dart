import 'sala.dart';
import 'inimigo.dart';

class MundoTexto {
  final Map<String, Sala> salas;

  MundoTexto({required this.salas});

  Sala? obterSala(String id) => salas[id];

  bool temSaida(String salaId, String direcao) {
    final sala = obterSala(salaId);
    return sala?.temSaida(direcao) ?? false;
  }

  String? irParaDirecao(String salaId, String direcao) {
    final sala = obterSala(salaId);
    return sala?.saidaPara(direcao);
  }
}

MundoTexto criarMundoVila() {
  final salas = {
    'praca': Sala(
      id: 'praca',
      nome: 'Praça Central',
      descricao: 'Uma fonte de pedra murmura. Bancas de comida ao redor.',
      saidas: {
        'norte': 'taverna',
        'leste': 'mercado',
        'sul': 'portao',
      },
      itens: ['Tocha'],
    ),
    'taverna': Sala(
      id: 'taverna',
      nome: 'Taverna do Galo Bravo',
      descricao: 'Fumo, risadas, cerveja. Aventureiros bebem aqui.',
      saidas: {
        'sul': 'praca',
        'norte': 'floresta',
      },
      inimigoPresente: Zumbi(),
    ),
    'mercado': Sala(
      id: 'mercado',
      nome: 'Mercado da Vila',
      descricao: 'Comida, armas, poções. Um lugar de comércio.',
      saidas: {
        'oeste': 'praca',
        'norte': 'cripta',
      },
      temLoja: true,
    ),
    'portao': Sala(
      id: 'portao',
      nome: 'Portão da Vila',
      descricao: 'Entrada fortificada. Os campos se estendem além.',
      saidas: {
        'norte': 'praca',
      },
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
      inimigoPresente: Orc(),
    ),
  };

  return MundoTexto(salas: salas);
}
