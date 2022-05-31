import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gerencia_loja_virtual/blocs/orders_bloc.dart';

import '../widgets/order_tile.dart';

class OrdersTab extends StatelessWidget {
  OrdersTab({Key? key}) : super(key: key);

  /*Variavel para dar acesso ao OrdersBloc*/
  final _OrdersBloc = BlocProvider.getBloc<OrdersBloc>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
      ),
      child: StreamBuilder<List>(
        //vai observar o bloc - saida do bloc stream
        stream: _OrdersBloc.outOrders,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            //se o snapshot nao tiver nenhum dado
            return Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          } else if (snapshot.data!.length == 0) {
            //se o snapshot tiver dados mas nao tiver nenhum pedido de compra ainda
            return Center(
              child: Text(
                'Nenhum pedido encontrado!',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            );
          } else {
            //se o snapshot tiver dados ou seja se a stream 'saida' do _ordersController do OrdersBloc tiver dados, retornar uma lista com os pedidos
            return ListView.builder(
              itemBuilder: (context, index) {
                return OrderTile(
                  order: snapshot.data![index],
                );
              },
              itemCount: snapshot.data!.length,
            );
          }
        },
      ),
    );
  }
}
