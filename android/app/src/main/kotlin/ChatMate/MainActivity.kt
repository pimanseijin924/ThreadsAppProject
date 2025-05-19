package chatmate.prerelease

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity(){
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    // ここで全プラグインを明示的に登録
    GeneratedPluginRegistrant.registerWith(flutterEngine)
  }
}
