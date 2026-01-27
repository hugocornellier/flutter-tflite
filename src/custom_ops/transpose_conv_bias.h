// Copyright 2018 The TensorFlow Authors.
// Copyright 2019 The MediaPipe Authors.
// Copyright 2025 tflite_flutter_custom authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Standalone implementation of MediaPipe's Convolution2DTransposeBias custom op
// for use with tflite_flutter_custom. Uses only the public TFLite C API.

#ifndef TFLITE_FLUTTER_CUSTOM_TRANSPOSE_CONV_BIAS_H_
#define TFLITE_FLUTTER_CUSTOM_TRANSPOSE_CONV_BIAS_H_

#include "../tensorflow_lite/common.h"
#include "../tensorflow_lite/c_api.h"

#ifdef __cplusplus
extern "C" {
#endif

// Returns the TfLiteRegistration for the Convolution2DTransposeBias custom op.
// This must be registered with the interpreter options before creating
// an interpreter that uses models containing this custom op.
//
// Usage from Dart:
//   final registration = tfliteBinding.TfLiteFlutter_RegisterConvolution2DTransposeBias();
//   tfliteBinding.TfLiteInterpreterOptionsAddCustomOp(
//     options, "Convolution2DTransposeBias".toNativeUtf8(), registration, 1, 1);
TfLiteRegistration* TfLiteFlutter_RegisterConvolution2DTransposeBias(void);

#ifdef __cplusplus
}
#endif

#endif  // TFLITE_FLUTTER_CUSTOM_TRANSPOSE_CONV_BIAS_H_
