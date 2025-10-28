## tflite_flutter_custom

A drop-in alternative to [`tflite_flutter`](https://pub.dev/packages/tflite_flutter), made easier. `tflite_flutter_custom` automatically includes all required native TensorFlow Lite libraries for Android, iOS, macOS, Windows, and Linux.  
No manual setup or handling of native libraries required.

### Why this fork?

`tflite_flutter` is an excellent library, but it requires developers to manually include platform-specific native binaries.  
This fork removes that friction by bundling everything inside the package.  

✅ **No more copying `.so`, `.dll`, or `.dylib` files**  
✅ **Works out of the box** on all supported platforms  
✅ **Same API** as `tflite_flutter` — fully compatible

### Installation

```yaml
dependencies:
  tflite_flutter_custom: ^1.0.0
````

### Usage

The API is identical to `tflite_flutter`, so you can follow their documentation directly.
For example:

```dart
import 'package:tflite_flutter_custom/tflite_flutter_custom.dart';

void main() async {
  final interpreter = await Interpreter.fromAsset('model.tflite');
  print('Model loaded successfully!');
}
```

### Platform Support

* ✅ Android
* ✅ iOS
* ✅ macOS
* ✅ Windows
* ✅ Linux

All required native binaries are automatically included in the build.

### Notes

* You **don’t need to add** any TensorFlow Lite libraries manually.
* The plugin uses the same bindings as `tflite_flutter` under the hood.
* Perfect for Flutter plugin authors who want seamless TFLite integration without setup complexity.

### Credits

This project is based on [`tflite_flutter`](https://pub.dev/packages/tflite_flutter) by the TensorFlow team and contributors.
All credit for the original bindings goes to them.