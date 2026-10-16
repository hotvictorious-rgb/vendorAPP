import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/constants/app_colors.dart';

class PhotoAuditViewerDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final String? badgeLabel;
  final Color? badgeColor;

  const PhotoAuditViewerDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.badgeLabel,
    this.badgeColor,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imagePath,
    String? badgeLabel,
    Color? badgeColor,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => PhotoAuditViewerDialog(
        title: title,
        subtitle: subtitle,
        imagePath: imagePath,
        badgeLabel: badgeLabel,
        badgeColor: badgeColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullUrl = ApiEndpoints.resolveImageUrl(imagePath);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (badgeLabel != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: (badgeColor ?? AppColors.primaryPurple).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeLabel!.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: badgeColor ?? AppColors.primaryPurple,
                              ),
                            ),
                          ),
                        ],
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // Image Container with InteractiveViewer (pinch/zoom)
            ClipRRect(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.55,
                ),
                color: Colors.black,
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.8,
                  maxScale: 3.5,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: fullUrl,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                      errorWidget: (_, __, ___) => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.broken_image_outlined, size: 48, color: Colors.white54),
                              SizedBox(height: 8),
                              Text('Could not load proof snap', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Footer Notice
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Live cryptographic snap anchored to VMarket settlement ledger.',
                      style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
