/// Boss Final Capítulo 4: Cadeia de Null Safety
///
/// Objetivo: Criar um mapa representando três salas onde algumas podem ser null.
/// Implementar um getter `salaAtual()` que usa encadeamento ?? para garantir
/// que o jogador está sempre em uma sala válida, caindo para "Praça Central"
/// se tudo mais for null.
///
/// Conceitos abordados:
/// - Tipos nullable (String?)
/// - Operador ?? (null coalescing)
/// - Null safety em Dart 3
/// - Getters e propriedades computadas
/// - Encadeamento seguro com ?.
///
/// Instruções:
/// 1. Execute este arquivo com: dart boss-final-cap04.dart
/// 2. Observe como o getter salaAtual() garante sempre uma sala válida
/// 3. Modifique as salas para null e veja o fallback funcionar
/// 4. Teste o encadeamento com múltiplos níveis de null
///
/// Resultado esperado: Demonstração clara de null safety em ação

void main() {
  print('═══════════════════════════════════════════════════════════');
  print('  Boss Final Capítulo 4: Cadeia de Null Safety');
  print('═══════════════════════════════════════════════════════════');
  print('');

  // Criar um mundo com salas (algumas null)
  var mundo = MundoJogador();

  // Teste 1: Todas as salas existem
  print('TESTE 1: Salas normais');
  print('  Sala Praça definida: ${mundo.salaPraca}');
  print('  Sala Corredor definida: ${mundo.salaCorredo}');
  print('  Sala Tesouraria definida: ${mundo.salaTesouraria}');
  print('  Sala atual: ${mundo.salaAtual}');
  print('');

  // Teste 2: Remover sala (simular null)
  print('TESTE 2: Corredor removido (null)');
  mundo.salaPraca = 'Praça Central';
  mundo.salaCorredo = null;
  mundo.salaTesouraria = 'Sala do Tesouro';
  print('  Sala Praça: ${mundo.salaPraca}');
  print('  Sala Corredor: ${mundo.salaCorredo}');
  print('  Sala Tesouraria: ${mundo.salaTesouraria}');
  print('  Sala atual (fallback em cascata): ${mundo.salaAtual}');
  print('');

  // Teste 3: Apenas praça disponível
  print('TESTE 3: Apenas Praça disponível');
  mundo.salaPraca = 'Praça Central';
  mundo.salaCorredo = null;
  mundo.salaTesouraria = null;
  print('  Sala Praça: ${mundo.salaPraca}');
  print('  Sala Corredor: ${mundo.salaCorredo}');
  print('  Sala Tesouraria: ${mundo.salaTesouraria}');
  print('  Sala atual: ${mundo.salaAtual}');
  print('');

  // Teste 4: Tudo null (último fallback)
  print('TESTE 4: Tudo null (fallback final)');
  mundo.salaPraca = null;
  mundo.salaCorredo = null;
  mundo.salaTesouraria = null;
  print('  Sala Praça: ${mundo.salaPraca}');
  print('  Sala Corredor: ${mundo.salaCorredo}');
  print('  Sala Tesouraria: ${mundo.salaTesouraria}');
  print('  Sala atual (garantido não-null): ${mundo.salaAtual}');
  print('');

  // Teste 5: Encadeamento com múltiplos níveis
  print('TESTE 5: Encadeamento com acesso seguro (?.)');
  var mundo2 = MundoJogoAvancado();
  print('  Descrição da sala (com ?.): ${mundo2.obterDescricaoSala()}');
  print('');

  print('═══════════════════════════════════════════════════════════');
  print('  Demonstração: Null safety garante sempre um valor válido');
  print('═══════════════════════════════════════════════════════════');
}

/// Classe que gerencia as salas do mundo
/// Demonstra o padrão de null coalescing (??)
class MundoJogador {
  // As salas podem ser null (não existem)
  String? salaPraca;
  String? salaCorredo;
  String? salaTesouraria;

  // Construtor com valores iniciais
  MundoJogador() {
    salaPraca = 'Praça Central';
    salaCorredo = 'Corredor Longo';
    salaTesouraria = 'Sala do Tesouro';
  }

  /// Getter que retorna a sala atual
  /// Usa encadeamento ?? para fornecer fallback em cascata
  /// Se salaPraca é null, tenta salaCorredo
  /// Se salaCorredo é null, tenta salaTesouraria
  /// Se tudo for null, retorna 'Praça Central' como último recurso
  String get salaAtual {
    return salaPraca ?? salaCorredo ?? salaTesouraria ?? 'Praça Central';
  }

  /// Método para navegar entre salas
  /// Valida se a sala de destino existe (não é null)
  bool navegarPara(String sala) {
    // Verificar se a sala existe
    if (sala == 'Praça' && salaPraca != null) {
      return true;
    } else if (sala == 'Corredor' && salaCorredo != null) {
      return true;
    } else if (sala == 'Tesouraria' && salaTesouraria != null) {
      return true;
    }

    print('  ⚠️ Sala "$sala" não existe ou foi destruída!');
    return false;
  }
}

/// Versão avançada com encadeamento seguro (?.)
/// e estrutura mais elaborada
class MundoJogoAvancado {
  // Sala pode ser null, e a sala tem uma descrição que também pode ser null
  Sala? _salaAtual;

  MundoJogoAvancado() {
    _salaAtual = Sala(
      nome: 'Praça Central',
      descricao: 'Uma praça iluminada por tochas antigas',
    );
  }

  /// Obtém a descrição da sala atual usando acesso seguro (?.)
  /// Se _salaAtual for null, retorna mensagem padrão
  /// Se descricao for null, retorna nome da sala
  String obterDescricaoSala() {
    return _salaAtual?.descricao ??
        _salaAtual?.nome ??
        'Você está em um lugar desconhecido...';
  }

  /// Simular uma sala que é destruída
  void destruirSalaAtual() {
    _salaAtual = null;
  }

  /// Restaurar a sala padrão
  void restaurarSalaAtual() {
    _salaAtual = Sala(
      nome: 'Praça Central',
      descricao: 'A praça foi restaurada',
    );
  }
}

/// Classe Sala para demonstrar encadeamento com estruturas
class Sala {
  final String nome;
  final String? descricao; // Descrição pode não existir

  Sala({
    required this.nome,
    this.descricao,
  });

  @override
  String toString() => nome;
}

/// Extensão demonstrando null safety em métodos
extension NullSafetyExemplo on String? {
  /// Retorna a string em maiúsculas, ou um padrão se for null
  String emMaiuscula() {
    return this?.toUpperCase() ?? '[DESCONHECIDO]';
  }

  /// Retorna o comprimento da string, ou -1 se for null
  int obterComprimento() {
    return this?.length ?? -1;
  }
}
