import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_constants.dart'; // adjust import path

class PdfViewerScreen extends StatefulWidget {
  final String orderNo;
  final String? whatsappNo;

  const PdfViewerScreen({
    Key? key,
    required this.orderNo,
    required this.whatsappNo,
  }) : super(key: key);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool _loading = true;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _fetchPdf();
  }

  Future<void> _fetchPdf() async {
    try {
      final docId = widget.orderNo.replaceAll(RegExp(r'[^0-9]'), '');
      final dio = Dio();
      final response = await dio.post(
        '${AppConstants.Pdf_url}/api/values/order',
        data: {"doc_id": docId},
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/order_$docId.pdf';
        final file = File(filePath);
        await file.writeAsBytes(response.data);
        if (mounted) {
          setState(() {
            _filePath = filePath;
            _loading = false;
          });
        }
      } else {
        _showError('Failed to load PDF: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    setState(() {
      _loading = false;
    });
  }

  Future<void> _sharePdf() async {
    if (_filePath != null) {
      try {
        await Share.shareXFiles([XFile(_filePath!)], text: 'Order PDF');
      } catch (e) {
        debugPrint('Error sharing PDF: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order PDF'),
        actions: [
          if (!_loading)
            IconButton(
              icon: Icon(Icons.share),
              onPressed: _sharePdf,
              tooltip: 'Share PDF',
            ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
           
                Expanded(
                  child: PDFView(
                    filePath: _filePath!,
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
                  ),
                ),
              ],
            ),
      floatingActionButton: !_loading
          ? FloatingActionButton(
              onPressed: _sharePdf,
              tooltip: 'Share PDF',
              child: Icon(Icons.share),
            )
          : null,
    );
  }
}
