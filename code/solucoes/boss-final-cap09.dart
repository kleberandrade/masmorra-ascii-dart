/// Boss Final Capítulo 9: Padrão Copy-With (Imutabilidade)
///
/// Objetivo: Refatorar Sala para ser imutável com `final` em todos os campos.
/// Implementar método copyWith() que retorna nova Sala com mudanças.
/// Demonstrar a sequência: sala1 → sala2 → sala3.
///
/// Conceitos abordados:
/// - Imutabilidade
/// - Padrão copy-with
/// - Final em campos
/// - Listas imutáveis (const)
/// - Programação funcional

void main() {
  print('═══════════════════════════════════════════════════════════');
  print('  Boss Final Capítulo 9: Padrão Copy-With');
  print('═══════════════════════════════════════════════════════════');
  print('');

  // Sala inicial: Praça Central
  var sala1 = Sala(
    id: 'praca',
    nome: 'Praça Central',
    descricao: 'Uma praça iluminada por tochas',
    itens: ['Moeda de Ouro', 'Chave Antiga'],
    temLoja: false,
  );

  print('TESTE 1: Sala Inicial');
  _exibirSala(sala1);
  print('');

  // Operação 1: Adicionar loja
  var sala2 = sala1.copyWith(temLoja: true);
  print('TESTE 2: Adicionar Loja (copyWith)');
  _exibirSala(sala2);
  print('  Sala1 inalterada? ${sala1.temLoja == false ? '✓ Sim' : '✗ Não'}');
  print('');

  // Operação 2: Adicionar item
  var novaListaItens = [...sala2.itens, 'Espada Lendária'];
  var sala3 = sala2.copyWith(itens: novaListaItens);
  print('TESTE 3: Adicionar Item (copyWith)');
  _exibirSala(sala3);
  print('  Sala2 inalterada? ${sala2.itens.length == 2 ? '✓ Sim' : '✗ Não'}');
  print('');

  // Operação 3: Remover item
  var listaSemMoeda = sala3.itens.where((i) => i != 'Moeda de Ouro').toList();
  var sala4 = sala3.copyWith(itens: listaSemMoeda);
  print('TESTE 4: Remover Item (copyWith)');
  _exibirSala(sala4);
  print('');

  // Histórico de salas
  print('TESTE 5: Histórico de mudanças');
  var historico = [sala1, sala2, sala3, sala4];
  for (var i = 0; i < historico.length; i++) {
    var s = historico[i];
    print('  Sala $i: ${s.nome} | Loja: ${s.temLoja} | Itens: ${s.itens.length}');
  }
  print('');

  print('═══════════════════════════════════════════════════════════');
  print('  Imutabilidade: cada mudança cria nova instância');
  print('═══════════════════════════════════════════════════════════');
}

/// Exibe informações de uma sala
void _exibirSala(Sala sala) {
  print('  Nome: ${sala.nome}');
  print('  Descrição: ${sala.descricao}');
  print('  Itens: ${sala.itens.isEmpty ? '(nenhum)' : sala.itens.join(', ')}');
  print('  Loja: ${sala.temLoja ? 'Sim' : 'Não'}');
}

/// Classe Sala completamente imutável
/// Todos os campos são final
class Sala {
  final String id;
  final String nome;
  final String descricao;
  final List<String> itens;
  final bool temLoja;

  // Construtor com required parameters
  const Sala({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.itens,
    required this.temLoja,
  });

  /// Método copyWith para criar nova Sala com mudanças
  /// Parâmetros opcionais permitem mudar apenas o que for necessário
  Sala copyWith({
    String? id,
    String? nome,
    String? descricao,
    List<String>? itens,
    bool? temLoja,
  }) {
    return Sala(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      itens: itens ?? this.itens,
      temLoja: temLoja ?? this.temLoja,
    );
  }

  /// Adicionar item (retorna nova Sala)
  Sala adicionarItem(String item) {
    return copyWith(itens: [...itens, item]);
  }

  /// Remover item (retorna nova Sala)
  Sala removerItem(String item) {
    return copyWith(itens: itens.where((i) => i != item).toList());
  }

  /// Limpar todos os itens
  Sala limparItens() {
    return copyWith(itens: []);
  }

  @override
  String toString() => 'Sala($nome)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Sala &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nome == other.nome;

  @override
  int get hashCode => id.hashCode ^ nome.hashCode;
}

/// Versão estendida com mais métodos
class SalaAvancada {
  final String id;
  final String nome;
  final String descricao;
  final List<String> itens;
  final bool temLoja;
  final List<String> conexoes; // Salas conectadas
  final int nivel; // Qual andar da masmorra

  const SalaAvancada({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.itens,
    required this.temLoja,
    required this.conexoes,
    required this.nivel,
  });

  /// Método copyWith expandido
  SalaAvancada copyWith({
    String? id,
    String? nome,
    String? descricao,
    List<String>? itens,
    bool? temLoja,
    List<String>? conexoes,
    int? nivel,
  }) {
    return SalaAvancada(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      itens: itens ?? this.itens,
      temLoja: temLoja ?? this.temLoja,
      conexoes: conexoes ?? this.conexoes,
      nivel: nivel ?? this.nivel,
    );
  }

  /// Conectar outra sala
  SalaAvancada conectarSala(String salaId) {
    if (conexoes.contains(salaId)) return this;
    return copyWith(conexoes: [...conexoes, salaId]);
  }

  /// Desconectar sala
  SalaAvancada desconectarSala(String salaId) {
    return copyWith(conexoes: conexoes.where((s) => s != salaId).toList());
  }
}
