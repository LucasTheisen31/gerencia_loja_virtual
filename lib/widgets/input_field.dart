import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  const InputField(
      {Key? key,
      required this.hint,
      required this.obscure,
      required this.icon,
      required this.stream,
      required this.onChanged})
      : super(key: key);

  final String hint;
  final bool obscure;
  final IconData icon;
  final Stream<String> stream;
  /*funcao que vais er executada ao ter alteraçoes no campo InputTextField, esta funcao vai ser passada para esta classe, aqui so usamos*/
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: stream,
      /*vai observar a stream e todos vez que ela tiver modificação vai reconstruir o builder (neste caso vai reconstruir o TextField)
      no caso se a stream retornar uma mensagem de erro vamos exibir esta mensagem no errorText*/
      builder: (context, snapshot) {
        return TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white),
            icon: Icon(
              icon,
              color: Colors.grey.shade800,
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromARGB(255, 4, 125, 141),
              ),
            ),
            contentPadding: EdgeInsets.only(
              left: 5,
              right: 30,
              bottom: 30,
              top: 30,
            ),
            /*se o esnapshot tiver um erro, no casso é a mensagem de erro da validação do campo(senha ou email) vai exibir o errorText no InputTextField*/
            errorText: snapshot.hasError ? snapshot.error.toString() : null,
          ),
          style: TextStyle(
            color: Colors.white,
          ),
          obscureText: obscure,
        );
      },
    );
  }
}
