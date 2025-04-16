import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/models/thread_model.dart';
import 'package:my_app/widgets/dashed_boder_painter.dart';
import 'package:my_app/providers/thread_provider.dart';
import 'package:my_app/providers/user_id_provider.dart';
import 'package:my_app/services/storage_service.dart';

class PostThreadScreen extends ConsumerStatefulWidget {
  final Thread thread;

  const PostThreadScreen({Key? key, required this.thread}) : super(key: key);

  @override
  _PostThreadScreenState createState() => _PostThreadScreenState();
}

class _PostThreadScreenState extends ConsumerState<PostThreadScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contentController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  final List<XFile> _selectedImages = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  final StorageService _storageService = StorageService();

  @override
  Widget build(BuildContext context) {
    final userIdFuture = ref.watch(userIdProvider);

    return Scaffold(
      appBar: AppBar(title: Text('書き込み')),
      body: userIdFuture.when(
        data: (userId) => _buildForm(context, ref, userId, widget.thread),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラーが発生しました: $e')),
      ),
    );
  }

  // REVIEW: 書き込み画面の中身は別ファイルに分けてもいいかも？
  Widget _buildForm(
    BuildContext context,
    WidgetRef ref,
    String userId,
    Thread thread,
    ConsumerState state,
  ) {
    // スレッドの詳細を取得するプロバイダーを使用して、スレッドの詳細を取得
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: state.nameController,
              decoration: InputDecoration(labelText: '名前'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'メールアドレス (任意)'),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: '書き込み内容'),
              maxLines: 5,
            ),
            SizedBox(height: 20),

            _buildImageSelector(),
            SizedBox(height: 20),

            if (_isUploading)
              Column(
                children: [
                  LinearProgressIndicator(value: _uploadProgress),
                  SizedBox(height: 8),
                  Text(
                    'アップロード中... ${(_uploadProgress * 100).toStringAsFixed(1)}%',
                  ),
                  SizedBox(height: 20),
                ],
              ),

            ElevatedButton(
              onPressed:
                  _isUploading
                      ? null
                      : () => _postComment(context, ref, userId, thread),
              child: _isUploading ? Text('投稿中...') : Text('投稿'),
            ),
          ],
        ),
      ),
    );
  }

  // 画像選択ボタンとプレビューを表示するウィジェット
  // REVIEW: 画像アップ画面は別ファイルに分けてもいいかも？
  Widget _buildImageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '画像を添付',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickImages,
                icon: Icon(Icons.photo_library),
                label: Text('ギャラリー'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _takePhoto,
                icon: Icon(Icons.camera_alt),
                label: Text('カメラ'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        _selectedImages.isNotEmpty
            ? Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _selectedImages.map((image) {
                    return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Image.file(
                            File(image.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                        InkWell(
                          onTap:
                              _isUploading ? null : () => _removeImage(image),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            )
            : Container(
              height: 100,
              width: double.infinity,
              child: CustomPaint(
                painter: DashedBorderPainter(),
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      '画像を選択してください',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }

  // アップロード予定の画像のプレビューから画像を削除するメソッド
  // REVIEW: removeImage utilsに移してもいいかも
  void _removeImage(XFile image) {
    setState(() {
      _selectedImages.remove(image);
    });
  }

  // 画像選択ダイアログを表示するメソッド
  // REVIEW: pickImages utilsに移してもいいかも
  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (images != null && images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  // カメラで写真を撮影するメソッド
  // REVIEW: takePhoto utilsに移してもいいかも
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (photo != null) {
      setState(() {
        _selectedImage = File(photo.path);
        _selectedImages.add(photo);
      });
    }
  }

  // 書き込みを投稿するメソッド
  // REVIEW: postComment utilsに移してもいいかも
  Future<void> _postComment(
    BuildContext context,
    WidgetRef ref,
    String userId,
    Thread thread,
  ) async {
    if (_contentController.text.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('書き込み内容または画像を入力してください')));
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final threadNotifier = ref.read(threadProvider.notifier);
      final commentCount =
          threadNotifier.getCommentCount(widget.thread.title) + 1;

      List<String> imageUrls = [];

      // 画像があれば先にアップロード
      if (_selectedImages.isNotEmpty) {
        for (int i = 0; i < _selectedImages.length; i++) {
          final image = _selectedImages[i];
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName =
              'thread_${widget.thread.title}_comment_${commentCount}_$timestamp.jpg';

          final imageUrl = await _storageService.uploadImage(
            File(image.path),
            fileName,
          );
          imageUrls.add(imageUrl);

          setState(() {
            _uploadProgress = (i + 1) / _selectedImages.length * 0.7;
          });
        }
      }

      // 書き込みを追加
      final addCommentService = ref.read(addCommentProvider);

      await addCommentService.addComment(
        threadId: widget.thread.id,
        writerId: userId,
        writerName: _nameController.text,
        writerEmail: _emailController.text,
        content: _contentController.text,
        imageUrls: _selectedImages.isNotEmpty ? imageUrls : null,
      );

      setState(() {
        _uploadProgress = 0.9; // コメント追加完了
      });

      // スレッドの書き込み数を更新
      threadNotifier.incrementCommentCount(widget.thread.id);

      setState(() {
        _uploadProgress = 1.0; // 完了
      });

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
