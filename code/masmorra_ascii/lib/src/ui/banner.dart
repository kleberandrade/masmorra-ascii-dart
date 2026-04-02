/// Cap. 6 — [StringBuffer] para juntar linhas sem criar muitas strings temporárias.
String montarBannerTitulo() {
  final b = StringBuffer();
  b.writeln(r"+------------------------------------------+");
  b.writeln(r"|     M A S M O R R A     A S C I I        |");
  b.writeln(r"|   Dart no terminal — um degrau de cada vez |");
  b.writeln(r"+------------------------------------------+");
  return b.toString();
}

String molduraComBuffer(String linha) {
  final b = StringBuffer();
  final traco = "-" * (linha.length + 4);
  b.write("+");
  b.write(traco);
  b.writeln("+");
  b.writeln("|  $linha  |");
  b.write("+");
  b.write(traco);
  b.writeln("+");
  return b.toString();
}
