/// Boss Final Capítulo 11: Múltiplos Mixins e Resolução de Conflito
///
/// Objetivo: Criar dois mixins `Lutador` e `Mago`, ambos com método atacar()
/// que retorna String. Depois criar classe `Paladim extends Inimigo with
/// Combatente, Lutador, Mago` e demonstrar como Dart resolve o conflito.
/// O último mixin (Mago) ganha.
///
/// Conceitos abordados:
/// - Mixins em Dart
/// - Ordem de resolução de métodos com múltiplos mixins
/// - O último mixin sobrescreve os anteriores
/// - Métodos override em mixins
/// - Hierarquia de métodos (Method Resolution Order - MRO)
///
/// Instruções:
/// 1. Execute este arquivo com: dart boss-final-cap11.dart
/// 2. Observe qual método atacar() é chamado
/// 3. Modifique a ordem dos mixins e veja o resultado mudar
/// 4. Entenda a precedência: última mixin ganha
///
/// Resultado esperado: Demonstração clara de como Dart resolve conflitos

void main() {
  print('═══════════════════════════════════════════════════════════');
  print('  Boss Final Capítulo 11: Múltiplos Mixins');
  print('═══════════════════════════════════════════════════════════');
  print('');

  // Criar um paladim (que tem conflito de métodos)
  var paladim = Paladim('Arturo');

  print('TESTE 1: Ordem de resolução (último mixin ganha)');
  print('  Classe: Paladim extends Inimigo with Combatente, Lutador, Mago');
  print('  Inimigo.atacar() = tapa com báculo');
  print('  Combatente.atacar() = golpe com espada');
  print('  Lutador.atacar() = golpe brutal');
  print('  Mago.atacar() = raio mágico');
  print('');
  print('  Resultado: ${paladim.atacar()}');
  print('  ✓ Mago ganhou (último mixin)');
  print('');

  // Teste com ordem diferente
  print('TESTE 2: Comparar com classe que tem ordem diferente');
  var paladimAlternativo =
      PaladimAlternativo('Lancelot'); // Ordem: Lutador, Mago, Combatente
  print('  Classe: PaladimAlternativo with Lutador, Mago, Combatente');
  print('  Resultado: ${paladimAlternativo.atacar()}');
  print('  ✓ Combatente ganhou (último nesta versão)');
  print('');

  // Teste com só um mixin
  print('TESTE 3: Com um único mixin');
  var guerreiro = Guerreiro('Conan');
  print('  Classe: Guerreiro with Lutador');
  print('  Resultado: ${guerreiro.atacar()}');
  print('');

  // Demonstrar que não há conflito se os nomes forem diferentes
  print('TESTE 4: Evitar conflito com nomes distintos');
  var arqueiro = Arqueiro('Robin');
  print('  Classe: Arqueiro with Lutador, Atirador');
  print('  atacarComEspada(): ${arqueiro.atacarComEspada()}');
  print('  dispararFlecha(): ${arqueiro.dispararFlecha()}');
  print('  ✓ Nenhum conflito quando métodos têm nomes diferentes');
  print('');

  print('═══════════════════════════════════════════════════════════');
  print('  Lição: Cuidado com conflitos; use nomes distintos quando');
  print('  possível. Se houver conflito, o último mixin vence.');
  print('═══════════════════════════════════════════════════════════');
}

/// Classe base: Inimigo
/// Todos os guerreiros são inimigos no dungeon
abstract class Inimigo {
  String nome;

  Inimigo(this.nome);

  String atacar() => 'tapa com báculo';

  void saudar() {
    print('Um $nome aparece!');
  }
}

/// Primeiro mixin: Combatente
/// Especialidade: combate com armas
mixin Combatente {
  String atacar() => 'golpe com espada';

  String aparar() => 'aparar com escudo';
}

/// Segundo mixin: Lutador
/// Especialidade: combate corpo a corpo
mixin Lutador {
  String atacar() => 'golpe brutal';

  String esquivar() => 'rolar para o lado';
}

/// Terceiro mixin: Mago
/// Especialidade: magia
/// Nota: Este é o último mixin, então seu atacar() será chamado
mixin Mago {
  String atacar() => 'raio mágico';

  String lancarFeitico() => 'fogo infernal';

  String escudo() => 'escudo mágico';
}

/// Paladim: Combina todas as especialidades
/// Ordem: Inimigo -> Combatente -> Lutador -> Mago
/// Resultado: Mago.atacar() é chamado (último mixin)
class Paladim extends Inimigo with Combatente, Lutador, Mago {
  Paladim(String nome) : super(nome);

  @override
  void saudar() {
    print('O Paladim $nome aparece, brilhando de magia!');
  }

  // Método que combina funcionalidades de múltiplos mixins
  String ataqueCombinado() {
    return '${atacar()} + ${lancarFeitico()}';
  }
}

/// Paladim alternativo: ordem diferente
/// Ordem: Inimigo -> Lutador -> Mago -> Combatente
/// Resultado: Combatente.atacar() é chamado (último nesta ordem)
class PaladimAlternativo extends Inimigo with Lutador, Mago, Combatente {
  PaladimAlternativo(String nome) : super(nome);
}

/// Guerreiro: Apenas com mixin Lutador
/// Resultado: Lutador.atacar() é chamado
class Guerreiro extends Inimigo with Lutador {
  Guerreiro(String nome) : super(nome);
}

/// Arqueiro: Demonstra evitar conflito com nomes diferentes
mixin Atirador {
  String dispararFlecha() => 'dispara uma flecha flamejante';

  String recuar() => 'recua para recarregar';
}

class Arqueiro extends Inimigo with Lutador, Atirador {
  Arqueiro(String nome) : super(nome);

  // Métodos distintos evitam conflito
  String atacarComEspada() => 'usa ${super.atacar()} com sua espada';

  String dispararFlecha() => 'dispara uma flecha afiada';
}

/// Demonstração: Classe que não usa mixin (apenas herança)
class Sacerdote extends Inimigo {
  Sacerdote(String nome) : super(nome);

  @override
  String atacar() => 'ataque espiritual';

  String curar() => 'cura todos ao redor';
}
