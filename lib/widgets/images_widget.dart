import 'package:flutter/material.dart';
import 'image_source_sheet.dart';
/*autovalidateMode: AutovalidateMode.disabled : Nenhuma validação automática ocorrerá.
autovalidateMode: AutovalidateMode.always : Usado para validar automaticamente FormField mesmo sem interação do usuário.
autovalidateMode: AutovalidateMode.onUserInteraction : Usado para validar automaticamente FormField somente após cada interação do usuário.*/

class ImagesWidget extends FormField<List> {
  ///***************** Construtor da classe ***************
  ImagesWidget({
    required BuildContext context,
    FormFieldSetter<List>? onSaved,
    FormFieldValidator<List>? validator,
    List? initialValue,
    AutovalidateMode? autovalidateMode,
  }) : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue != null ? initialValue : [],
            autovalidateMode: AutovalidateMode.disabled,
            builder: (state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                //coluna para retornar as imagens e uma menssagem de erro em baixo
                children: [
                  Container(
                    //container para definir a altura das imagens
                    height: 124,
                    padding: EdgeInsets.only(top: 16, bottom: 8),
                    child: ListView(
                      //Axis.horizontal para rolar as imagens na horizontal
                      scrollDirection: Axis.horizontal,
                      //pega o estado do campo, lista(state) de imagens e da um Map chamando a função
                      children: state.value!.map<Widget>((image) {
                        //agora para desenhar cada uma das imagen, para cada item(value) da lista (state) vai retornar um widget
                        return Container(
                          height: 100,
                          width: 100,
                          margin: EdgeInsets.only(right: 8),
                          child: GestureDetector(
                              //se a imagem estiver no formato de String, ou seja vem do firebase ou se a imagem foi importada da galeria ou tirada com a camera
                              child: image is String
                                  ? Image.network(
                                      image,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      image,
                                      fit: BoxFit.cover,
                                    ),
                              onLongPress: () {
                                //se segurar apertado remove a imagem da lista(state)
                                state.value!.remove(image);
                                //Atualiza o estado deste campo para o novo valor.
                                state.didChange(state.value);
                              }),
                        );
                      }).toList()
                        ..add(
                          //adiciona apos a lista de imagems(estao na horizontal) adiciona um
                          GestureDetector(
                              child: Container(
                                height: 100,
                                width: 100,
                                color: Colors.grey.shade900,
                                child: Icon(Icons.camera_enhance,
                                    color: Colors.white),
                                //color: Colors.white.withAlpha(50),
                              ),
                              onTap: () {
                                //ao clicar na imagem da camera abre as opçoes para tirar uma foto com a camera ou importar uma imagem da galeria
                                showModalBottomSheet(
                                  context: context,
                                  /*chama o widget ImageSourceSheet que vai exibir o BottonSheet e que
                                  tem a funcao onImageSelected que é a funcao de calback que vai retornar a imagem tirada
                                  com a camera ou selecionada da galeria*/
                                  builder: (context) => ImageSourceSheet(
                                    ///onImageSelected é o callback que retorna a imagen selecionada(camera ou galeria)
                                    onImageSelected: (image) {
                                      //image é a imagen que foi retornada no callback e agora podemos fazer oq quiser com ela
                                      //if(image == null) return;
                                      //adiciona a imagem da lista(state)
                                      state.value?.add(image);
                                      //Atualiza o estado deste campo para o novo valor.
                                      state.didChange(state.value);
                                      //fecha a showModalBottomSheet
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                );
                              }),
                        ),
                    ),
                  ),
                  //se o estado tiver algum erro exibe um texto com a mensagem de erro senao exibe so um container
                  state.hasError
                      ? Text(
                          state.errorText!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        )
                      : Container()
                ],
              );
            });
}
