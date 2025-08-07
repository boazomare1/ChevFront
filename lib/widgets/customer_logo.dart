import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:chevenergies/shared utils/app_theme.dart';
import 'package:chevenergies/services/image_service.dart';

class CustomerLogo extends StatefulWidget {
  final String logoUrl;
  final double width;
  final double height;
  final String placeholderAsset;
  final String shopName;
  final String? shopLocation;

  const CustomerLogo({
    super.key,
    required this.logoUrl,
    required this.width,
    required this.height,
    required this.placeholderAsset,
    required this.shopName,
    this.shopLocation,
  });

  @override
  State<CustomerLogo> createState() => _CustomerLogoState();
}

class _CustomerLogoState extends State<CustomerLogo> {
  Uint8List? _imageBytes;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (widget.logoUrl.isEmpty) {
      print('CustomerLogo: No logo URL provided');
      return;
    }

    print('CustomerLogo: Loading image from URL: ${widget.logoUrl}');

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final imageBytes = await ImageService.fetchImage(widget.logoUrl);

      if (mounted) {
        setState(() {
          _imageBytes = imageBytes;
          _isLoading = false;
        });

        if (imageBytes != null) {
          print(
            'CustomerLogo: Image loaded successfully, bytes: ${imageBytes.length}',
          );
        } else {
          print('CustomerLogo: ImageService returned null');
          setState(() {
            _hasError = true;
          });
        }
      }
    } catch (e) {
      print('CustomerLogo: Error loading image: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap:
              widget.logoUrl.isNotEmpty && _imageBytes != null
                  ? () => _showImagePreview(context)
                  : null,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImageContent(),
            ),
          ),
        ),
        // Visibility icon overlay
        if (widget.logoUrl.isNotEmpty && _imageBytes != null)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.visibility, color: Colors.white, size: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildImageContent() {
    if (widget.logoUrl.isEmpty) {
      return _buildPlaceholder();
    }

    if (_isLoading) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[200],
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      );
    }

    if (_hasError || _imageBytes == null) {
      return _buildPlaceholder();
    }

    return Image.memory(
      _imageBytes!,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
    );
  }

  void _showImagePreview(BuildContext context) {
    if (_imageBytes == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.95)),
            child: Stack(
              children: [
                // Full screen image with InteractiveViewer
                Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.memory(_imageBytes!, fit: BoxFit.contain),
                  ),
                ),

                // Top bar with close button and shop info
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 10,
                      left: 20,
                      right: 20,
                      bottom: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        // Shop info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.shopName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (widget.shopLocation != null) ...[
                                SizedBox(height: 4),
                                Text(
                                  widget.shopLocation!,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Close button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            style: IconButton.styleFrom(
                              padding: EdgeInsets.all(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom info bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: MediaQuery.of(context).padding.bottom + 20,
                      top: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.zoom_in,
                          color: Colors.white.withOpacity(0.7),
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Pinch to zoom • Tap to close',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.asset(
        widget.placeholderAsset,
        width: widget.width * 0.6,
        height: widget.height * 0.6,
        fit: BoxFit.contain,
      ),
    );
  }
}
