import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerencia_loja_virtual/pages/product_page.dart';
import 'package:gerencia_loja_virtual/widgets/edit_category_dialog.dart';

class CategoryTile extends StatelessWidget {
  const CategoryTile({Key? key, required this.category}) : super(key: key);

  final DocumentSnapshot category;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 16,
      ),
      child: Card(
        child: ExpansionTile(
          /*Cria um ListTile de linha única com um ícone de seta de expansão que expande ou recolhe o bloco para revelar ou ocultar os filhos.*/
          title: Text(
            category['titulo'],
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
          //coloca o winget leading que é a imagem da categoria dentro de um InkWell para poder tocar e exibir o dialogo com as opçoes de editar a categoria
          leading: InkWell(
            onTap: () {
              showDialog(
                  context: context, builder: (context) => EditCategoryDialog(category: category,));
            },
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 44,
                minHeight: 44,
                maxWidth: 64,
                maxHeight: 64,
              ),
              child: Image.network(
                category['icone'],
                fit: BoxFit.cover,
              ),
            ),
          ),
          children: [
            StreamBuilder<QuerySnapshot>(
              //vai observar category.reference.collection('Items').snapshots(),
              stream: category.reference.collection('Items').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  //se snapshot for null
                  return Container();
                } else {
                  //se snapshot contem dados
                  return Column(
                    //como cada filho da coluna possui um valor fixo, nao precisamos usar o ListView.builder, podemos usar uma coluna direto com todos os filhos
                    children: snapshot.data!.docs.map((e) {
                      return ListTile(
                        //leading widget na esquerda no ListTile
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(e['imagens'][0]),
                          backgroundColor: Colors.transparent,
                        ),
                        title: Text(e['titulo']),
                        //trailing widget na direita do ListTile
                        trailing: Text('R\$${e['preco'].toStringAsFixed(2)}'),
                        onTap: () {
                          //abre a tela para editar o produto, passando o produto e o id do produto
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProductPage(
                                productId: category.id,
                                product: e,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList()
                      ..add(
                        //adiciona um list tile para adicionar produtos depois da lista de produtos da categooria
                        ListTile(
                          leading: CircleAvatar(
                            child: Icon(
                              Icons.add,
                              color: Color.fromARGB(255, 4, 125, 141),
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                          title: Text('Adicionar'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductPage(productId: category.id),
                              ),
                            );
                          },
                        ),
                      ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
