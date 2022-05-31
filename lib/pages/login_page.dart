import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gerencia_loja_virtual/blocs/login_bloc.dart';
import 'package:gerencia_loja_virtual/widgets/alert_dialog_login.dart';
import 'package:gerencia_loja_virtual/widgets/input_field.dart';

import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //instanciando um LoginBloc para poder usar suas funcionalidades, passar as Streams
  final _loginBloc = LoginBloc();

  /*como nao podemos mudar de janela ou mostrar outros widgets dentro do StreamBuilder pois o StreamBuilder ja esta construindo a tela
  temos que usar um listen pois é o correto usnado bloc*/
  @override
  void initState() {
    super.initState();
    /*vai observar o loginBloc.outState que vai traser a saida 'Stream' do controlador _stateController que serve para controlar
     os estados que o login pode ter e quando a stream _loginBloc.outState tiver alteraçoes vai executar as açoes de acordo*/
    _loginBloc.outState.listen((event) {
      switch (event) {
        case LoginState.SUCCESS:
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HomePage(),
          ));
          break;
        case LoginState.FAILPERMISSION:
          showDialog(
            context: context,
            builder: (context) => AlertDialogLogin(
              title: 'Erro',
              content: 'Você não possui os privilegios necessarios',
            ),
          );
          break;
        case LoginState.FAILLOGIN:
          showDialog(
            context: context,
            builder: (context) => AlertDialogLogin(
              title: 'Erro',
              content: 'Usuario ou senha invalida',
            ),
          );
          break;
        case LoginState.LOADING:
        case LoginState.IDLE:
      }
    });
  }

  @override
  void dispose() {
    _loginBloc.dispose(); //para liberar o bloc
    super.dispose();
  }

  /**CODIGO BUILD**/
  @override
  Widget build(BuildContext context) {
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
        backgroundColor: Colors.transparent,
        body: StreamBuilder<LoginState>(
            /*vai observar o loginBloc.outState que vai traser a saida 'Stream' do controlador _stateController que serve para controlar os estados que o login pode ter
            e quando a stream _loginBloc.outState tiver alteraçoes vai construir o builder que no caso é a tela de login,
            ou seja vai construir a tela de login de acordo com o estado do login*/
            stream: _loginBloc.outState,
            initialData: LoginState.LOADING,
            builder: (context, snapshot) {
              if (kDebugMode) {
                print(snapshot.data);
              }
              switch (snapshot.data) {
                case LoginState.LOADING:
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                case LoginState.SUCCESS:
                case LoginState.FAILLOGIN:
                case LoginState.FAILPERMISSION:
                case LoginState.IDLE:
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(), //gambia para a stack centralizar  conteudo
                      SingleChildScrollView(
                        child: Container(
                          margin: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Icon(
                                Icons.store_mall_directory,
                                size: 170,
                                color: Color.fromARGB(255, 4, 125, 141),
                              ),
                              InputField(
                                hint: 'Login',
                                obscure: false,
                                icon: Icons.person_outline,
                                stream: _loginBloc.outEmail,
                                /*recebe a saida dos dados(Stream) do controlador de email criado no LoginBloc
                          ou seja aqui vai chegar um email ou um erro de validação do campo*/
                                onChanged: _loginBloc
                                    .changeEmail, //ao ter modificaçoes manda o texto para a entrada dos dados (Sink.add) no LoginBloc que na Stream(saida) vai validar os dados ou nao
                              ),
                              InputField(
                                hint: 'Senha',
                                obscure: true,
                                icon: Icons.lock_outline,
                                stream: _loginBloc.outSenha,
                                /*recebe a saida dos dados(Stream) do controlador de senha criado no LoginBloc
                          ou seja aqui vai chegar uma senha ou um erro de validação do campo*/
                                onChanged: _loginBloc.changeSenha,
                              ),
                              SizedBox(
                                height: 31,
                              ),
                              SizedBox(
                                height: 50,
                                child: StreamBuilder<Object>(
                                    stream: _loginBloc.outSubmitdValid,
                                    /*vai observar o loginBloc.outSubmitdValid que vai traser de retorno true ou false
                              e quando a stream:  builder quando _loginBloc.outSubmitdValid tiver alteraçoes vai construir o builder
                              que no caso é o botao de login, ou seja vai ativar ou desativar o botao de acordo com o retorno da Stream _loginBloc.outSubmitdValid
                              isso é feito no onPressed: snapshot.hasData ? _loginBloc.submit : null*/
                                    builder: (context, snapshot) {
                                      return ElevatedButton(
                                        onPressed: snapshot.hasData
                                            ? _loginBloc.submit
                                            : null,
                                        child: Text(
                                          'Entrar',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          primary: Color.fromARGB(255, 4, 125, 141),
                                          textStyle: TextStyle(letterSpacing: 1),
                                          onSurface: Color.fromARGB(255, 4, 125, 141).withAlpha(
                                              140), //cor do botao desabilitado
                                        ),
                                      );
                                    }),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                default:
                  return Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Color.fromARGB(255, 4, 125, 141),
                    ),
                  );
              }
            }),
      ),
    );
  }
}
