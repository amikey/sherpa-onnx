#!/usr/bin/env bash
#
# This scripts shows how to build JNI libs for sherpa-onnx
# Note: This scripts runs only on Linux and macOS, though sherpa-onnx
# supports building JNI libs for Windows.

set -e


cd ..
mkdir -p build
cd build

if [[ ! -f ../build/lib/libsherpa-onnx-jni.dylib  && ! -f ../build/lib/libsherpa-onnx-jni.so ]]; then
  cmake \
    -DSHERPA_ONNX_ENABLE_PYTHON=OFF \
    -DSHERPA_ONNX_ENABLE_TESTS=OFF \
    -DSHERPA_ONNX_ENABLE_CHECK=OFF \
    -DBUILD_SHARED_LIBS=ON \
    -DSHERPA_ONNX_ENABLE_PORTAUDIO=OFF \
    -DSHERPA_ONNX_ENABLE_JNI=ON \
    ..

  make -j4
  ls -lh lib
fi

export LD_LIBRARY_PATH=$PWD/build/lib:$LD_LIBRARY_PATH

cd ../kotlin-api-examples

if [ ! -f ./sherpa-onnx-streaming-zipformer-en-2023-02-21/tokens.txt ]; then
  git lfs install
  git clone https://huggingface.co/csukuangfj/sherpa-onnx-streaming-zipformer-en-2023-02-21
fi

if [ ! -f ./vits-zh-aishell3/tokens.txt ]; then
  git lfs install
  git clone https://huggingface.co/csukuangfj/vits-zh-aishell3
fi

kotlinc-jvm -include-runtime -d main.jar Main.kt WaveReader.kt SherpaOnnx.kt faked-asset-manager.kt Tts.kt

ls -lh main.jar

java -Djava.library.path=../build/lib -jar main.jar
