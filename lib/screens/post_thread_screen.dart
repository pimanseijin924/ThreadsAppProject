import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase初期化用
import '../widgets/dashed_boder_painter.dart';
import '../providers/thread_provider.dart';
import '../providers/user_id_provider.dart';
import '../services/storage_service.dart';
import 'base_screen.dart';

class PostThreadScreen extends ConsumerStatefulWidget {
  final String threadTitle;

  PostThreadScreen({required this.threadTitle});

  @override
  _PostThreadScreenState createState() => _PostThreadScreenState();
}

class _PostThreadScreenState extends ConsumerState<PostThreadScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contentController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  final StorageService _storageService = StorageService();

  @override
  Widget build(BuildContext context) {
    final userIdFuture = ref.watch(userIdProvider);

    return BaseScreen(
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(title: Text('書き込み')),
        body: userIdFuture.when(
          data: (userId) => _buildForm(context, ref, userId),
          loading: () => Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('エラーが発生しました: $e')),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, WidgetRef ref, String userId) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
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
                      : () => _postComment(context, ref, userId),
              child: _isUploading ? Text('投稿中...') : Text('投稿'),
            ),
          ],
        ),
      ),
    );
  }

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
                onPressed: _isUploading ? null : _pickImage,
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
        _selectedImage != null
            ? Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
                InkWell(
                  onTap: _isUploading ? null : _removeImage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ],
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

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

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
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _postComment(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) async {
    if (_contentController.text.isEmpty && _selectedImage == null) {
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
      final now = DateFormat('yy/MM/dd HH:mm:ss.SS').format(DateTime.now());
      final threadNotifier = ref.read(threadProvider.notifier);
      final commentNotifier = ref.read(
        threadCommentsProvider(widget.threadTitle).notifier,
      );
      final commentCount =
          threadNotifier.getCommentCount(widget.threadTitle) + 1;

      String? imageUrl;

      // 画像があれば先にアップロード
      if (_selectedImage != null) {
        // ファイル名に日付時刻を含めて一意にする
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName =
            'thread_${widget.threadTitle}_comment_${commentCount}_$timestamp.jpg';

        // Firebase Storageにアップロード
        setState(() {
          _uploadProgress = 0.3; // アップロード開始を示す
        });

        imageUrl = await _storageService.uploadImage(_selectedImage!, fileName);

        setState(() {
          _uploadProgress = 0.7; // 画像アップロード完了
        });
      }

      // 書き込みを追加
      commentNotifier.addComment(
        resNumber: commentCount,
        name: _nameController.text.isNotEmpty ? _nameController.text : '名無しさん',
        email: _emailController.text,
        content: _contentController.text,
        userId: userId,
        timestamp: now,
        imageUrl: imageUrl,
      );

      setState(() {
        _uploadProgress = 0.9; // コメント追加完了
      });

      // スレッドの書き込み数を更新
      threadNotifier.incrementCommentCount(widget.threadTitle);

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
