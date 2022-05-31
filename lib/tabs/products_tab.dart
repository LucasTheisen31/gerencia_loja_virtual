import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/category_tile.dart';

class ProductsTab extends StatefulWidget {
  ProductsTab({Key? key}) : super(key: key);

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> with AutomaticKeepAliveClientMixin {
  //with AutomaticKeepAliveClientMixin é para que a tela fique viva mesmo apos sair dela, la no final tem outro codigo complementar
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    //StreamBuilder por que é para ficar observando e quando tiver alteração é para atualizar a tela
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firebaseFirestore.collection("produtos").snapshots(),
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          //se snapshot nao tiver dados
          return Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        } else {
          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            //O itemBuilder deve sempre retornar um widget não nulo
            itemBuilder: (context, index) {
              return CategoryTile(
                category: snapshot.data.docs[index],
              );
            },
          );
        }
      },
    );
  }

  //AutomaticKeepAliveClientMixin codigoo complementar que diz para mander a tela viva
  @override
  // TODO: implement wantKeepAlive
  //quer manter vivo => true;
  bool get wantKeepAlive => true;
}
