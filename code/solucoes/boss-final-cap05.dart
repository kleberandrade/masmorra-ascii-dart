/// Boss Final Capítulo 5: Visualizar o Mundo (Mapa de Adjacência)
///
/// Objetivo: Função exibirMapaMundi() que imprime diagrama ASCII
/// mostrando salas conectadas com setas.
///
/// Conceitos abordados:
/// - Estruturas de grafo
/// - Visualização de conexões
/// - Formatação ASCII
/// - Mapas de adjacência

void main() {
  print('═══════════════════════════════════════════════════════════');
  print('  Boss Final Capítulo 5: Mapa de Adjacência');
  print('═══════════════════════════════════════════════════════════');
  print('');

  // Criar mundo
  var mundo = criarMundoExemplo();

  // Exibir mapa
  exibirMapaMundi(mundo);
}

/// Classe para representar uma sala
class Sala {
  final String id;
  final String nome;
  final List<(String direcao, String salaId)> conexoes;

  Sala({
    required this.id,
    required this.nome,
    required this.conexoes,
  });
}

/// Tipo para mundo
typedef Mundo = Map<String, Sala>;

/// Criar exemplo de mundo
Mundo criarMundoExemplo() {
  return {
    'praca': Sala(
      id: 'praca',
      nome: 'Praça Central',
      conexoes: [
        ('norte', 'corredor1'),
        ('sul', 'taverna'),
        ('leste', 'loja'),
      ],
    ),
    'corredor1': Sala(
      id: 'corredor1',
      nome: 'Corredor Comprido',
      conexoes: [
        ('sul', 'praca'),
        ('norte', 'biblioteca'),
      ],
    ),
    'taverna': Sala(
      id: 'taverna',
      nome: 'Taverna do Rei',
      conexoes: [
        ('norte', 'praca'),
      ],
    ),
    'loja': Sala(
      id: 'loja',
      nome: 'Loja de Itens',
      conexoes: [
        ('oeste', 'praca'),
      ],
    ),
    'biblioteca': Sala(
      id: 'biblioteca',
      nome: 'Biblioteca Antiga',
      conexoes: [
        ('sul', 'corredor1'),
        ('leste', 'sala_secreta'),
      ],
    ),
    'sala_secreta': Sala(
      id: 'sala_secreta',
      nome: 'Sala Secreta',
      conexoes: [
        ('oeste', 'biblioteca'),
      ],
    ),
  };
}

/// Exibir mapa do mundo em formato ASCII
void exibirMapaMundi(Mundo mundo) {
  print('MAPA DO MUNDO');
  print('═════════════════════════════════════════════════════════');
  print('');

  // Versão 1: Árvore simples
  _exibirComoArvore(mundo);

  print('');
  print('═════════════════════════════════════════════════════════');
  print('');

  // Versão 2: Grafo com conexões
  _exibirComoGrafo(mundo);
}

/// Exibir mundo como árvore
void _exibirComoArvore(Mundo mundo) {
  print('FORMATO ÁRVORE:');
  print('');

  var visitadas = <String>{};
  _exibirArvoreRecursivo('praca', mundo, visitadas, 0);
}

void _exibirArvoreRecursivo(
  String salaId,
  Mundo mundo,
  Set<String> visitadas,
  int profundidade,
) {
  if (visitadas.contains(salaId)) {
    return;
  }

  visitadas.add(salaId);

  var sala = mundo[salaId];
  if (sala == null) return;

  var indentacao = '  ' * profundidade;
  var prefixo = profundidade == 0 ? '●' : '├─';

  print('$indentacao$prefixo ${sala.nome}');

  for (var (direcao, proximaSalaId) in sala.conexoes) {
    var indentacaoProxima = '  ' * (profundidade + 1);
    print('$indentacaoProxima  [$direcao]→');
    _exibirArvoreRecursivo(proximaSalaId, mundo, visitadas, profundidade + 2);
  }
}

/// Exibir mundo como grafo
void _exibirComoGrafo(Mundo mundo) {
  print('FORMATO GRAFO:');
  print('');

  // Mostrar cada sala e suas conexões
  for (var sala in mundo.values) {
    print('${sala.nome}');

    if (sala.conexoes.isEmpty) {
      print('  (sem conexões)');
    } else {
      for (var (direcao, salaDestino) in sala.conexoes) {
        var salaDestinaNome = mundo[salaDestino]?.nome ?? 'desconhecida';
        print('  ──[$direcao]──> $salaDestinaNome');
      }
    }

    print('');
  }
}

/// Versão alternativa: Mapa em grid visual
void exibirMapaemGrid() {
  print('FORMATO GRID:');
  print('');
  print('┌─────────────────────────────────────────┐');
  print('│                                         │');
  print('│          ┌──────────────┐               │');
  print('│          │  Biblioteca  │               │');
  print('│          │              │               │');
  print('│          └──────┬───────┘               │');
  print('│                 │                       │');
  print('│       ┌─────────┼─────────┐             │');
  print('│       │         │         │             │');
  print('│   ┌───┴────┐    │    ┌────┴─────┐       │');
  print('│   │ Taverna├────┼────┤ Praça    ├──┬─┐ │');
  print('│   └────────┘    │    │ Central  │  │ │ │');
  print('│                 │    └────┬─────┘  │ │ │');
  print('│       ┌─────────┼─────────┘        │ │ │');
  print('│       │         │              ┌───┘ │ │');
  print('│   ┌───┴────┐    │              │   ┌─┘ │');
  print('│   │Corredor├────┼──────────┬───┤   │   │');
  print('│   │ Comprido    │          │   └─┬─┘   │');
  print('│   └────────┘    │          │     │     │');
  print('│                 │          │ ┌───┘     │');
  print('│          ┌──────┴──┐   ┌───┴─┴─┐       │');
  print('│          │ Sala    │   │ Loja  │       │');
  print('│          │ Secreta │   │ Itens │       │');
  print('│          └─────────┘   └───────┘       │');
  print('│                                         │');
  print('└─────────────────────────────────────────┘');
  print('');
}

/// Classe para gerenciar mundo com métodos úteis
class GerenciadorMundo {
  final Mundo mundo;

  GerenciadorMundo(this.mundo);

  /// Obter salas conectadas a uma sala
  List<String> obterSalasConectadas(String salaId) {
    var sala = mundo[salaId];
    if (sala == null) return [];
    return sala.conexoes.map((c) => c.$2).toList();
  }

  /// Obter direção para outra sala
  String? obterDirecao(String salaOrigem, String salaDestino) {
    var sala = mundo[salaOrigem];
    if (sala == null) return null;

    for (var (direcao, destino) in sala.conexoes) {
      if (destino == salaDestino) {
        return direcao;
      }
    }

    return null;
  }

  /// Verificar se duas salas estão conectadas
  bool estaoConectadas(String sala1, String sala2) {
    return obterSalasConectadas(sala1).contains(sala2);
  }

  /// Encontrar caminho entre duas salas (BFS)
  List<String>? encontrarCaminho(String inicio, String fim) {
    var fila = [inicio];
    var visitadas = {inicio};
    var pai = <String, String>{};

    while (fila.isNotEmpty) {
      var atual = fila.removeAt(0);

      if (atual == fim) {
        // Reconstruir caminho
        var caminho = <String>[fim];
        var current = fim;
        while (pai.containsKey(current)) {
          current = pai[current]!;
          caminho.insert(0, current);
        }
        return caminho;
      }

      for (var proxima in obterSalasConectadas(atual)) {
        if (!visitadas.contains(proxima)) {
          visitadas.add(proxima);
          pai[proxima] = atual;
          fila.add(proxima);
        }
      }
    }

    return null;
  }
}
