import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:gerencia_loja_virtual/blocs/orders_bloc.dart';
import 'package:gerencia_loja_virtual/blocs/user_bloc.dart';
import 'package:gerencia_loja_virtual/tabs/products_tab.dart';
import 'package:gerencia_loja_virtual/tabs/users_tab.dart';
import 'package:gerencia_loja_virtual/widgets/edit_category_dialog.dart';

import '../tabs/orders_tab.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /*Controlador para a PageView*/
  final PageController _pageController = PageController();

  /*Variavel para pegar o indice da pagina, para alterar o icone selecionado na bottomNavigationBar*/
  int _pageIndex = 0;

  /*Variavel para dar acesso ao OrdersBloc*/
  final _OrdersBloc = BlocProvider.getBloc<OrdersBloc>();

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
        //para ficar somente o gradiente do container
        backgroundColor: Colors.transparent,
        /*Barra de navegaçao inferior da pagina*/
        bottomNavigationBar: BottomNavigationBar(
          //indice atual do icone exibido, o mesmo da pagina exibida
          currentIndex: _pageIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Clientes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Pedidos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Produtos',
            ),
          ],
          backgroundColor: Color.fromARGB(255, 4, 125, 141),
          /*cor de fundo da barra*/
          unselectedItemColor: Colors.white54,
          /*Cor dos itens não slecionados*/
          selectedItemColor: Colors.white,
          /*Cor dos itens selecionados*/
          onTap: (page) {
            _pageController.animateToPage(
              page,
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease,
            );
          },
        ),
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _pageIndex = index;
              });
            },
            children: [
              UsersTab(),
              OrdersTab(),
              ProductsTab(),
            ],
          ),
        ),
        /*botao flutuante, mas como temos vair telas no PageView, cada tela vai ter um floatingActionButton diferente, entao fizemos uma funcao para isso
        _buildfloatingActionButton() que vai retornar um widget FloatingActionButton de acordo com a tela PageView*/
        floatingActionButton: _buildfloatingActionButton(),
      ),
    );
  }

  Widget? _buildfloatingActionButton() {
    switch (_pageIndex) {
      case 0:
        return null;
      case 1:
        return SpeedDial(
          icon: Icons.sort,
          backgroundColor: Color.fromARGB(255, 4, 125, 141),
          //sobreposição de opacidade
          overlayOpacity: 0.4,
          // cor de sobreposição
          overlayColor: Colors.black,
          //botoes filhos
          children: [
            SpeedDialChild(
              child: Icon(
                Icons.arrow_downward,
                color: Color.fromARGB(255, 4, 125, 141),
              ),
              label: 'Concluidos Abaixo',
              labelStyle: TextStyle(fontSize: 14),
              onTap: () {
                //chama a funcao do OrdersBloc que ordena os pedidos
                _OrdersBloc.setOrderCriteria(SortCriteria.CONCLUIDOSULTIMO);
              },
            ),
            SpeedDialChild(
              child: Icon(
                Icons.arrow_upward,
                color: Color.fromARGB(255, 4, 125, 141),
              ),
              label: 'Concluidos Acima',
              labelStyle: TextStyle(fontSize: 14),
              onTap: () {
                //chama a funcao do OrdersBloc que ordena os pedidos
                _OrdersBloc.setOrderCriteria(SortCriteria.CONCLUIDOSPRIMEIRO);
              },
            ),
          ],
        );
      case 2:
        //FloatingActionButton para criar uma categoria nova
        return FloatingActionButton(
          backgroundColor: Color.fromARGB(255, 4, 125, 141),
          child: Icon(Icons.add),
          onPressed: () {
            //exibe o dialogo para preencher os dados da nova categoria
            showDialog(
                context: context, builder: (context) => EditCategoryDialog());
          },
        );
    }
  }
}
