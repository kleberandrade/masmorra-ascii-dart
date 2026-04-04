mixin Descritivel {
  String get descricaoCompleta => 'Uma criatura indescritível.';

  void apresentar() {
    print('Sou: $descricaoCompleta');
  }
}
