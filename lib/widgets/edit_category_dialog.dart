import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerencia_loja_virtual/blocs/category_bloc.dart';
import 'package:gerencia_loja_virtual/widgets/image_source_sheet.dart';

class EditCategoryDialog extends StatefulWidget {
  EditCategoryDialog({Key? key, this.category}) : super(key: key);

  final DocumentSnapshot? category;

  @override
  State<EditCategoryDialog> createState() => _EditCategoryDialogState(category);
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  //******* CONSTRUTOOR ********
  _EditCategoryDialogState(this.category);

  //variavel para dar acesso a categoria, caso esteja sendo editado uma categoria ela vai ser passada mas caso esteja sendo criada uma nova categoria entao ela sera null
  final DocumentSnapshot? category;
  late CategoryBloc _categoryBloc;
  late TextEditingController _textEditingController;

  //******** METODO CHAMADO QUANDO INICIA O WIDGET *********
  @override
  void initState() {
    //inicia o CategoryBloc(category) passando a categoria, e caso a categoria nao seja null ele retorna os dados da categoria nas Streams e ativa o botao de excluir, caso contrarios desativa o botao de excluir
    _categoryBloc = CategoryBloc(category);
    _textEditingController = TextEditingController(
        text: category != null ? category!['titulo'] : '');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      //card pra ter uma borda bonita com uma sombrinha
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //no lugar do ListTile poderia ser uma Row, mas o ListTile ja contem o leading, trailing, title que facilitam
            ListTile(
              //leading sera um InkWell para podermos tocar e alterar a imagen da categoria
              leading: InkWell(
                onTap: () {
                  //ao clicar na imagem da camera abre as opçoes para tirar uma foto com a camera ou importar uma imagem da galeria
                  showModalBottomSheet(
                    context: context,
                    /*chama o widget ImageSourceSheet que vai exibir o BottonSheet e que
                     tem a funcao onImageSelected que é a funcao de callback que vai retornar a imagem tirada
                     com a camera ou selecionada da galeria*/
                    builder: (context) => ImageSourceSheet(
                      ///onImageSelected é o callback que retorna a imagen selecionada(camera ou galeria)
                      onImageSelected: (image) {
                        //image é a imagen que foi retornada no callback e agora podemos fazer oq quiser com ela
                        //fecha a showModalBottomSheet
                        Navigator.of(context).pop();
                        /*chama a funcao para setar a imagem escolhida no imageController.add
                        que vai atualizar o StreamBuilder que estiver objervando a Stream outImage
                        que é no Widget leading: InkWell do ListTile */
                        _categoryBloc.setImage(image);
                      },
                    ),
                  );
                },
                child: StreamBuilder(
                  //vai observar a saida dos dados do controlador imageController
                  stream: _categoryBloc.outImage,
                  builder: (context, snapshot) {
                    //se snapshot for != null ou seja se tiver alguma imagem
                    if (snapshot.data != null) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                          maxWidth: 64,
                          maxHeight: 64,
                        ),
                        //se a imagem for do tipo File(arm Localmente) ou String(arm no Firebase)
                        child: snapshot.data is File
                            ? Image.file(
                                snapshot.data as File,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                snapshot.data.toString(),
                                fit: BoxFit.cover,
                              ),
                      );
                    } else {
                      return Icon(Icons.image);
                    }
                  },
                ),
              ),
              //O titulo sera um campo de texto para poder alterar o nome da categoria
              title: StreamBuilder<String>(
                  //vai observar a saida do titleController
                  stream: _categoryBloc.outTitle,
                  builder: (context, snapshot) {
                    return TextField(
                      controller: _textEditingController,
                      onChanged: _categoryBloc.setTitle,
                      decoration: InputDecoration(
                        //como a Strean _categoryBloc.outTitle possui validaçao na saida, se ela nao validar o texto passado ela vai informar um erro e entao exibimos no errorText
                        errorText: snapshot.hasError
                            ? snapshot.error.toString()
                            : null,
                      ),
                    );
                  }),
            ),
            //depois do ListTile vamos colocar uma Row = linha, para adicionar dois botoes, salvar e excluir
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StreamBuilder<bool>(
                    //vai observar _categoryBloc.outDelete
                    stream: _categoryBloc.outDelete,
                    //vai construir o builder de acordo com o retorno do _categoryBloc.outDelete
                    builder: (context, snapshot) {
                      //se o snapshot for null nem exibe o botao
                      if (!snapshot.hasData) return Container();
                      return TextButton(
                        //se snapshot == true ou seja se a categoria esta salva ja e posso excluila
                        onPressed: snapshot.data!
                            ? () {
                                Navigator.of(context).pop();
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Cuidado'),
                                    content: Text(
                                        "Deseja realmente excluir a categoria?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancelar'),
                                        style: TextButton.styleFrom(
                                          primary: Colors.red,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _categoryBloc.delete();
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Confirmar'),
                                        style: TextButton.styleFrom(
                                          primary:
                                              Color.fromARGB(255, 4, 125, 141),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            : null,
                        child: Text('Excluir'),
                        style: TextButton.styleFrom(primary: Colors.red),
                      );
                    }),
                StreamBuilder<bool>(
                    /*vai observar a Stream outSubmitdValid que so vai retornar true quando as Streams (outTitle e outImage)  retornarem true tambem
                  * ou seja, so vai ativar o botao de salvar a categoria, quando a categria tiver uma imagem e um titulo valido*/
                    stream: _categoryBloc.outSubmitdValid,
                    builder: (context, snapshot) {
                      return TextButton(
                        //se _categoryBloc.outSubmitdValid retornar true ativa o botao, senao desativa
                        onPressed: snapshot.hasData
                            ? () async {
                                //chama a funcao para salvar os dados no firebase
                                await _categoryBloc.saveData();
                                Navigator.of(context).pop();
                              }
                            : null,
                        child: Text('Salvar'),
                        style: TextButton.styleFrom(
                          primary: Color.fromARGB(255, 4, 125, 141),
                        ),
                      );
                    }),
              ],
            )
          ],
        ),
      ),
    );
  }
}
