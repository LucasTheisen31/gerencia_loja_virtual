import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

class ProductBloc extends BlocBase {
  /*lembrando que Bloc -> Sink é a entrada dos dados e Stream é a saida dos dados*/
  //controladores do bloc
  final _dataController = BehaviorSubject<Map>();

  //controlador para dizer se esta salvando ou nao
  final _loadingController = BehaviorSubject<bool>();

  //controlador para dizer se o produto esta criado ou não, para ativar ou desativar o botao de excluir o produto
  final _createdControler = BehaviorSubject<bool>();

  /*vamos declarar as Stream que sao as saidas dos dados dos controladores (vai simplismente retornar a saida(Stream) dos controladores)
  * quando precisarmos os dados do _dataController basta usar um StreamBuilder e colocar na stream o outData*/
  Stream<Map> get outData => _dataController.stream;

  Stream<bool> get outLoading => _loadingController.stream;

  //stream que vai ser usada para habilitar ou desabilitar o botao de exluir um produto (habilita se o produto ja esta criado - saida == true, se nao esta criado, desabilita - saida == fasle)
  Stream<bool> get outCreated => _createdControler.stream;

  String categoryId;
  DocumentSnapshot? product;

  //mapa para copiar manter os dados temporarios antes de salvar no banco de dados
  late Map<String, dynamic> unsavedData;

  /************ Construtor ********************/
  ProductBloc({required this.categoryId, this.product}) {
    //se foi passado um produto, ou seja se um produto esta sendo editado
    if (product != null) {
      //vai fazer uma copia dos dados do produto para o Map unsavedData
      unsavedData = product!.data() as Map<String, dynamic>;
      unsavedData['imagens'] = List.of(product!['imagens']);
      unsavedData['tamanhos'] = List.of(product!['tamanhos']);
      //informamos ao _createdControler que o produto esta criado e ele ira notificar na tela com sua Stream (habilitar botao de excluir)
      _createdControler.add(true);
    } else {
      //coso nao seja passado um produto entao significa que foi clicado no botao de criar um novo produto
      unsavedData = {
        'titulo': null,
        'descricao': null,
        'preco': null,
        'imagens': [],
        'tamanhos': [],
      };
      //produto nao esta criado ainda
      _createdControler.add(false);
    }
    //adiciona o Map unsavedData a entrada do controlador _dataController que vao sair na Stream outData
    _dataController.add(unsavedData);
  }

  /*************** Funcao para salvar as imagens de um produto no Mapa temporario unsavedData **************/
  void saveImages(List? images) {
    unsavedData['imagens'] = images;
  }

  /*************** Funcao para salvar o titulo de um produto no Mapa temporario unsavedData **************/
  void saveTitle(String? title) {
    unsavedData['titulo'] = title;
  }

  /*************** Funcao para salvar a descrição de um produto no Mapa temporario unsavedData **************/
  void saveDescription(String? description) {
    unsavedData['descricao'] = description;
  }

  /*************** Funcao para salvar o preço de um produto no Mapa temporario unsavedData **************/
  void savePrice(String? price) {
    unsavedData['preco'] = double.tryParse(price!);
  }

  /*************** Funcao para salvar os tamanhos de um produto no Mapa temporario unsavedData **************/
  void saveSizes(List? sizes){
    unsavedData['tamanhos'] = sizes;
  }

  /************** Funcao para salvar um produto no firebase *************/
  Future<bool> saveProduct() async {
    //envia true na entrada do controlador  _loadingController, ou seja diz que esta salvando dados
    _loadingController.add(true);
    try {
      if (product != null) {
        //significa que ja tem um produto criado e so estamos modificando ele
        //chama a funcao para fazer o upload das imagens para o firebaseStorage
        await _uploadImages(product!.id);
        //depois de fazer o upload das imagems para o Storage faz o update do produto com os dados para o Firebase
        product!.reference.update(unsavedData);
      } else {
        //se é um novo produto que esta sendo criado
        /*Salva todos os dados do produto na coleçao (produtos) -- documento com id da categoria -- coleçao (itens). Entao salva os dados do produto menos as imagens
        * remove as imagens pq como é um novo produto as imagens estao sendo salvas em formato de arquivo, e queremoos elas en formato String no Firebase,
        * entao temos que salvalas separadamente */

       DocumentReference dr = await FirebaseFirestore.instance
            .collection('produtos')
            .doc(categoryId)
            .collection('Items')
            .add(Map.from(unsavedData)..remove('imagens'));
        //agora fazemos o upload das imagens separadamente para o Storage
        await _uploadImages(dr.id);
        //agora  Map temporario unsavedData possui as imagens no formato de String e podemos fazer o upload de todos os dados para o Firebase
        await dr.update(unsavedData);
      }
      //informamos ao _loadingController que nao estamos mais salvando dados e ele ira notificar na tela com sua Stream
      _loadingController.add(false);
      //informamos ao _createdControler que o produto esta criado e ele ira notificar na tela com sua Stream(habilitar botao de excluir)
      _createdControler.add(true);
      return true;
    } catch (e) {
      //envia false na entrada do controlador  _loadingController, ou seja diz que terminou de salvar os dados
      _loadingController.add(false);
      return false;
    }
  }


  /*void deleteProduct(){
    product!.reference.delete();
  }*/
  /************* FUNCAO QUE DELETA UM PRODUTO *************/
  Future deleteProduct() async {
    //apaga o documento referente ao produto no Firebase Firestore
    product!.reference.delete();
    //pega a lista de URL que sao as imagens no Firebase Storage
    List<dynamic> imageListUrl = List.of(product!["imagens"]);
    for (int i = 0; i < imageListUrl.length; i++) {
      //percorre a lista de URL das imagens e vai no Firebase Storage e apaga a imagen referente a cada URL
      FirebaseStorage.instance.refFromURL(imageListUrl[i]).delete();

        /*(imageListUrl[i])
          .then((reference) => reference.delete())
          .catchError((e) => print(e));*/
    }
  }

  Future _uploadImages(String productId) async {
    /*for para percorrer o Map unsavedData que possui os dados temporarios de um produto, esse for vai verificar todas as imagens do produto e verificar se elas
    * ja estao no firebase ou nao, e se nao estiverem vai fazer o upload delas e substituir o arquivo de imagem local pela url gerada da imagem no FirebaseStorage*/
    for (int i = 0; i < unsavedData['imagens'].length; i++) {
      //se a imagen estiver no formato String significa que ela ja é do firebase, ou seja a String é uma url da imagem entao vai ignorar a parte do codigo relacionada a upload da imagem
      if (unsavedData['imagens'][i] is String) continue;
      //caso a imagem nao esteja no Storage ainda, entao vai salvar em uma pasta cateogryID -> productId (o nome do arquivo vai ser a data e os miliseegundos)
      //uploadTask que vai fazer o upload da imagem na pasta determinada
      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child(categoryId)
          .child(productId)
          .child(DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(unsavedData['imagens'][i]);
      //TaskSnapshot s = await uploadTask -- vai esperar o upload da imagem ser completado
      TaskSnapshot s = await uploadTask;
      //String dounloadURL = await s.ref.getDownloadURL() -- pega a url da imagem que foi feita upload
      String downloadURL = await s.ref.getDownloadURL();
      //agora adiciona url no Map unsavedData que possui os dados temporarios de um produto
      /*ou seja antes essa posicao do unsavedData['imagens'][i] tinha um arquivo local de imagem, e fizemos o upload dela para o FirebaseStorage e agora substituimos esse arquivo
      * pela url do arquivo no FirebaseStorage*/
      unsavedData['imagens'][i] = downloadURL;
    }
  }

  /**************** metodo chamado quando fecha a tela ***************/
  @override
  void dispose() {
    // TODO: implement dispose
    //fecha o controlador
    _dataController.close();
    _loadingController.close();
    _createdControler.close();
    super.dispose();
  }
}
