/*
 * Copyright 2023 The TensorFlow Authors. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *             http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:ffi';
import 'dart:io';

import 'package:tflite_flutter_custom/src/bindings/tensorflow_lite_bindings_generated.dart';

final DynamicLibrary _dylib = () {
  if (Platform.isAndroid) {
    return DynamicLibrary.open('libtensorflowlite_jni.so');
  }

  if (Platform.isIOS) {
    return DynamicLibrary.process();
  }

  // Desktop platforms support multiple loading strategies for testing
  if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
    return _loadDesktopLibrary();
  }

  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// Loads the TensorFlow Lite library for desktop platforms.
///
/// This function tries multiple strategies to locate the native library:
/// 1. Environment variable override (TFLITE_LIB_PATH)
/// 2. Production app bundle path (for released apps)
/// 3. Development/testing fallback paths (for flutter test)
///
/// This ensures the library works in both production and testing environments.
DynamicLibrary _loadDesktopLibrary() {
  final List<String> attemptedPaths = [];

  // Strategy 1: Check for environment variable override
  final envPath = Platform.environment['TFLITE_LIB_PATH'];
  if (envPath != null && envPath.isNotEmpty) {
    attemptedPaths.add('TFLITE_LIB_PATH: $envPath');
    try {
      return DynamicLibrary.open(envPath);
    } catch (e) {
      // Continue to fallback paths if env var path fails
    }
  }

  // Strategy 2: Try production app bundle path
  String productionPath;
  if (Platform.isMacOS) {
    productionPath = '${Directory(Platform.resolvedExecutable).parent.parent.path}/resources/libtensorflowlite_c-mac.dylib';
  } else if (Platform.isLinux) {
    productionPath = '${Directory(Platform.resolvedExecutable).parent.path}/lib/libtensorflowlite_c-linux.so';
  } else {
    // Windows
    productionPath = '${Directory(Platform.resolvedExecutable).parent.path}/libtensorflowlite_c-win.dll';
  }

  attemptedPaths.add('Production path: $productionPath');
  try {
    return DynamicLibrary.open(productionPath);
  } catch (e) {
    // Continue to fallback paths if production path fails
  }

  // Strategy 3: Try development/testing fallback paths
  String fallbackPath;
  if (Platform.isMacOS) {
    fallbackPath = '${Directory.current.path}/macos/Frameworks/libtensorflowlite_c-mac.dylib';
  } else if (Platform.isLinux) {
    fallbackPath = '${Directory.current.path}/linux/lib/libtensorflowlite_c-linux.so';
  } else {
    // Windows
    fallbackPath = '${Directory.current.path}/windows/libtensorflowlite_c-win.dll';
  }

  attemptedPaths.add('Fallback path: $fallbackPath');
  try {
    return DynamicLibrary.open(fallbackPath);
  } catch (e) {
    // All strategies failed
  }

  // If all strategies fail, provide a helpful error message
  throw UnsupportedError(
    'Failed to load TensorFlow Lite library. Attempted paths:\n'
    '${attemptedPaths.map((p) => '  - $p').join('\n')}\n\n'
    'Solutions:\n'
    '  1. For production apps: Ensure native libraries are bundled correctly\n'
    '  2. For testing: Set TFLITE_LIB_PATH environment variable:\n'
    '     TFLITE_LIB_PATH=/path/to/library flutter test\n'
    '  3. For testing: Ensure libraries exist in the project fallback locations'
  );
}

final DynamicLibrary _dylibGpu = () {
  if (Platform.isAndroid) {
    return DynamicLibrary.open('libtensorflowlite_gpu_jni.so');
  }

  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// TensorFlowLite Bindings
final tfliteBinding = TensorFlowLiteBindings(_dylib);

/// TensorFlowLite Gpu Bindings
final tfliteBindingGpu = TensorFlowLiteBindings(_dylibGpu);
