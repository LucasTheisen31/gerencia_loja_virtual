import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerencia_loja_virtual/blocs/product_bloc.dart';
import 'package:gerencia_loja_virtual/validators/product_validator.dart';
import 'package:gerencia_loja_virtual/widgets/product_sizes.dart';

import '../widgets/images_widget.dart';

class ProductPage extends StatelessWidget with ProductValidator {
  //with ProductValidator{ para dar acesso aos metodos da classe de validação dos compos que criei
  /************ construtor ja instanciando um ProductBloc passando categoryId: productId, product: product *********************/
  ProductPage({Key? key, required this.productId, this.product})
      : _productBloc = ProductBloc(categoryId: productId, product: product),
        super(key: key);

  //variavel para acessar o ProductBloc
  final ProductBloc _productBloc;
  final String productId;
  final DocumentSnapshot? product;

  //key para o Form
  final _formKey = GlobalKey<FormState>();

  //Key para o Scaffold Messager
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    //atalho para o estilo dos TextFormField
    final _fieldStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
    );
    //funcao atalho para decoração que retorna um InputDecoration para a decoration do TextFormField
    InputDecoration _buildDecoration(String label) {
      return InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade900,
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 4, 125, 141),
            ),
          ));
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 211, 118, 130),
            const Color.fromARGB(255, 253, 181, 168),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          //coloca o title dentro de um StreamBuilder, dependendo da saida do _productBloc.outCreated exibe o texto (criar ou editar)
          title: StreamBuilder<bool>(
            stream: _productBloc.outCreated,
            initialData: false,
            builder: (context, snapshot) {
              return Text(snapshot.data! ? 'Editar Produto' : 'Criar Produto');
            },
          ),
          actions: [
            //coloca o botao de deletar dentro de um StreamBuilder pq ele sera ativado ou nao dependendo da saida do _productBloc.outCreated
            StreamBuilder<bool>(
              stream: _productBloc.outCreated,
              initialData: false,
              builder: (context, snapshot) {
                if (snapshot.data!) {
                  //se for snapshot == true ou seja o produto ja foi criado
                  return StreamBuilder<bool>(
                    stream: _productBloc.outLoading,
                    initialData: false,
                    builder: (context, snapshot) {
                      return IconButton(
                        //se snapshot.data! == true esta salvando um produto entao desativa o botao
                        onPressed: snapshot.data!
                            ? null
                            : () {
                                _productBloc.deleteProduct();
                                //apos excluir o produto volta uma pagina
                                Navigator.of(context).pop();
                              },
                        icon: Icon(Icons.delete_forever_outlined),
                      );
                    },
                  );
                } else {
                  return Container();
                }
              },
            ),
            //coloca o botao de salvar dentro de um StreamBuilder pq ele sera ativado ou nao dependendo da saida do _productBloc.outLoading
            StreamBuilder<bool>(
              //vai observar a saida dos dados do _productBloc.outLoading
              stream: _productBloc.outLoading,
              initialData: false,
              builder: (context, snapshot) {
                return IconButton(
                  //se snapshot.data! == true esta salvando um produto entao desativa o botao
                  onPressed: snapshot.data! ? null : saveProduct,
                  icon: Icon(Icons.save_outlined),
                );
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Form(
              /*form pois queremos validar os campos TextFormField*/
              key: _formKey,
              child: StreamBuilder<Map>(
                /*vai observar o _productBloc.outData que vai traser a saida 'Stream' do controlador _productBloc que vai traser os dados dos produtos*/
                stream: _productBloc.outData,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    //se snapshot nao tiver dados == null
                    return Container();
                  } else {
                    return ListView(
                      //LisView para poder rolar a pagina, pois a pagina vai ter bastante conteudo
                      padding: EdgeInsets.all(16),
                      children: [
                        Text(
                          'Imagens:',
                          style: TextStyle(
                            color: Colors.grey.shade900,
                            fontSize: 12,
                          ),
                        ),
                        /*funcao para exibir as imagems e opçoes para tirar foto ou selecioonar foto da galeria, passa as imagens do produto como valor inicial*/
                        ImagesWidget(
                          context: context,
                          initialValue: product?['imagens'],
                          onSaved: _productBloc.saveImages,
                          validator: validateImages,
                        ),
                        TextFormField(
                          initialValue: snapshot.data?['titulo'],
                          style: _fieldStyle,
                          decoration: _buildDecoration('Titulo'),
                          onSaved: _productBloc.saveTitle,
                          validator: validateTitle,
                        ),
                        TextFormField(
                          initialValue: snapshot.data?['descricao'],
                          style: _fieldStyle,
                          decoration: _buildDecoration('Descrição'),
                          maxLines: 6,
                          onSaved: _productBloc.saveDescription,
                          validator: validateDesciption,
                        ),
                        TextFormField(
                          initialValue:
                              snapshot.data?["preco"]?.toStringAsFixed(2),
                          style: _fieldStyle,
                          decoration: _buildDecoration('Preço'),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          onSaved: _productBloc.savePrice,
                          validator: validatePrice,
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          'Tamanhos:',
                          style: TextStyle(
                            color: Colors.grey.shade900,
                            fontSize: 12,
                          ),
                        ),
                        //classe que vai retornar o widget GridView que exibira as opçoes de tamanhos do produto
                        ProductSizes(
                          context: context,
                          initialValue: snapshot.data!['tamanhos'],
                          validator: (s){
                            if (s!.isEmpty) {
                              return 'Adicione um tamanho';
                            }
                          },
                          onSaved: _productBloc.saveSizes,
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
            StreamBuilder<bool>(
              //vai observar a saida dos dados do _productBloc.outLoading
              stream: _productBloc.outLoading,
              initialData: false,
              builder: (context, snapshot) {
                //IgnorePointer nao deixa clicar
                return IgnorePointer(
                  //_productBloc.outLoading retornar true ou seja se esta salvando um produto, vai bloquear o toque na tela para nao deixar clicar em nada
                  ignoring: !snapshot.data!,
                  /*um container que sobrepoem a tela pq esta em um stack, entao se a Stream _productBloc.outLoading retornar true ou seja se esta sendo salvo um produto
                  nao vai deixar clicar no container e vai colocar uma cor fosca de fundo nele*/
                  child: Container(
                    child: snapshot.data!
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : null,
                    color: snapshot.data! ? Colors.black54 : Colors.transparent,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /**************** funcao para salvar o produto *****************/
  void saveProduct() async {
    //chama os metodos de validaçao de todods os campos TextFormField
    if (_formKey.currentState!.validate()) {
      //se validar todos os campos entao chama o metodo onSaved para cada um dos campos que vai salvar os dados de cada campo no mapa temporario unsavedData
      _formKey.currentState!.save();

      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            'Salvando produto ....',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color.fromARGB(255, 4, 125, 141),
          duration: Duration(minutes: 1),
        ),
      );

      //chama a funcao para salvar os dados no Firebase e espera o retorno (true ou false)
      bool success = await _productBloc.saveProduct();
      //remove a snackBar
      _scaffoldKey.currentState!.removeCurrentSnackBar();
      //exibe a snackbar de acordo de salvou com sucesso ou nao
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Salvo com sucesso' : 'Erro ao salvar',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor:
              success ? Color.fromARGB(255, 4, 125, 141) : Colors.red,
        ),
      );
    }
  }
}
