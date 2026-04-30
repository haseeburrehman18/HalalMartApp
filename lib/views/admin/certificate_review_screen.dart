// lib/views/admin/certificate_review_screen.dart
// Screen 18 of 20

import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_chip.dart';

class CertificateReviewScreen extends StatefulWidget {
  const CertificateReviewScreen({super.key});

  @override
  State<CertificateReviewScreen> createState() =>
      _CertificateReviewScreenState();
}

class _CertificateReviewScreenState extends State<CertificateReviewScreen> {

  final List<Map<String, dynamic>> _certs = [
    {
      'id': 'CERT-101',
      'seller': 'Al-Barakah Store',
      'product': 'Halal Chicken Breast',
      'authority': 'JAKIM',
      'date': '2024-01-10',
      'status': 'pending',
      'file': 'assets/sample/cert1.jpg'
    },
    {
      'id': 'CERT-102',
      'seller': 'Salam Foods',
      'product': 'Organic Goat Milk',
      'authority': 'IFANCA',
      'date': '2024-01-09',
      'status': 'pending',
      'file': 'assets/sample/cert2.jpg'
    },
    {
      'id': 'CERT-103',
      'seller': 'Blessed Market',
      'product': 'Date Mix Premium',
      'authority': 'MUI',
      'date': '2024-01-08',
      'status': 'approved',
      'file': 'assets/sample/cert3.jpg'
    },
    {
      'id': 'CERT-104',
      'seller': 'Halal Hub',
      'product': 'Lamb Chops',
      'authority': 'JAKIM',
      'date': '2024-01-07',
      'status': 'rejected',
      'file': 'assets/sample/cert4.jpg'
    },
  ];

  void _updateStatus(int i, String newStatus) {
    setState(() {
      _certs[i]['status'] = newStatus;
    });
  }

  /// VIEW CERTIFICATE
  void _viewCertificate(String path) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text(
                "Certificate Preview",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),

              const SizedBox(height: 10),

              Image.asset(
                path,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Certificate Review')),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _certs.length,
        itemBuilder: (_, i) {

          final cert = _certs[i];

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      const Icon(Icons.picture_as_pdf,
                          color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        cert['id'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      StatusChip(status: cert['status']),
                    ],
                  ),

                  const SizedBox(height: 10),

                  _InfoRow('Seller', cert['seller']),
                  _InfoRow('Product', cert['product']),
                  _InfoRow('Authority', cert['authority']),
                  _InfoRow('Submitted', cert['date']),

                  const SizedBox(height: 10),

                  /// PREVIEW BUTTON
                  GestureDetector(
                    onTap: () =>
                        _viewCertificate(cert['file']),
                    child: Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.visibility,
                                color: AppColors.primary),
                            SizedBox(width: 6),
                            Text(
                              'View Certificate Document',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (cert['status'] == 'pending') ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [

                        Expanded(
                          child: CustomButton(
                            label: 'Approve',
                            onPressed: () =>
                                _updateStatus(i, 'approved'),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: CustomButton(
                            label: 'Reject',
                            color: AppColors.error,
                            onPressed: () =>
                                _updateStatus(i, 'rejected'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {

  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [

          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}