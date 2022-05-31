import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class UserTile extends StatelessWidget {
  UserTile({Key? key, required this.user}) : super(key: key);

  final Map<String, dynamic> user;

  final textStyle = TextStyle(color: Colors.white);

  @override
  Widget build(BuildContext context) {
    if (user.containsKey('totalGasto')){
      /*se no UserBloc funcao _subscribeToOrders ja foi calculado o valor total gasto e adicionado no mapa _users a key 'totalGasto' retorna o ListTile, senao retorna o shimmer que
      * da ao campo o efeito de carregamento*/
      return ListTile(
        //tileColor: Colors.red,
        title: Text(
          user['nome'],
          style: textStyle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          user['email'],
          style: textStyle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          /*trailing é o widget na direita dentro do ListTile*/
          crossAxisAlignment: CrossAxisAlignment.end, //alinha a direita da coluna
          children: [
            Text(
              'Pedidos : ${user['numPedidos']}',
              style: textStyle,
            ),
            Text(
              'Gasto : R\$${user['totalGasto'].toStringAsFixed(2)}',
              style: textStyle,
            ),
          ],
        ),
      );
    }else{
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 200,
              height: 20,
              child: Shimmer.fromColors(
                  child: Container(
                    color: Colors.white.withAlpha(50),
                    margin: EdgeInsets.symmetric(vertical: 4),
                  ),
                  enabled: true,
                  direction: ShimmerDirection.ltr,
                  baseColor: Colors.white,
                  highlightColor: Colors.grey,
              ),
            ),
            SizedBox(
              width: 100,
              height: 20,
              child: Shimmer.fromColors(
                  child: Container(
                    color: Colors.white.withAlpha(50),
                    margin: EdgeInsets.symmetric(vertical: 4),
                  ),
                  enabled: true,
                  baseColor: Colors.white,
                  highlightColor: Colors.grey,
              ),
            )
          ],
        ),
      );
    }
  }
}
