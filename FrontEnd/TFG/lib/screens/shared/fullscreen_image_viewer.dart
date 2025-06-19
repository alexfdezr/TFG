import 'package:flutter/material.dart';
import '../../utils/image_utils.dart';

class FullscreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullscreenImageViewer({super.key, required this.images, this.initialIndex = 0});

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  void _canviarImatge(int delta) {
    final nouIndex = _currentIndex + delta;
    if (nouIndex >= 0 && nouIndex < widget.images.length) {
      _pageController.animateToPage(
        nouIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentIndex = nouIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: widget.images.length,
            itemBuilder: (context, index) => Center(
              child: getImageWidget(widget.images[index], width: double.infinity),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          if (widget.images.length > 1) ...[
            Positioned(
              left: 16,
              top: MediaQuery.of(context).size.height / 2 - 24,
              child: IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white, size: 48),
                onPressed: () => _canviarImatge(-1),
              ),
            ),
            Positioned(
              right: 16,
              top: MediaQuery.of(context).size.height / 2 - 24,
              child: IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white, size: 48),
                onPressed: () => _canviarImatge(1),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
