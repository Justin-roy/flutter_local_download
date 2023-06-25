import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:path/path.dart' as pathext;
import 'package:http/http.dart' as http;

class LocalDownload {
  Uint8List? _imagebytes;
  String? _filepath;
  bool isImageUrl = false;
  // getter
  Uint8List? get imageBytes => _imagebytes;
  String? get filePath => _filepath;
  Future<void> downloadFileToLocalStorage(
    BuildContext context, {
    required String url,
    String msg = "File Downloading ...",
  }) async {
    ProgressDialog pd = ProgressDialog(context: context);
    try {
      pd.show(
          max: 100, msg: msg, backgroundColor: Colors.white.withOpacity(0.6));
      HttpClient httpClient = HttpClient();
      HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
      HttpClientResponse response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response,
          onBytesReceived: (rec, total) {
        int progress = (((rec / total!) * 100).toInt());
        pd.update(value: progress);
      });
      isImageUrl = await _isImageUrl(url);
      _imagebytes = bytes;
      String ext = isImageUrl ? 'jpg' : pathext.extension(url);
      String localePath = await _getLocalPath(bytes: bytes, ext: ext);
      _filepath = localePath;
      httpClient.close();
      pd.close();
      await openFileLocation(localePath);
    } catch (e) {
      debugPrint(e.toString());
      pd.close();
    }
  }

  Future<String> _getLocalPath(
      {required Uint8List bytes, required String ext}) async {
    final String fileName = "File-${Random().nextInt(100)}.$ext";
    Directory? downloadsDirectory = await getExternalStorageDirectory();
    String localePath = '${downloadsDirectory?.path}/$fileName';
    File file = File(localePath);
    await file.writeAsBytes(bytes);
    return localePath;
  }

  Future<void> openFileLocation(String path) async {
    await OpenFilex.open(path);
  }

  Future<bool> _isImageUrl(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType != null && contentType.startsWith('image')) {
          return true;
        }
      }
    } catch (e) {
      debugPrint('Error checking URL: $e');
    }
    return false;
  }
}
