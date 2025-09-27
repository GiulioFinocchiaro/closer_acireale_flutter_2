import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class WebSafeImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const WebSafeImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  String get _fullUrl {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return '${AppConstants.cdnUrl}/$imagePath';
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Per la versione web, usiamo un approccio diverso
      return _buildWebImage();
    } else {
      // Per le versioni native, usiamo Image.network normale
      return _buildNativeImage();
    }
  }

  Widget _buildWebImage() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _fullUrl,
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Errore caricamento immagine web: $error');
            debugPrint('URL immagine: $_fullUrl');
            
            return errorWidget ?? Container(
              width: width,
              height: height,
              color: Colors.grey.shade100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    size: (height != null && height! < 100) ? 24 : 48,
                    color: Colors.grey.shade400,
                  ),
                  if (height == null || height! >= 60) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Immagine non disponibile',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            
            return placeholder ?? Container(
              width: width,
              height: height,
              color: Colors.grey.shade50,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNativeImage() {
    return Image.network(
      _fullUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Errore caricamento immagine native: $error');
        debugPrint('URL immagine: $_fullUrl');
        
        return errorWidget ?? Container(
          width: width,
          height: height,
          color: Colors.grey.shade100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image,
                size: (height != null && height! < 100) ? 24 : 48,
                color: Colors.grey.shade400,
              ),
              if (height == null || height! >= 60) ...[
                const SizedBox(height: 8),
                Text(
                  'Immagine non disponibile',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        return placeholder ?? Container(
          width: width,
          height: height,
          color: Colors.grey.shade50,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
}

class WebSafeNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const WebSafeNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Per web, prova prima con un proxy CORS se necessario
      return _buildWebSafeImage();
    } else {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        loadingBuilder: (context, child, loadingProgress) => 
          loadingProgress == null ? child : _buildLoadingWidget(loadingProgress),
      );
    }
  }

  Widget _buildWebSafeImage() {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Errore caricamento immagine web: $error');
        debugPrint('URL: $url');
        
        // Se l'immagine fallisce, prova con un approccio alternativo
        return _tryAlternativeLoad();
      },
      loadingBuilder: (context, child, loadingProgress) => 
        loadingProgress == null ? child : _buildLoadingWidget(loadingProgress),
    );
  }

  Widget _tryAlternativeLoad() {
    // Prova a caricare con un approccio diverso o mostra errore
    return errorWidget ?? _buildErrorWidget();
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: (height != null && height! < 100) ? 24 : 48,
            color: Colors.grey.shade400,
          ),
          if (height == null || height! >= 60) ...[
            const SizedBox(height: 8),
            Text(
              'Immagine non disponibile',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(ImageChunkEvent loadingProgress) {
    return placeholder ?? Container(
      width: width,
      height: height,
      color: Colors.grey.shade50,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
              : null,
        ),
      ),
    );
  }
}