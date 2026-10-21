import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'package:flick/core/theme/app_colors.dart';
import 'package:flick/features/playlists/utils/playlist_cover_crop_math.dart';
import 'package:flick/l10n/l10n.dart';
import 'package:flick/widgets/common/flick_snackbar.dart';

/// Square crop editor for a user-selected playlist cover.
///
/// Pops with the path to a temporary JPEG, which the caller copies into
/// durable storage before deleting it.
class PlaylistCoverCropScreen extends StatefulWidget {
  const PlaylistCoverCropScreen({super.key, required this.sourcePath});

  final String sourcePath;

  @override
  State<PlaylistCoverCropScreen> createState() =>
      _PlaylistCoverCropScreenState();
}

class _PlaylistCoverCropScreenState extends State<PlaylistCoverCropScreen> {
  final TransformationController _controller = TransformationController();

  Uint8List? _imageBytes;
  Size? _imageSize;
  bool _preparing = true;
  bool _failed = false;
  bool _saving = false;
  bool _viewportReady = false;
  double? _viewportSide;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _prepare() async {
    try {
      final data = await compute(_prepareCoverImage, widget.sourcePath);
      if (!mounted) return;
      setState(() {
        _imageBytes = data['bytes'] as Uint8List;
        _imageSize = Size(
          (data['width'] as int).toDouble(),
          (data['height'] as int).toDouble(),
        );
        _preparing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _preparing = false;
        _failed = true;
      });
    }
  }

  void _centerViewport(double side) {
    if (_viewportSide == side) return;
    _viewportSide = side;
    _viewportReady = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _viewportSide != side) return;
      final imageSize = _imageSize;
      if (imageSize == null) return;

      final coverScale = math.max(
        side / imageSize.width,
        side / imageSize.height,
      );
      final childWidth = imageSize.width * coverScale;
      final childHeight = imageSize.height * coverScale;
      _controller.value = Matrix4.identity()
        ..setTranslationRaw(
          (side - childWidth) / 2,
          (side - childHeight) / 2,
          0,
        );
      setState(() => _viewportReady = true);
    });
  }

  Future<void> _save() async {
    final imageSize = _imageSize;
    final side = _viewportSide;
    if (_saving || imageSize == null || side == null || !_viewportReady) {
      return;
    }

    setState(() => _saving = true);
    try {
      final crop = calculatePlaylistCoverCrop(
        viewportSize: Size.square(side),
        imageSize: imageSize,
        transform: _controller.value,
      );
      final bytes = await compute(_cropCoverImage, <String, Object>{
        'path': widget.sourcePath,
        'left': crop.left,
        'top': crop.top,
        'side': crop.width,
        'preparedWidth': imageSize.width,
        'preparedHeight': imageSize.height,
      });
      if (bytes == null) {
        throw const FormatException('Could not crop playlist cover');
      }

      final temporaryDirectory = await getTemporaryDirectory();
      final directory = Directory(
        '${temporaryDirectory.path}${Platform.pathSeparator}'
        'playlist_cover_crop',
      );
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final file = File(
        '${directory.path}${Platform.pathSeparator}'
        'playlist_cover_${DateTime.now().microsecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(bytes, flush: true);

      if (!mounted) return;
      Navigator.of(context).pop(file.path);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showFlickSnackBar(
        SnackBar(
          content: Text(context.l10n.couldNotUpdatePlaylistCover),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final imageSize = _imageSize;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l10n.cropCover),
        actions: [
          TextButton(
            onPressed: _viewportReady && !_saving ? _save : null,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(l10n.save),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final available = math.min(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  final side = math.max(1.0, available - 32);
                  if (imageSize != null && _imageBytes != null) {
                    _centerViewport(side);
                  }

                  if (_failed) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          l10n.couldNotOpenThatPhotoTry,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }

                  return Center(
                    child: SizedBox(
                      width: side,
                      height: side,
                      child: _preparing || imageSize == null
                          ? const Center(child: CircularProgressIndicator())
                          : !_viewportReady || _imageBytes == null
                          ? const SizedBox.shrink()
                          : ClipRect(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  InteractiveViewer(
                                    transformationController: _controller,
                                    constrained: false,
                                    minScale: 1,
                                    maxScale: 4,
                                    child: _buildImage(
                                      side,
                                      imageSize,
                                      _imageBytes!,
                                    ),
                                  ),
                                  const IgnorePointer(
                                    child: CustomPaint(
                                      painter: _CropOverlayPainter(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Text(
                l10n.cropCoverHint,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(double side, Size imageSize, Uint8List bytes) {
    final coverScale = math.max(
      side / imageSize.width,
      side / imageSize.height,
    );
    return SizedBox(
      width: imageSize.width * coverScale,
      height: imageSize.height * coverScale,
      child: Image.memory(
        bytes,
        width: imageSize.width * coverScale,
        height: imageSize.height * coverScale,
        fit: BoxFit.fill,
        gaplessPlayback: true,
      ),
    );
  }
}

Map<String, Object> _prepareCoverImage(String sourcePath) {
  final decoded = img.decodeImage(File(sourcePath).readAsBytesSync());
  if (decoded == null) {
    throw const FormatException('Could not decode playlist cover');
  }

  var image = img.bakeOrientation(decoded);
  final longestSide = math.max(image.width, image.height);
  if (longestSide > 2400) {
    final scale = 2400 / longestSide;
    image = img.copyResize(
      image,
      width: math.max(1, (image.width * scale).round()),
      height: math.max(1, (image.height * scale).round()),
      interpolation: img.Interpolation.average,
    );
  }

  return {
    'bytes': img.encodeJpg(image, quality: 92),
    'width': image.width,
    'height': image.height,
  };
}

Uint8List? _cropCoverImage(Map<String, Object> request) {
  final decoded = img.decodeImage(
    File(request['path'] as String).readAsBytesSync(),
  );
  if (decoded == null) return null;

  final image = img.bakeOrientation(decoded);
  final preparedWidth = (request['preparedWidth'] as num).toDouble();
  final preparedHeight = (request['preparedHeight'] as num).toDouble();
  final scaleX = preparedWidth > 0 ? image.width / preparedWidth : 1.0;
  final scaleY = preparedHeight > 0 ? image.height / preparedHeight : 1.0;
  final cropScale = math.min(scaleX, scaleY);
  final maxLeft = math.max(0, image.width - 1);
  final maxTop = math.max(0, image.height - 1);
  final left = ((request['left'] as num) * scaleX).round().clamp(0, maxLeft);
  final top = ((request['top'] as num) * scaleY).round().clamp(0, maxTop);
  final maxSide = math.min(image.width - left, image.height - top);
  final side = ((request['side'] as num) * cropScale).round().clamp(1, maxSide);

  var cropped = img.copyCrop(image, x: left, y: top, width: side, height: side);
  if (cropped.width > 1600) {
    cropped = img.copyResize(
      cropped,
      width: 1600,
      height: 1600,
      interpolation: img.Interpolation.average,
    );
  }

  return img.encodeJpg(cropped, quality: 90);
}

class _CropOverlayPainter extends CustomPainter {
  const _CropOverlayPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white54;
    canvas.drawRect(Offset.zero & size, border);

    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white24;
    final thirdX = size.width / 3;
    final thirdY = size.height / 3;
    canvas.drawLine(Offset(thirdX, 0), Offset(thirdX, size.height), grid);
    canvas.drawLine(
      Offset(thirdX * 2, 0),
      Offset(thirdX * 2, size.height),
      grid,
    );
    canvas.drawLine(Offset(0, thirdY), Offset(size.width, thirdY), grid);
    canvas.drawLine(
      Offset(0, thirdY * 2),
      Offset(size.width, thirdY * 2),
      grid,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
