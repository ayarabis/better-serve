import 'dart:io';

import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/constants.dart';
import '/core/util.dart';

class FileDataSouce {
  Future<List<String>> getFiles(String bucket, String path) async {
    var data = await supabase.storage
        .from(bucket)
        .list(path: path, searchOptions: const SearchOptions());
    return data.map((e) => publicPath(e.name)).toList();
  }

  Future<String> uploadFile(File file, String bucket, String path) async {
    return await supabase.storage.from(bucket).upload(
        "$path/${basename(file.path)}", file,
        fileOptions: const FileOptions(upsert: true));
  }

  Future<void> deleteFile(String bucket, List<String> paths) async {
    await supabase.storage.from(bucket).remove(paths);
  }
}
