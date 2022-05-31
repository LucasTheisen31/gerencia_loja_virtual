import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceSheet extends StatelessWidget {
  const ImageSourceSheet({Key? key, required this.onImageSelected})
      : super(key: key);
  //********** funcao CallBack que vai retornar a imagem no formato File
  final Function(File) onImageSelected;

  /*********** funcao para editar a imagen ****************/
  Future<void> imageSelected(File? image) async {
    if (image != null) {
      //ImageCropper é um plugin para cortar imagens, apos cortar a imagem ele retorna a imagem
      File? croppedImage = await ImageCropper().cropImage(
        sourcePath: image.path,
        //aspectRatioPresets: [CropAspectRatioPreset.square],
      );
      //chama a funcao de callback (onImageSelected) para retornar a imagem para a ImagesWidget(Widget anterios que chama essa funcao de callback) para adicionar esta imagem na lista das imagens do produto
      onImageSelected(croppedImage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      //funcao chamada quando fechar a janela
      onClosing: () {},
      //builder o que sera exibido no BootonShee
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () async {
              XFile? image =
                  await ImagePicker().pickImage(source: ImageSource.camera);
              File? imageFile = File(image!.path);
              imageSelected(imageFile);
            },
            child: Text('Camera'),
          ),
          TextButton(
            onPressed: () async {
              XFile? image =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              File? imageFile = File(image!.path);
              imageSelected(imageFile);
            },
            child: Text('Galeria'),
          ),
        ],
      ),
    );
  }
}
