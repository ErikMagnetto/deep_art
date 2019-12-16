import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';

import 'package:flutter/services.dart';

class DeepArt {
  static const MethodChannel _channel =
  const MethodChannel('artistic_style_transfer');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> realtimeTransfer({int yRowStride, int uvRowStride, int uvPixelStride, List<Uint8List> byteList, int imgHeight, int imgWidth, int number}) async {
    // final String outFilePath =
    await _channel.invokeMethod(
        'realtimeTransfer',
        {
          'yRowStride': yRowStride,
          'uvRowStride': uvRowStride,
          'uvPixelStride': uvPixelStride,
          'byteList': byteList,
          'imgHeight': imgHeight,
          'imgWidth': imgWidth,
          'number': number,
        }
    );
    // return outFilePath;
  }

  static Future<String> styleTransfer({String inputFilePath, String outputDir, int number /*List<int> styles, String inputFilePath, String outputFilePath, int quality, double styleFactor=1.0,  final bool convertToGrey*/}) async {
//    assert(styles != null);
//    assert(styles.length !=0 );
//    assert(inputFilePath != null);
//    assert(outputFilePath != null);
//    assert(quality <= 100&& quality >0);
    final String outFilePath = await _channel.invokeMethod(
        'styleTransfer',
        {
//          'styles': styles,
          'inputFilePath': inputFilePath,
          'outputDir': outputDir,
          'number': number,
//          'quality': quality,
//          'styleFactor': styleFactor,
//          'convertToGrey': convertToGrey,
//          'bitmap': bitmap,
        }
    );
    return outFilePath;
  }

}
