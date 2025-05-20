import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfViewerScreen extends StatelessWidget {
  final String filePath;

  const PdfViewerScreen({Key? key, required this.filePath}) : super(key: key);

  Future<void> _sharePdf() async {
    try {
      await Share.shareXFiles([XFile(filePath)], text: 'Order PDF');
    } catch (e) {
      debugPrint('Error sharing PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order PDF'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePdf,
            tooltip: 'Share PDF',
          ),
        ],
      ),
      body: PDFView(
        filePath: filePath,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: false,
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF Error: $error')),
          );
        },
        onPageError: (page, error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error on page $page: $error')),
          );
        },
        onRender: (pages) {
          // Called when the PDF is rendered
          debugPrint('PDF rendered with $pages pages');
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sharePdf,
        tooltip: 'Share PDF',
        child: const Icon(Icons.share),
      ),
    );
  }
}