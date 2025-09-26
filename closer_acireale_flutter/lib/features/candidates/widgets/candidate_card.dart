import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/candidate_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';

class CandidateCard extends StatelessWidget {
  final Candidate candidate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CandidateCard({
    super.key,
    required this.candidate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border(
          top: BorderSide(color: AppTheme.primaryBlue, width: 4.w),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto candidato
            Center(
              child: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.borderLight, width: 2.w),
                  color: Colors.grey[100],
                ),
                child: ClipOval(
                  child: candidate.photo != null && candidate.photo!.isNotEmpty
                      ? Image.network(
                          candidate.photo!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultAvatar();
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            );
                          },
                        )
                      : _buildDefaultAvatar(),
                ),
              ),
            ),
            
            SizedBox(height: 12.h),
            
            // Nome candidato
            Center(
              child: Text(
                candidate.userName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            SizedBox(height: 8.h),
            
            // Anno classe
            if (candidate.classYear != null && candidate.classYear!.isNotEmpty) ...[
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'Anno: ${candidate.classYear}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],
            
            // Descrizione
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Descrizione:',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Expanded(
                    child: Text(
                      candidate.description ?? 'Nessuna descrizione',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppTheme.textMedium,
                        height: 1.3,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 12.h),
            
            // Link manifesto (se presente)
            if (candidate.manifesto != null && candidate.manifesto!.isNotEmpty) ...[
              Center(
                child: GestureDetector(
                  onTap: () => _launchURL(candidate.manifesto!),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.description,
                          size: 16.w,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Vedi Manifesto',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
            ],
            
            // Bottoni azioni
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Modifica',
                    icon: Icons.edit,
                    onPressed: onEdit,
                    height: 32.h,
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: CustomButton(
                    text: 'Elimina',
                    icon: Icons.delete,
                    onPressed: onDelete,
                    backgroundColor: Colors.red,
                    height: 32.h,
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: Icon(
        Icons.person,
        size: 40.w,
        color: Colors.grey[600],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Handle error
        print('Could not launch $url');
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }
}