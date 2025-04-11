import 'package:flutter/material.dart';
import 'comment_image_grid.dart';

/// モーダルで画像を拡大表示するウィジェット
class ImageModal extends StatelessWidget {
  final String imageUrl;
  const ImageModal({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // モーダルの外側をタップすると閉じる
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.black54, // 背景を暗くする
        child: Center(
          child: GestureDetector(
            // モーダル内の画像を長押しで保存メニューを表示
            onLongPress: () async {
              final selected = await showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SafeArea(
                    child: Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.save_alt),
                          title: const Text('画像を保存する'),
                          onTap: () {
                            Navigator.pop(context, 'save');
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
              if (selected == 'save') {
                await saveImage(imageUrl);
              }
            },
            child: Image.network(imageUrl, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
