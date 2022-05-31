import 'dart:async';
import 'dart:io';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

//lembrando que Bloc -> Sink é a entrada dos dados e Stream é a saida dos dados
class CategoryBloc extends BlocBase{
  //************* CONTROLADORES *************
  final _titleController = BehaviorSubject<String>();
  //nao definimos o tipo do controller da imagen pois a imagem pode ser um File (armazenada no celular) ou uma String (URL do FirebaseStorage)
  final _imageController = BehaviorSubject();
  //para controlar se caso estiver criando uma nova categoria desativar o boao de excluir pq a categoria nao foi salva ainda
  final _deleteController = BehaviorSubject<bool>();
  //para salvar a imagem selecionada para a categoria
  File? image;
  //para armazenar o titulo digitado na categoria
  String? title;

  //************* STREAMS, SAIDA DOS DADOS DOS CONTROLLERS **************
  /*mas perceba que no final da Stream outTitle tem um .transform ou seja é o metodo para validar o titulo passado, na validaçao ela vai receber a saida da Stream
  e vai validar o dado ou nao, retornando o proprio titulo(se for valido) ou uma mensagem de erro(se invalido)
  resumindo a Stream outTitle que é a saida dos dados do controller _titleController tem uma validação sa saida e nao deixa sair valor null*/
  Stream<String> get outTitle => _titleController.stream.transform(StreamTransformer<String, String>.fromHandlers(
    handleData: (title, sink) {
      //recebe o titulo e envia o dado (no sink) de acordo com a validaçao
      if(title.isEmpty){
        sink.addError('Insira um titulo');
      }else{
        sink.add(title);
      }
    },
  ));
  Stream get outImage => _imageController.stream;
  Stream<bool> get outDelete => _deleteController.stream;
  //stream para ativar ou desativar o botao de salvar a categoria, so vai ativar o botao quando as duas streams(outTitle e outImage) retornarem true
  Stream<bool> get outSubmitdValid => Rx.combineLatest2(outTitle, outImage, (a, b) => true);

  //******** VARIAVEL DO TIPO DOCUMENTSNAPSHOOT PARA DAR ACESSO A CATEGORIA NO FIREBASE
  DocumentSnapshot? category;

  //************* CONSTRUTOR *****************
  CategoryBloc(this.category){
    //no construutor ja verificamos se a categoria passada é null ou nao, ou seja se for null significa que é uma nova categoria que esta sendo criada, caso contrario é uma categoria existente
    if (category != null) {
      title = category!['titulo'];

      _titleController.add(category!['titulo']);
      _imageController.add(category!['icone']);
      //habilita o botao de excluir
      _deleteController.add(true);
    }else{
      //desabilita o botao de excluir
      _deleteController.add(false);
    }
  }

  //************* FUNCAO PARA ADICIONAR O TITULO DIGITADO NA CATEGORIA NO _titleController
  void setTitle(String title){
    //adiciona o titulo no controller _titleController que vai atualizar aonde tiver observando a Stream outTitle
    _titleController.add(title);
    this.title = title;
  }

  //************* FUNCAO PARA ADICIONAR UMA IMAGEM NO _imageController
  void setImage(File image){
    this.image = image;
    //adiciona a imagem no controller _imageController que vai atualizar aonde tiver observando a Stream outImage
    _imageController.add(image);
  }

  /*************** FUCNAO PARA SALVAR OS DADS DA CATEGORIA NO FARIBASE*/
  Future saveData() async{
    if(image == null && category != null && title == category!['titulo']) return;
    /*se nao foi alterado nenhum dado da categoria entao sai do save data, ou seja
    se a imagem nao foi alterada, se a categoria existe e o titulo é o mesmo da categoria ja existente entao significa que nada foi alterado
    so sai da funcao saveDava
     */
    //senao
    //Mapa temporario para armazzenar os dados que serao salvos no Firebase
    Map<String, dynamic> dataToUpdate = {};

    //caso a imagem seja != null entao vai salvar em uma pasta icones -> title (titulo da categoria)
    //uploadTask que vai fazer o upload da imagem na pasta determinada
    if(image != null){
      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child('icones')
          .child(title!)
          .putFile(image!);
      //TaskSnapshot s = await uploadTask -- vai esperar o upload da imagem ser completado
      TaskSnapshot s = await uploadTask;
      //agora adiciona a url no Map dataToUpdate que possui os dados temporarios da categoria
      dataToUpdate['icone'] = await s.ref.getDownloadURL();
    }

    if(title != category?['titulo'] || category == null){
      //se o titulo foi editado, ou é uma nova categoria que esta sendo salva
      dataToUpdate['titulo'] = title;
    }

    if(category == null){
    //se é uma nova categoria que esta sendo salva, temos que criar uma nova categoria no firebase
      //salva na coleçao produtos -> cria um documento com (titulo da categoria em letra nibuscula) e salva o Mapa temporario dataToUpdate dentro deste documento
      FirebaseFirestore.instance.collection('produtos').doc(title!.toLowerCase()).set(dataToUpdate);
    }else{
      //se é uma categoria que esta sendo editada, precisamos atualizar seus dados no firebase
      category!.reference.update(dataToUpdate);
    }

  }

  /*************** FUCNAO PARA deletar OS DADS DA CATEGORIA NO FARIBASE*/
  Future delete() async{
    category!.reference.delete();
  }

  //************* DISPOSE PARA FECHAR OS CONTROLADORES ***************
  @override
  void dispose() {
    _titleController.close();
    _imageController.close();
    _deleteController.close();
    super.dispose();
  }
}