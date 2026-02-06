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
/// 2. Framework Resources path (where CocoaPods puts s.resources)
/// 3. App bundle Resources path
/// 4. Development/testing fallback paths (for flutter test)
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

  // Platform-specific library name
  String libName;
  if (Platform.isMacOS) {
    libName = 'libtensorflowlite_c-mac.dylib';
  } else if (Platform.isLinux) {
    libName = 'libtensorflowlite_c-linux.so';
  } else {
    libName = 'libtensorflowlite_c-win.dll';
  }

  // macOS: Check various locations where CocoaPods puts libraries
  if (Platform.isMacOS) {
    final appBundle = Directory(Platform.resolvedExecutable).parent.parent;

    // Strategy 2: Check inside tflite_flutter_custom.framework/Resources
    // This is where CocoaPods puts s.resources for framework targets
    final frameworkResourcesPath =
        '${appBundle.path}/Frameworks/tflite_flutter_custom.framework/Versions/A/Resources/$libName';
    attemptedPaths.add('Framework Resources path: $frameworkResourcesPath');
    try {
      return DynamicLibrary.open(frameworkResourcesPath);
    } catch (e) {
      // Continue
    }

    // Also check without Versions/A (for symlinked frameworks)
    final frameworkResourcesPathAlt =
        '${appBundle.path}/Frameworks/tflite_flutter_custom.framework/Resources/$libName';
    attemptedPaths
        .add('Framework Resources path (alt): $frameworkResourcesPathAlt');
    try {
      return DynamicLibrary.open(frameworkResourcesPathAlt);
    } catch (e) {
      // Continue
    }

    // Strategy 3: App bundle Resources directory
    final resourcesPath = '${appBundle.path}/Resources/$libName';
    attemptedPaths.add('App Resources path: $resourcesPath');
    try {
      return DynamicLibrary.open(resourcesPath);
    } catch (e) {
      // Continue
    }

    // Strategy 4: Development/testing fallback path
    final fallbackPath = '${Directory.current.path}/macos/Frameworks/$libName';
    attemptedPaths.add('Fallback path: $fallbackPath');
    try {
      return DynamicLibrary.open(fallbackPath);
    } catch (e) {
      // Continue
    }
  } else if (Platform.isLinux) {
    // Linux: Try production and fallback paths
    final productionPath =
        '${Directory(Platform.resolvedExecutable).parent.path}/lib/$libName';
    attemptedPaths.add('Production path: $productionPath');
    try {
      return DynamicLibrary.open(productionPath);
    } catch (e) {
      // Continue
    }

    final fallbackPath = '${Directory.current.path}/linux/lib/$libName';
    attemptedPaths.add('Fallback path: $fallbackPath');
    try {
      return DynamicLibrary.open(fallbackPath);
    } catch (e) {
      // Continue
    }
  } else {
    // Windows: Try production and fallback paths
    final productionPath =
        '${Directory(Platform.resolvedExecutable).parent.path}/$libName';
    attemptedPaths.add('Production path: $productionPath');
    try {
      return DynamicLibrary.open(productionPath);
    } catch (e) {
      // Continue
    }

    final fallbackPath = '${Directory.current.path}/windows/$libName';
    attemptedPaths.add('Fallback path: $fallbackPath');
    try {
      return DynamicLibrary.open(fallbackPath);
    } catch (e) {
      // Continue
    }
  }

  // If all strategies fail, provide a helpful error message
  throw UnsupportedError(
      'Failed to load TensorFlow Lite library. Attempted paths:\n'
      '${attemptedPaths.map((p) => '  - $p').join('\n')}\n\n'
      'Solutions:\n'
      '  1. For production apps: Ensure native libraries are bundled correctly\n'
      '  2. For testing: Set TFLITE_LIB_PATH environment variable:\n'
      '     TFLITE_LIB_PATH=/path/to/library flutter test\n'
      '  3. For testing: Ensure libraries exist in the project fallback locations');
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
