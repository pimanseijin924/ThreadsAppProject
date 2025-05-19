import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage =
      FirebaseStorage.instance
        ..setMaxUploadRetryTime(const Duration(minutes: 5))
        ..setMaxOperationRetryTime(const Duration(minutes: 5));
  // タイムアウトを 5 分に設定

  Future<String> uploadImage(File imageFile, String fileName) async {
    try {
      // 画像ファイルのパスを設定
      final storageRef = _storage.ref().child('thread_images/$fileName');

      // メタデータを設定（オプション）
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': imageFile.path},
      );

      // 画像をアップロード
      final uploadTask = storageRef.putFile(imageFile, metadata);

      // アップロードの進行状況を監視
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Upload progress: $progress');
      });

      // アップロード完了を待機
      await uploadTask;

      // 画像のダウンロードURLを取得
      final downloadUrl = await storageRef.getDownloadURL();
      print('\nDownload URL: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      // ↓ここで必ずエラーコードとメッセージをログ出力↓
      print(
        '🔴 Firebase Storage Error ▶ code: ${e.code}, message: ${e.message}',
      );
      // 必要に応じて、コードごとに処理を分岐
      switch (e.code) {
        case 'storage/object-not-found':
          // ファイル自体が存在しない
          print('File not found');
          break;
        case 'storage/unauthorized':
          // 認証は通っているがルール上許可されていない
          print('Unauthorized access');
          break;
        // 他のケースも handle...
        default:
        // 想定外のエラー
      }
      rethrow;
    }
  }

  // 画像を削除するメソッド
  Future<void> deleteImage(String imageUrl) async {
    try {
      // URLからリファレンスを取得
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw Exception('画像の削除に失敗しました: ${e.message}');
    }
  }
}
