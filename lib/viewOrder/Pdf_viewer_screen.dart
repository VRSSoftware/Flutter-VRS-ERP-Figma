import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:vrs_erp_figma/constants/app_constants.dart';

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
  String? filePath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final docId = widget.orderNo.replaceAll(RegExp(r'[^0-9]'), '');
      final dio = Dio();
      final response = await dio.post(
        '${AppConstants.Pdf_url}/api/values/order2',
        data: {"doc_id": docId},
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/order_$docId.pdf';
        final file = File(path);
        await file.writeAsBytes(response.data);

        setState(() {
          filePath = path;
          isLoading = false;
        });
      } else {
        _showError('Failed to load PDF: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error loading PDF: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.whatsapp,
                    size: 25,
                    //color: Colors.green,
                  ),

                  title: Text('Send via WhatsApp'),
                  onTap: () {
                    Navigator.pop(context);
                    _showWhatsAppDialog();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share'),
                  onTap: () {
                    Navigator.pop(context);
                    _sharePdf();
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _showWhatsAppDialog() async {
    final controller = TextEditingController(text: widget.whatsappNo);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Send PDF via WhatsApp'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'WhatsApp Number'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final file = File(filePath!);
                  final fileBytes = await file.readAsBytes();
                  final success = await sendWhatsAppFile(
                    fileBytes: fileBytes,
                    mobileNo: controller.text,
                    fileType: 'pdf',
                    caption: 'Order ${widget.orderNo}',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Sent via WhatsApp' : 'Failed to send',
                      ),
                    ),
                  );
                },
                child: Text('Send'),
              ),
            ],
          ),
    );
  }

  Future<void> _sharePdf() async {
    if (filePath == null) return;
    try {
      await Share.shareXFiles([
        XFile(filePath!),
      ], text: 'Order ${widget.orderNo}');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Share error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order PDF'),
        actions: [
          IconButton(icon: Icon(Icons.share), onPressed: _showShareOptions),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : PDFView(
                filePath: filePath!,
                enableSwipe: true,
                swipeHorizontal: true,
                autoSpacing: false,
                pageFling: false,
                onError: (error) => _showError('PDF Error: $error'),
                onPageError:
                    (page, error) => _showError('Error on page $page: $error'),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showShareOptions,
        tooltip: 'Share PDF',
        child: Icon(Icons.share),
      ),
    );
  }
}

Future<bool> sendWhatsAppFile({
  required List<int> fileBytes,
  required String mobileNo,
  required String fileType,
  String? caption,
}) async {
  try {
    String fileBase64 = base64Encode(fileBytes);

    final response = await http.post(
      Uri.parse("http://node4.wabapi.com/v4/postfile.php"),
      body: {
        'data': fileBase64,
        'filename': fileType == 'image' ? 'catalog.jpg' : 'catalog.pdf',
        'key': AppConstants.whatsappKey,
        'number': '91$mobileNo',
        'caption': caption ?? 'Please find the file attached.',
      },
    );

    return response.statusCode == 200;
  } catch (e) {
    print('Error sending file: $e');
    return false;
  }
}
