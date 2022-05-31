import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';

import '../blocs/user_bloc.dart';
import '../widgets/user_tile.dart';

class UsersTab extends StatelessWidget {
  UsersTab({Key? key}) : super(key: key);

  /*Variavel para dar acesso ao UserBlock*/
  final _userBloc = BlocProvider.getBloc<UserBloc>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TextField(
            style: TextStyle(color: Colors.white),
            onChanged: _userBloc.onChangedSearch,
            decoration: InputDecoration(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),

              hintText: 'Pesquisar',
              hintStyle: TextStyle(
                color: Colors.white,
              ),
              border: InputBorder.none,
            ),
          ),
          Expanded(
            child: StreamBuilder(
                stream: _userBloc.outUsers,
                //vai observar o bloc - saida do bloc stream
                builder: (context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    //se o snapshot nao tiver nenhum dado
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  } else if (snapshot.data!.length == 0) {
                    //se o snapshot tiver dados mas nao tiver nenhum usuario cadastrado ainda
                    return Center(
                      child: Text(
                        'Nenhum usuário encontrado!',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    );
                  } else {
                    //se o snapshot tiver dados ou seja se a stream 'saida' do _usersController do UserBloc tiver dados, retornar uma lista com os dados dos usuarios
                    return ListView.separated(
                      /*ListView com separador*/
                      /*itemBuilder funcao qye vai retornar os itens da lista*/
                      itemBuilder: (context, index) {
                        return UserTile(
                          user: snapshot.data[index],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                      /*itemCount, numero de itens que vai ter*/
                      itemCount: snapshot.data!.length,
                    );
                  }
                }),
          ),
        ],
      ),
    );
  }
}
