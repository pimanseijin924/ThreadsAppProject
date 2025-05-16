import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/providers/thread_provider.dart';
import 'package:my_app/models/thread_model.dart';
import 'package:my_app/providers/user_id_provider.dart';
import 'package:my_app/services/storage_service.dart';
import 'package:my_app/widgets/dashed_border_painter.dart';

class PostForm extends ConsumerStatefulWidget {
  final String userId;
  final String formType;
  final Thread? thread;
  final String? boardId; // スレッド作成時に必要
  final bool? isDevelopper;

  const PostForm({
    Key? key,
    required this.userId,
    required this.formType,
    this.thread,
    this.boardId,
    this.isDevelopper = false,
  }) : super(key: key);

  @override
  ConsumerState<PostForm> createState() => _PostFormState();
}

class _PostFormState extends ConsumerState<PostForm> {
  final _titleController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  final StorageService _storageService = StorageService();
  // 開発者向け画面に使用
  String _selectedThreadLabel = '';
  final TextEditingController _maxCommentController = TextEditingController();
  String _selectedWriterId = '';

  @override
  Widget build(BuildContext context) {
    String _selectedWriterId = widget.userId;
    return _postFormComponent(
      context,
      ref,
      widget.userId,
      widget.thread ??
          Thread(id: '', title: '', createdAt: DateTime.now(), isDat: false),
    );
  }

  Widget _postFormComponent(
    BuildContext context,
    WidgetRef ref,
    String userId,
    Thread thread,
  ) {
    if (widget.isDevelopper == false) {
      _selectedWriterId = userId;
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('ユーザーID: $_selectedWriterId'),
            if (widget.isDevelopper == true) ...[
              const Text(
                '開発者向け設定',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (widget.formType == 'thread') ...[
                DropdownButtonFormField<String>(
                  value: _selectedThreadLabel,
                  decoration: const InputDecoration(labelText: 'スレッドタイプ'),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('通常')),
                    DropdownMenuItem(value: 'official', child: Text('公式')),
                    DropdownMenuItem(value: 'honsure', child: Text('本スレ')),
                    DropdownMenuItem(value: 'jikkyou', child: Text('実況')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedThreadLabel = value ?? '';
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _maxCommentController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: '最大コメント数',
                    hintText: '例: 100',
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (widget.formType == 'response') ...[
                DropdownButtonFormField<String>(
                  value: _selectedWriterId,
                  decoration: const InputDecoration(labelText: '投稿ID'),
                  items: [
                    DropdownMenuItem(value: userId, child: Text('通常')),
                    DropdownMenuItem(value: '', child: Text('IDなし')),
                    DropdownMenuItem(value: 'official', child: Text('運営ID')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedWriterId = value ?? _selectedWriterId;
                    });
                  },
                ),
              ],
            ],
            if (widget.formType == 'thread')
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'スレッドタイトル'),
              ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '名前'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'メールアドレス'),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: '書き込み内容'),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            _imageSelectorComponent(),
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
                      : () =>
                          _postComment(context, ref, _selectedWriterId, thread),
              child: _isUploading ? Text('投稿中...') : Text('投稿'),
            ),
          ],
        ),
      ),
    );
  }

  // 画像選択ボタンとプレビューを表示するウィジェット
  // REVIEW: 画像アップ画面は別ファイルに分けてもいいかも？
  Widget _imageSelectorComponent() {
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
        _selectedImages.add(XFile(photo.path));
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
      List<String> imageUrls = [];
      var currentThreadId = thread.id;

      // 画像があれば先にアップロード
      if (_selectedImages.isNotEmpty) {
        for (int i = 0; i < _selectedImages.length; i++) {
          final image = _selectedImages[i];
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'thread_${thread.title}_comment_$timestamp.jpg';

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

      // スレッド作成の場合はスレッド作成処理を実行
      if (widget.formType == 'thread') {
        final createThreadService = ref.read(createThreadProvider);

        currentThreadId = await createThreadService.createThread(
          title: _titleController.text,
          boardIds: [widget.boardId!],
          maxCommentCount: 1000,
          limitType: 'count',
          commentDeadline: null, // 'time' 制限の場合は DateTime を指定
          label: _selectedThreadLabel,
        );
      }

      // 書き込みを追加
      final addCommentService = ref.read(addCommentProvider);

      await addCommentService.addComment(
        threadId: currentThreadId,
        writerId: userId,
        writerName: _nameController.text,
        writerEmail: _emailController.text,
        content: _contentController.text,
        imageUrls: _selectedImages.isNotEmpty ? imageUrls : null,
        clientIp: await fetchPublicIp(),
      );

      setState(() {
        _uploadProgress = 0.9; // コメント追加完了
      });

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
