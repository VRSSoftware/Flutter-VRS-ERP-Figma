import 'package:flutter/material.dart';

class ImageZoomScreen extends StatelessWidget {
  final List<String> imageUrls; // Changed to List<String>
  final int initialIndex; // Optional: to start at a specific image

  const ImageZoomScreen({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0, // Default to first image
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        Navigator.pop(context); // Double tap to go back
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: imageUrls.isEmpty || imageUrls.every((url) => url.isEmpty)
            ? const Center(
                child: Icon(Icons.image_not_supported, color: Colors.white),
              )
            : PageView.builder(
                controller: PageController(initialPage: initialIndex),
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  final imageUrl = imageUrls[index];
                  return InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: SizedBox.expand(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.error, color: Colors.white),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}