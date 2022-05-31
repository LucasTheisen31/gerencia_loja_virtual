import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:gerencia_loja_virtual/validators/login_validator.dart';
import 'package:rxdart/rxdart.dart';
/*lembrando que Bloc -> Sink é a entrada dos dados e Stream é a saida dos dados
  LoginValidator é a classe que fizemos para validar os dados dos campos email e senha*/

/*enumerador para os estados que o login pode ter, IDLE = parado na pagina de login ou digitando os dados dos campos,
  LOADING = carregando os dados, processando os dados enviados,
  SUCCESS = login com sucesso
  FAIL = falha ao realizar login*/
enum LoginState { IDLE, LOADING, SUCCESS, FAILPERMISSION, FAILLOGIN }

class LoginBloc extends BlocBase with LoginValidator {
  //controladores
  final _emailController =
      BehaviorSubject<String>(); //controlador para campo de email
  final _senhaController =
      BehaviorSubject<String>(); //controlador para campo de senha
  final _stateController = BehaviorSubject<
      LoginState>(); //controlador para os estados que o login pode ter

  /*vamos declarar as Stream que sao as saidas dos dados dos controladores (vai simplismente retornar a saida(Stream) dos controladores)
  mas perceba que no final tem um .transform(validateEmail)ou seja é o metodo para validar o email passado, na validaçao ela vai receber a saida da Stream
  e vai validar o dado ou nao, retornando o proprio email(se for valido) ou uma mensagem de erro(se invalido), é a mesma coisa para o campo da senha*/
  Stream<String> get outEmail =>
      _emailController.stream.transform(validateEmail);

  Stream<String> get outSenha =>
      _senhaController.stream.transform(validateSenha);

  Stream<LoginState> get outState => _stateController.stream;

  Stream<bool> get outSubmitdValid =>
      Rx.combineLatest2(outEmail, outSenha, (a, b) => true);

  /*Stream que vai retornar true ou false, combinando a saida das duas Streams outEmail e outSenha, e uma funcao de avaliacao que no caso é
  (a, b) => true ou seja se os dois controladores _emailControler e  _senhaControler tiverem dados nas saidas 'Streams' (outEmail e outSenha) significa que os dados
  dos capos email e senha sao validos pois senao nao iria retornar um dado e sim um erro, entao se sao validos ambos a funcao de avaliaçao vai retornar true
  este outSubmitdValid vai ser usado para ativar ou nao o botao de login, ou seja se retornar true significa que os campos email e senha tem dados validos e o botao
   de login vai estar ativado, caso retornar false, significa que pelo menos um dos campos nao possui dado valido e entao o botao de login vai estar desabilitado*/

  //vamos delclarar os Sik, entrada dos dados dos controladores
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changeSenha => _senhaController.sink.add;

  late StreamSubscription<User?> _streamSubscription;/*para poder fechar a StreamSubscription<User?> retornada no FirebaseAuth.instance.authStateChanges()
  la no final no dispose eu fecho a _streamSubscription.cancel*/

  @override
  void dispose() {
    _emailController.close();
    _senhaController.close();
    _stateController.close();
    _streamSubscription.cancel();
    super.dispose();
  }

  /*CONSTRUTOR
  ao iniciar vai verificar se ja esta logado um ususario*/
  LoginBloc() {
    /* FirebaseAuth.instance.authStateChanges().listen ou seja quando o status da autorização(Logado ou nao) mudar ou seja quando a Stream retornada pelo firebase tiver mudança
     vai chamar a funcao aqui definida*/
    _streamSubscription = FirebaseAuth.instance.authStateChanges().listen((user) async{
      if (user != null) {
        if(await verifyPrivileges(user)){
          /*chama a funcao verifyPrivileges para verifica se o usuario tem privilegios de administrador*/
          _stateController.add(LoginState.SUCCESS);
          if (kDebugMode) {
            print('Logou um Admin');
          }
          FirebaseAuth.instance.signOut();
          /*atualiza o valor do _stateController com SUCCES para nao exibir a tela de login, pois ja tem um usuario logado*/
        }else{
          _stateController.add(LoginState.FAILPERMISSION);
          if (kDebugMode) {
            print('Usuario nao tem privilegios de Admin');
          }
          /*atualiza o valor do _stateController com FAIL para exibir uma mensagem de erro na tela, pois usiarios comums nao podem logar neste app*/
          FirebaseAuth.instance.signOut().then((value){
            if (kDebugMode) {
              print('Deslogou');
            }
          });
        }
      } else {
        _stateController.add(LoginState.IDLE);
        /*atualiza o valor do _stateController com IDLE para exibir a tela de login*/
      }
    });
  }

  /*funcao para realizar o login*/
  void submit() {
    final email = _emailController
        .value; //pega o ultimo valor de saida(Stream) do controlador
    final senha = _senhaController
        .value; //pega o ultimo valor de saida(Stream) do controlador

    /*diz ao _stateController que o login esta no estado de loading*/
    _stateController.add(LoginState.LOADING);
    /*FirebaseAuth.instance.signInWithEmailAndPassword retorna o usuario logado ou um erro
    caso retorne erro atualiza _stateController dizendo que o estado do login é FAIL
    */
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: senha)
        .catchError((e) {
      _stateController.add(LoginState.FAILLOGIN);
    });
  }

  /*funcao para verificar os privilegios do usuario, se é administrador*/
  Future<bool> verifyPrivileges(User user) async{
    /*tenta pegar o documento referente ao usuario logado na coleção de admins
    ou seja se o usuario que esta logado for um admin ele vai ter um documento na coleçao admins com seu uid
    mas caso ele nao seja um admin ele nao vai ter um documento com seu uid na colecao admins*/
    return await FirebaseFirestore.instance.collection('admins').doc(user.uid).get().then((value){
      if(value.data() != null){
        return true;
        /*tem um documento com seu uid na colecao admins entao é um usuario administrador*/
      }else{
        return false;
        /*nao tem um documento com seu uid na colecao admins*/
      }
    }).catchError((error){
      return false;
      /*usuario nao tem nem acesso a colecao de admins portanto nao é um administrador*/
    });
  }
}
