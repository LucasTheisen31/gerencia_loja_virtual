import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class UserBloc extends BlocBase {
  //controladores
  final _usersController = BehaviorSubject<List>();

  /*vamos declarar as Stream que sao as saidas dos dados dos controladores (vai simplismente retornar a saida(Stream) dos controladores)*/
  Stream<List> get outUsers => _usersController.stream;


  /*Um mapa string e outro mapa, pq uero passar o uid do usuario e ja pegar todos os dados dele
  na string sera o uid e no map seraos dados do usuario referente ao uid*/
  Map<String, Map<String, dynamic>> _users = {};

  //ponto de entrada para acessar um FirebaseFirestore
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  /************************ CONSTRUTOR ********************/
  UserBloc(){
    //chama o metodo na inicialização
    _addUserListner();
  }

  /*************************** Função que vai retornar a busca, adicionar a busca na entrada do _usersController (add) para atualizar a tela ***************************************/
  void onChangedSearch(String search){
    /*se o texto da busca estiver vazio*/
    if (search.trim().isEmpty) {
      //adiciona ao _usersController na 'entrada dos dados' a lista dos dados de todos os usuarios, pois a busca nao esta filtrando ja que esta vazia
       _usersController.add(_users.values.toList());
    }else{
      /*agora se o texto da busca nao for vazio, vai adicionar ao _usersController na 'entrada dos dados' a lista dos dados filtrada
      * a filtragen dos dados é feita na funcao _filter(passando o texto da busca)
      * .trim() remove possiveis espaços digitados*/
      _usersController.add(_filter(search.trim()));
    }
  }

  /*************************** Função que vai fazer a filtragem da busca retornando a lista ja filtrada ***************************************/
  List<Map<String, dynamic>> _filter(String search){
    //copia a lista dos dados dos usuarios para a lista filteredUsers
    List<Map<String, dynamic>> filteredUsers = List.from(_users.values.toList());
    //Remove todos os objetos desta lista que não satisfazem o teste.
    filteredUsers.retainWhere((user) {
      //se a pesquisa estiver contida no nome do usuario, retorna true e mantem o usuario, caso contrario retorna false e deleta o usuario da List<Map<String, dynamic>> filteredUsers
      return user['nome'].toUpperCase().contains(search.toUpperCase());
    });
    //retorna List<Map<String, dynamic>> filteredUsers ja filtrada, contendo somente os usuarios que contem a (String search) no nome
    return filteredUsers;
  }

  /*************************** funcao para atualizar a lista de ususarios ****************************************/
  void _addUserListner() {
    //sempre que tiver alguma alteração nos dados dos usuarios no banco vai chamar o .listem que vai chamar a funcao anonima passando o snaphot
    _firebaseFirestore.collection('usuarios').snapshots().listen((snapshot) {
      /*snaphot.docChanges vai pegar as mudanças dos documentos
      * forEach para cada mudança vai chamar a outra função anonima passando a mudança*/
      snapshot.docChanges.forEach((element) {
        //pega o uid do usuario que teve os dados modificados
        String uid = element.doc.id;
        //switch de acordo com o tipo da mudança que ocorreu nos dados do usuario
        switch (element.type) {
          /*caso um usuario tenha sido adicionado*/
          case DocumentChangeType.added:
            //aemazena os dados do usuario no map _users
            _users[uid] = element.doc.data()!;
            //chama a funcao para observar os pedidos do usuario
            _subscribeToOrders(uid);
            break;
          /*caso um usuario tenha sido modificado*/
          case DocumentChangeType.modified:
            //como o snapshot so vai trazer as mudanças que foram feitas entao vamos atualizar com as novas mudanças
            _users[uid]!.addAll(element.doc.data()!);
            //adicona ao _usersController todos os dados locais dos usuarios (.values.toList() = somente os valores, nao passando o uid do usuario pois so queremos exibir uma grande lista com os dados)
            _usersController.add(_users.values.toList());
            break;
          /*caso um usuario tenha sido removido*/
          case DocumentChangeType.removed:
            //simplesmente removemos o usuario do map _users
            _users.remove(uid);
            //chama a funcao para cancelar o _subscribeToOrders ou seja para parar de observar os pedidos do usuario que foi deletado
            _unsubscribeToOrders(uid);
            //adicona ao _usersController todos os dados locais dos usuarios (.values.toList() = somente os valores, nao passando o uid do usuario pois so queremos exibir uma grande lista com os dados)
            _usersController.add(_users.values.toList());
            break;
        }
      });
    });
  }

  /************* funcao para atualizar os valores gastos de cada usuario em tempo real ou seja objervar os pedidos do usuario .listen fica observando *****************/
  void _subscribeToOrders(String uid) {
    /*pega a coleçao de pedidos do usuario referente ao uid passado e quando tiver alteração(.listen) atualiza o numero de pedidos e o valor total gasto por ele
    armazena esse subscription pois quando apagar um usuario dai podemos cancelar o listner referente a ele, nao vai ficar rodando o listner referente a ele*/
    _users[uid]!['subscription'] = _firebaseFirestore.collection('usuarios').doc(uid)
        .collection('pedidos').snapshots().listen((pedidos) async {
      int numeroDePedidos = pedidos.docs.length; //pega o numero de pedidos
      double totalGasto = 0;
      //for para cada pedido na lista de pedidos do usuario
      for(DocumentSnapshot d in pedidos.docs){
        //vai na coleção de pedidos e pega os dados do pedido
        DocumentSnapshot pedido = await _firebaseFirestore.collection('pedidos').doc(d.id).get();

        /*se o pedido for vazio(por exemplo se o pedido nao existir mais)vai ignorar a linha abaixo e vai para o proximo pedido, proxima iteração do for*/
        if(pedido.data() == null) continue;
        totalGasto += pedido['valorTotal'];
      }

      //cria dois novos campos no mapa local _user para cada usuario com os novos dados criados
      _users[uid]!.addAll({'totalGasto' : totalGasto, 'numPedidos' : numeroDePedidos});

      //adicona ao _usersController todos os dados locais dos usuarios (.values.toList() = somente os valores, nao passando o uid do usuario pois so queremos exibir uma grande lista com os dados)
      _usersController.add(_users.values.toList());
    });
  }

  /*****************funcao para cancelar a subscribe de um usuario caso ele seja deletado ou seja para cancelar o .listen (parar d eobservar os pedidos do usuario deletado)*************************/
  void _unsubscribeToOrders(String uid){
    //cancela a subscription do usuario
    _users[uid]!['subscription'].cancel();
  }

  //*************** funca que retorna um usuario **********************
  Map<String, dynamic>? getUser(String uid){
    return _users[uid];
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _usersController.close();
    super.dispose();
  }
}
