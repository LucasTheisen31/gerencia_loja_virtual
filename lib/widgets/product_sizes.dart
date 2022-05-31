import 'package:flutter/material.dart';
import 'add_size_dialog.dart';

//List pq é uma lista de tamanhos(Strings)
class ProductSizes extends FormField<List> {
  /************** CONSTRUTOR **************/
  //super é o construtor da classe ou seja vai construir a tela ja na inicialização
  ProductSizes(
      {required BuildContext context,
      List? initialValue,
      FormFieldSetter<List>? onSaved,
      FormFieldValidator<List>? validator})
      : super(
          //super é o construtor
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          builder: (state) {
            return Column(
              //uma coluna para exibir um GridView com os tamanhos, e uma mensagem de erro abaixo caso ocorra um erro
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  //SizedBox para definir a altura os widgets
                  height: 34,
                  child: GridView(
                    //GridView
                    //numero de itens fixos no eixo cruzado (eixo cruzado é o numero de linhas)
                    padding: EdgeInsets.symmetric(vertical: 4),
                    scrollDirection: Axis.horizontal,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      //(horizontal=eixo principal, vertical=eixo cruzado)
                      //numero de itens que terao no eixo cruzado (somente 1 pq so queremos 1 linha)
                      crossAxisCount: 1,
                      //espaçamento no eixo pricipal (espaçamento na horizontal)
                      mainAxisSpacing: 8,
                      //proporção entre a altura e a largura, 0.5 = a largura vai ser o dobro da altura
                      childAspectRatio: 0.5,
                    ),
                    /*filhos, pega o stado do FormField (state.value = a lista de tamanhos, lembrando que o FormField recebe um initialValue que é a lista inicial de tamanhos)
                    .map((e){}) significa que para cada item desta lista, vou retornar um GestureDetector*/
                    children: state.value!.map((e) {
                      return InkWell(
                        //GestureDetector ou InkWell para poder clicar (InkWell tem animação de click)
                        onLongPress: () {
                          //state.value.remove(e), remove um item da lista de tamanhos
                          state.value!.remove(e);
                          //state.didChange diz que o estado mudou e passa o novo estado (lista com o item ja removido)
                          state.didChange(state.value);
                        },
                        splashColor: Colors.white,
                        child: Container(
                          decoration: BoxDecoration(
                            //cor de fundo
                            color: Colors.grey.shade900.withAlpha(40),
                            //curva da borda
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              //cor da borda
                              color: Color.fromARGB(255, 4, 125, 141),
                              //largura
                              width: 3,
                            ),
                          ),
                          //alinha o conteudo no centro do container
                          alignment: Alignment.center,
                          child: Text(
                            e,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }).toList()
                      ..add(
                        //adiciona mais um widget (depois dos widgets dos tamanhos dos produtos) colocamos um widget para adicionar
                        InkWell(
                          //GestureDetector ou InkWell para poder clicar (InkWell tem animação de click)
                          onTap: () async {
                            //exibe o widget para escrever o tamanho que vai ser adidiconado, se salvar vai retornar o texto digitado e sera armazenado em String size, caso nao seja salvo vai retornar null
                            String? size = await showDialog(
                              context: context,
                              builder: (context) => AddSizeDialog(),
                            );
                            if (size != null) {
                              //state.value.add(size), adiciona um item da lista de tamanhos
                              state.value!.add(size);
                              //state.didChange diz que o estado mudou e passa o novo estado (lista com o item ja adicionado)
                              state.didChange(state.value);
                            }
                          },
                          splashColor: Colors.white,
                          child: Container(
                            decoration: BoxDecoration(
                                //cor de fundo
                                color: Colors.grey.shade900.withAlpha(40),
                                //curva da borda
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  //cor da borda, se o estado tiver algum erro define a cor da borda como vermelha
                                  color: state.hasError
                                      ? Colors.red
                                      : Color.fromARGB(255, 4, 125, 141),
                                  //largura
                                  width: 3,
                                )),
                            //alinha o conteudo no centro do container
                            alignment: Alignment.center,
                            child: Text(
                              '+',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                  ),
                ),
                //se o estado tiver algum erro exibe um texto com a mensagem de erro senao exibe so um container
                state.hasError
                    ? Text(
                        state.errorText.toString(),
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      )
                    : Container(),
              ],
            );
          },
        );
}
