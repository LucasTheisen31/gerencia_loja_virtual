import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerencia_loja_virtual/blocs/user_bloc.dart';

class OrderHeader extends StatelessWidget {
  OrderHeader({Key? key, required this.order}) : super(key: key);

  final DocumentSnapshot order;

  /*Variavel para dar acesso ao UserBlock*/
  final _userBloc = BlocProvider.getBloc<UserBloc>();



  @override
  Widget build(BuildContext context) {
    //atalho para pegar os dados do usuario retornados no _userBloc.getUser, para nao digitar toda vez _userBloc.getUser(order['clienteID']);
    final _user = _userBloc.getUser(order['clienteID']);

    return Row(
      children: [
        Expanded(
          /*pra parte do nome e endereço ocuparam o maior espaço prossivel*/
          child: Column(
            /*alinha na esuqerda*/
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _user!['nome'],
                style: TextStyle(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _user['endereco'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Column(
          /*alinha na direita*/
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Produtos R\$${order['valorCompra'].toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Total R\$${order['valorTotal'].toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      ],
    );
  }
}
