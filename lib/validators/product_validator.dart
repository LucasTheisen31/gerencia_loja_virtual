class ProductValidator {
  //metodos para validar os campos do cadastro de um novo produto
  /********** valida a lista das imagens **************/
  String? validateImages(List? images) {
    if (images!.isEmpty || images == null) {
      //se a lsita de imagens for vazia
      return 'Adicione imagens ao produto';
    }
    return null;
  }

  /********** valida o campo titulo **************/
  String? validateTitle(String? text) {
    if (text!.isEmpty || text == null) {
      return 'Informe o titulo do produto';
    }
    return null;
  }

  /********** valida o campo descrição **************/
  String? validateDesciption(String? text) {
    if (text!.isEmpty || text == null) {
      return 'Informe a descrição do produto';
    }
    return null;
  }

  /********** valida o campo preço **************/
  String? validatePrice(String? text) {
    if (text != null) {
      //tenta converter o texto passado em um double
      double? price = double.tryParse(text);
      if (price != null) {
        //se conseguiu converter o texto em um double
        if (!text.contains(".") || text.split(".")[1].length != 2)
          return "Utilize 2 casas decimais";
        //se o texto nao contem '.' ou ttext.split('.')[1] divide o texto no ponto e [1] = pega a parte depois do ponto e length != 2 varifica se tem ais que duas casasa apos o ponto ex: 90.99
      } else {
        return 'Preço invalido';
      }
    }
    return null;
  }
}
