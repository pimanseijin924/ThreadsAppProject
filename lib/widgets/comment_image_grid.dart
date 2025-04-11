import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
//import 'package:image_downloader/image_downloader.dart'; // 画像保存用パッケージ 古いので代わりにimage_gallery_saverを使用
// import 'package:image_gallery_saver/image_gallery_saver.dart'; これも古いので代わりにflutter_image_gallery_saverを使用
import 'package:flutter_image_gallery_saver/flutter_image_gallery_saver.dart';
import 'dart:typed_data';
import 'image_modal.dart'; // 画像モーダルウィジェット

/// コメント内の画像リストを3列の正方形グリッドで表示するウィジェット
class CommentImageGrid extends StatelessWidget {
  final List<String> imageUrls;
  const CommentImageGrid({Key? key, required this.imageUrls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 画像が空の場合は何も表示しない
    if (imageUrls.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3列表示
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
          childAspectRatio: 1.0, // 正方形
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          final imageUrl = imageUrls[index];
          return GestureDetector(
            onTap: () {
              // 画像をタップするとモーダルで拡大表示
              showDialog(
                context: context,
                builder: (context) => ImageModal(imageUrl: imageUrl),
              );
            },
            onLongPress: () async {
              // 長押しで保存メニューを表示
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
            child: Container(
              color: Colors.black, // 正方形の背景色
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain, // アスペクト比を維持して収まるように表示
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 画像をローカルに保存する処理の例（実際の実装はお好みで調整してください）
Future<void> saveImage(String imageUrl) async {
  try {
    // 画像をダウンロード
    final response = await Dio().get(
      imageUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    // 画像を保存
    await FlutterImageGallerySaver.saveImage(Uint8List.fromList(response.data));

    print('画像を保存しました');
  } catch (e) {
    print('画像の保存に失敗しました: $e');
  }
}
