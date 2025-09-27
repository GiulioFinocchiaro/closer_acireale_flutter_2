import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/web_safe_image.dart';

class MaterialPreviewDialog extends StatelessWidget {
  final String title;
  final String filePath;

  const MaterialPreviewDialog({
    super.key,
    required this.title,
    required this.filePath,
  });

  bool get _isImage {
    final extension = filePath.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  bool get _isPdf {
    return filePath.toLowerCase().endsWith('.pdf');
  }

  String get _fullUrl => '${AppConstants.cdnUrl}/$filePath';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: AppTheme.textMedium,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Content
            Expanded(
              child: Center(
                child: _buildContent(context),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Chiudi'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isImage) {
      return Container(
        constraints: const BoxConstraints(
          maxHeight: 400,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            _fullUrl,
            fit: BoxFit.contain,
            headers: const {
              'Access-Control-Allow-Origin': '*',
              'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
              'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization, X-Request-With',
            },
            errorBuilder: (context, error, stackTrace) {
              print('Errore caricamento immagine: $error');
              print('URL: $_fullUrl');
              return _buildErrorWidget(context);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const CircularProgressIndicator();
            },
          ),
        ),
      );
    } else if (_isPdf) {
      // Per i PDF, mostriamo un placeholder che apre il link
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf,
            size: 64,
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(height: 16),
          Text(
            'Documento PDF',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Clicca per aprire in una nuova scheda',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMedium,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Aprire PDF in nuova scheda
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Apri PDF'),
          ),
        ],
      );
    } else {
      // Per altri tipi di file
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_drive_file,
            size: 64,
            color: AppTheme.textMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'File non visualizzabile',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tipo di file non supportato per l\'anteprima',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMedium,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Aprire file
            },
            icon: const Icon(Icons.download),
            label: const Text('Scarica File'),
          ),
        ],
      );
    }
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorRed,
          ),
          const SizedBox(height: 16),
          Text(
            'Errore nel caricamento',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.errorRed,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Impossibile caricare l\'immagine',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}