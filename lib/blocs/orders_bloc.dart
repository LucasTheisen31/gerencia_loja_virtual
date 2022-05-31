import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

enum SortCriteria { CONCLUIDOSPRIMEIRO, CONCLUIDOSULTIMO }

class OrdersBloc extends BlocBase {
  //controlador para os pedidos
  final _ordersController = BehaviorSubject<List>();

  //vamos declarar as Stream que sao as saidas dos dados dos controladores (vai simplismente retornar a saida(Stream) dos controladores)
  Stream<List> get outOrders => _ordersController.stream;

  //ponto de entrada para acessar um FirebaseFirestore
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  //Lista do tipo DocumentSnapshot ou seja armazena referencias dos documentos dos pedidos la do banco de dados, desta forma é mais facil de excluilos, modificalos etc
  List<DocumentSnapshot> _orders = [];

  //variaavel para armazenar a escolha da ordenação
  SortCriteria? _criteria;

  //************ CONSTRUTOR ************
  OrdersBloc() {
    //chama o metodo na inicialização
    _addOrdersListener();
  }

  /*************************** funcao para atualizar a lista dos pedidos ****************************************/
  void _addOrdersListener() {
    //sempre que tiver alguma alteração nos dados dos pedidos no banco vai chamar o .listem que vai chamar a funcao anonima passando o snaphot
    _firebaseFirestore.collection('pedidos').snapshots().listen((snapshot) {
      //snaphot.docChanges vai pegar as mudanças dos documentos forEach para cada mudança vai chamar a outra função anonima passando a mudança
      snapshot.docChanges.forEach((element) {
        //pega o id do pedido que teve os dados modificados
        String oid = element.doc.id;
        //switch de acordo com o tipo da mudança que ocorreu nos dados do pedido
        switch (element.type) {
          case DocumentChangeType.added:
            //caso um peido tenha sido adicionado
            //adiciona o novo documento do pedido na List<DocumentSnapshot> _orders
            _orders.add(element.doc);
            break;
          case DocumentChangeType.modified:
            //caso um peido tenha sido modificado
            //remove o antigo que esta desatualizado
            _orders.removeWhere((element) => element.id == oid);
            //adiciona o novo documento do pedido na List<DocumentSnapshot> _orders
            _orders.add(element.doc);
            break;
          case DocumentChangeType.removed:
            //caso um peido tenha sido removido
            _orders.removeWhere((element) => element.id == oid);
            break;
        }
      });
      //chama a funcao para ordenar os dados
      _sort();
    });
  }

  /************************ funcao para escolha da ordem de ordenação dos pedidos **************************/
  void setOrderCriteria(SortCriteria criteria) {
    _criteria = criteria;
    _sort();
  }

  /********************** funcao para comparar os pedidos e ordenar pelo estatus do pedido (em preparação, enviado, entregue, etc)*********************************/
  void _sort() {
    switch (_criteria) {
      case SortCriteria.CONCLUIDOSPRIMEIRO:
        _orders.sort(
          (a, b) {
            int sa = a['statusDoPedido']; //paga o status do pedido a
            int sb = b['statusDoPedido']; //paga o status do pedido b

            if(sa < sb){
              //se status pedido a < status pedido b
              return 1;
            }else if(sb < sa){
              return -1;
            }else{
              return 0;
            }
          },
        );
        break;
      case SortCriteria.CONCLUIDOSULTIMO:
        _orders.sort(
              (a, b) {
            int sa = a['statusDoPedido']; //paga o status do pedido a
            int sb = b['statusDoPedido']; //paga o status do pedido b

            if(sa > sb){
              //se status pedido a > status pedido b
              return 1;
            }else if(sa < sb){
              return -1;
            }else{
              return 0;
            }
          },
        );
        break;
    }
    /*adiciona ao controlador _ordersController a lista dos pedidos _orders ordenada de acordo com a escolha
    * automaticamente vai reconstruir a tela com os pedidos ordenados pois o StreamBulder da OrdersTab esta
    * observando a Stream _OrdersBloc.outOrders, ou seja a saida dos dados do ordersController*/
    _ordersController.add(_orders);
  }

  //********************* dispose para quando sair da janela fechar os controladores ****************************
  @override
  void dispose() {
    // TODO: implement dispose
    _ordersController.close();
    super.dispose();
  }
}
