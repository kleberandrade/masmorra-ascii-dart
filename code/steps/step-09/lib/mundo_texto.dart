import 'sala.dart';

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

  void adicionarSala(Sala sala) {
    salas[sala.id] = sala;
  }

  List<String> salasConectadas(String salaId) {
    final sala = obterSala(salaId);
    if (sala == null) {
      return [];
    }
    return sala.saidas.keys.toList();
  }
}

MundoTexto criarMundoVila() {
  final salas = {
    'praca': Sala(
      id: 'praca',
      nome: 'Praça Central',
      descricao:
          'Uma fonte de pedra murmura ao centro. Bancas de comida linha os arredores.',
      saidas: {
        'norte': 'taverna',
        'leste': 'mercado',
        'sul': 'portao',
      },
      itens: ['Tocha', 'Chave Enferrujada'],
    ),
    'taverna': Sala(
      id: 'taverna',
      nome: 'Taverna do Galo Bravo',
      descricao: 'Fumo, som de risadas, cheiro a cerveja. Aventureiros bebem.',
      saidas: {
        'sul': 'praca',
        'norte': 'floresta',
      },
    ),
    'mercado': Sala(
      id: 'mercado',
      nome: 'Mercado da Vila',
      descricao: 'Bancas de comida, armas, e poções. Um lugar de comércio.',
      saidas: {
        'oeste': 'praca',
        'norte': 'cripta',
      },
      temLoja: true,
    ),
    'portao': Sala(
      id: 'portao',
      nome: 'Portão da Vila',
      descricao: 'Uma entrada fortificada. Os campos se estendem além.',
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
    ),
    'cripta': Sala(
      id: 'cripta',
      nome: 'Cripta Antiga',
      descricao: 'Lápides rotas. Silêncio assustador.',
      saidas: {
        'sul': 'mercado',
      },
    ),
    'caverna': Sala(
      id: 'caverna',
      nome: 'Caverna do Dragão',
      descricao: 'Escura demais. Você sente respiração quente ao longe.',
      saidas: {
        'sul': 'floresta',
      },
    ),
  };

  return MundoTexto(salas: salas);
}
