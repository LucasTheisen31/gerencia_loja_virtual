import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gerencia_loja_virtual/blocs/orders_bloc.dart';
import 'package:gerencia_loja_virtual/blocs/user_bloc.dart';
import 'package:gerencia_loja_virtual/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gerencia_loja_virtual/pages/login_page.dart';

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = ((X509Certificate cert, String  host, int port) => true);
  }
}

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase
      .initializeApp(); /*Cria e inicializa uma instância do aplicativo Firebase*/
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      blocs: [
        Bloc((i) => UserBloc()),
        Bloc((i) => OrdersBloc()),
      ],
      dependencies: [],
      child: MaterialApp(
        title: 'Gerencia Loja Virtual',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: Color.fromARGB(255, 4, 125, 141),
            //elevation: 0,
          )
        ),
        home: LoginPage(),
      ),
    );
  }
}
