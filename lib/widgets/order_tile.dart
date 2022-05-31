import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'order_header.dart';

class OrderTile extends StatelessWidget {
  OrderTile({Key? key, required this.order}) : super(key: key);

  final DocumentSnapshot order;

  //lista dos estados que um pedido pode ter, pois no firebase o statos do pedido é um numero
  final status = [
    '',
    'Em preparação',
    'Em transporte',
    'Aguardando Entrega',
    'Entregue'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      child: Card(
        child: ExpansionTile(
          /*Cria um ListTile de linha única com um ícone de seta de expansão que expande ou recolhe o bloco para revelar ou ocultar os filhos.*/
          //initiallyExpanded so vai abrir expandido se o pedido nao tiver sido entregue ainda
          initiallyExpanded: order['statusDoPedido'] != 4,
          title: Text(
            '#${order.id.substring(
              order.id.length - 8,
              order.id.length,
            )} - ${status[order['statusDoPedido']]}',
            style: TextStyle(
              color: order['statusDoPedido'] != 4 ? Colors.grey.shade800 : Colors.green,
            ),
          ),
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 0,
                bottom: 8,
              ),
              child: Column(
                //stretch para para o espaço máximo disponível, ou seja, match_parentpara seu eixo cruzado, estica o maximo possivel na horizontal no caso da coluna.
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OrderHeader(order: order),
                  Column(
                    //coluna dos produtos do pedido
                    //tamanho minimo possivel na vertical
                    mainAxisSize: MainAxisSize.min,
                    children: order['produtos'].map<Widget>((produto) {
                      //para cada produto da lista de produtos do pedido vai chamar a funcao passando o produto
                      return ListTile(
                        title: Text('${produto['produto']['titulo']} ${produto['tamanho']}', maxLines: 2,overflow: TextOverflow.ellipsis,),
                        subtitle: Text('${produto['categoria']} / ${produto['idProduto']}'),
                        trailing: Text(
                          //trailing wiget na direita no ListTile
                          '${produto['quantidade'].toString()}',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        //espaçamento do conteudo
                        contentPadding:
                            EdgeInsets.zero, //espaçamento do conteudo
                      );
                    }).toList(),
                  ),
                  Row(
                    //maor espaço possivel entre os widgets
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          /*apaga o documento do pedido que esta no usuario
                          * order['clienteID'] pega o id do usuario que esta no pedido esta sendo deletado
                          * vai na lista de usuarios, pega o documento (usuario) que tem o id recuperado acima, ou seja o cliente a qual o pedido esta sendo deletado
                          * collection('pedidos') vai na lista de pedidos deste usuario,.doc(order.id) pega o documento (pedido) que tem o mesmo codigo do pedido que esta sendo deletado
                          * e deleta este documento.*/
                          FirebaseFirestore.instance.collection('usuarios').doc(order['clienteID']).collection('pedidos').doc(order.id).delete();
                          //apaga o pedido da lista de pedidos
                          order.reference.delete();
                        },
                        child: Text('Excluir'),
                        style: TextButton.styleFrom(
                          primary: Colors.red,
                        ),
                      ),
                      TextButton(
                        onPressed: order['statusDoPedido'] > 1 ? (){
                          //diminui o valor do status do pedido
                          order.reference.update({'statusDoPedido' : order['statusDoPedido'] - 1});
                        } : null,
                        child: Text('Regredir'),
                        style: TextButton.styleFrom(
                          primary: Colors.grey.shade800,
                        ),
                      ),
                      TextButton(
                        onPressed: order['statusDoPedido'] < 4 ? (){
                          //aumenta o valor do status do pedido
                          order.reference.update({'statusDoPedido' : order['statusDoPedido'] + 1});
                        } : null,
                        child: Text('Avançar'),
                        style: TextButton.styleFrom(
                          primary: Colors.green,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
