import 'package:flutter/material.dart';

class AddSizeDialog extends StatelessWidget {
  AddSizeDialog({Key? key}) : super(key: key);
  //controlador para o TextField
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.only(left: 8, right: 8, top: 8),
        child: Column(
          //tamanho da coluna no eixo prncipal (vertical) minimo possivel
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    //volta uma janela
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancelar'),
                  style: TextButton.styleFrom(
                    primary: Color.fromARGB(255, 4, 125, 141),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    //volta uma janela passando o valor do campo TextField
                    Navigator.of(context).pop(_controller.text.toUpperCase());
                  },
                  child: Text('Adicionar'),
                  style: TextButton.styleFrom(
                    primary: Color.fromARGB(255, 4, 125, 141),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
