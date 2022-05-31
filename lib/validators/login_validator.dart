import 'dart:async';

class LoginValidator {

  /*validador email, StreamTransformer<String, String> significa que vai entrar uma string e se for valida vai sair uma string
    por exemplo vai entrar um email e se for valido vai sair este email na Stream*/
  final validateEmail = StreamTransformer<String, String>.fromHandlers(
    handleData: (email, sink) {
      if(email.contains('@')){
        /*Se o email conter @ vai ser enviado para a entrada o Bloc (Sink == entrada dos dados)*/
        sink.add(email);
      }else{
        /*Se o email for invalido enviamos um erro na entrada do Bloc (Sink == entrada dos dados)*/
        sink.addError('Insira um e-mail valido');
      }
    },
  );
  /*validador da senha*/
  final validateSenha = StreamTransformer<String, String>.fromHandlers(
    handleData: (senha, sink) {
      if(senha.length >=  6){
        /*Se a senha tiver ao menos 6 caracteres vai ser enviada para a entrada do Bloc (Sink == entrada dos dados)*/
        sink.add(senha);
      }else{
        /*Se a senha tiver menos de 6 caracteres  enviamos um erro na entrada do Bloc (Sink == entrada dos dados)*/
        sink.addError('Senha invalida, a senha deve ter pelo menos 6 caracteres');
      }
    },
  );
}