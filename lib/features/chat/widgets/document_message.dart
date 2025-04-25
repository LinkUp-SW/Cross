import 'dart:io';
import 'package:flutter/material.dart';
import 'package:link_up/features/chat/model/message_model.dart';
import 'package:open_filex/open_filex.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DocumentMessageWidget extends StatefulWidget {
  final Message message;

  const DocumentMessageWidget({super.key, required this.message});

  @override
  State<DocumentMessageWidget> createState() => _DocumentMessageWidgetState();
}

class _DocumentMessageWidgetState extends State<DocumentMessageWidget> {
  bool _isDownloading = false;
  bool _isDownloaded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final filePath = widget.message.content;
    final isUrl = filePath.startsWith('http');
    final fileName = filePath.split('/').last;

    return GestureDetector(
      onTap: () async {
        if (isUrl) {
          final uri = Uri.parse(filePath);
          final directory = await getApplicationDocumentsDirectory();
          final localPath = '${directory.path}/$fileName';
          final localFile = File(localPath);

          if (await localFile.exists()) {
            OpenFilex.open(localPath);
          } else {
            setState(() => _isDownloading = true);
            try {
              final response = await http.get(uri);
              await localFile.writeAsBytes(response.bodyBytes);
              setState(() => _isDownloaded = true);
              await OpenFilex.open(localPath);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Download error: $e")),
              );
            } finally {
              setState(() => _isDownloading = false);
            }
          }
        } else {
          final file = File(filePath);
          if (await file.exists()) {
            OpenFilex.open(file.path);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("File not found")),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.cardColor, // Adaptive background
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.insert_drive_file, color: colorScheme.primary), // Theme-aware icon color
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                fileName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            if (_isDownloading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }
}
