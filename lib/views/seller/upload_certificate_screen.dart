// lib/views/seller/upload_certificate_screen.dart
// Screen 16 of 20

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';
import '../../widgets/status_chip.dart';

class UploadCertificateScreen extends StatefulWidget {
  const UploadCertificateScreen({super.key});

  @override
  State<UploadCertificateScreen> createState() => _UploadCertificateScreenState();
}

class _UploadCertificateScreenState extends State<UploadCertificateScreen> {
  final _bodyCtrl = TextEditingController();
  final _issuingCtrl = TextEditingController();
  bool _isSubmitting = false;
  String? _uploadedFileName;

  final _pastCerts = [
    {'id': 'CERT-001', 'product': 'Halal Chicken Breast', 'date': '2023-08-12', 'status': 'approved'},
    {'id': 'CERT-002', 'product': 'Goat Milk', 'date': '2023-09-05', 'status': 'approved'},
    {'id': 'CERT-003', 'product': 'Date Mix', 'date': '2024-01-02', 'status': 'pending'},
  ];

  Future<void> _submitCert() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() { _isSubmitting = false; _uploadedFileName = null; _bodyCtrl.clear(); _issuingCtrl.clear(); });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Certificate submitted for review!'), backgroundColor: AppColors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Certificate')),
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
            child: const Row(children: [
              Icon(Icons.verified_user_outlined, color: AppColors.primary),
              SizedBox(width: 10),
              Expanded(child: Text('Upload your halal certification documents to get your products approved for sale.', style: TextStyle(color: AppColors.primaryDark, fontSize: 13))),
            ]),
          ),
          const SizedBox(height: 20),
          // Upload form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('New Certificate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => setState(() => _uploadedFileName = 'halal_cert_2024.pdf'),
                child: Container(
                  height: 100, width: double.infinity,
                  decoration: BoxDecoration(
                    color: _uploadedFileName != null ? AppColors.primaryLight : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _uploadedFileName != null ? AppColors.primary : AppColors.border),
                  ),
                  child: _uploadedFileName != null
                      ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.picture_as_pdf, color: AppColors.primary, size: 32),
                          const SizedBox(width: 8),
                          Text(_uploadedFileName!, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ])
                      : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.cloud_upload_outlined, size: 36, color: AppColors.textLight),
                          SizedBox(height: 6),
                          Text('Tap to upload PDF/Image', style: TextStyle(color: AppColors.textSecondary)),
                        ]),
                ),
              ),
              const SizedBox(height: 14),
              InputField(label: 'Issuing Authority', controller: _issuingCtrl, prefixIcon: Icons.business_outlined,
                  hint: 'e.g. JAKIM, IFANCA'),
              const SizedBox(height: 14),
              InputField(label: 'Certificate Number', controller: _bodyCtrl, prefixIcon: Icons.numbers_outlined),
              const SizedBox(height: 20),
              CustomButton(label: 'Submit for Review', onPressed: _submitCert, isLoading: _isSubmitting),
            ]),
          ),
          const SizedBox(height: 24),
          const Text('Past Submissions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          ..._pastCerts.map((cert) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: AppColors.primaryLight, child: Icon(Icons.description_outlined, color: AppColors.primary)),
              title: Text(cert['product']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              subtitle: Text('${cert['id']} • ${cert['date']}', style: const TextStyle(fontSize: 11)),
              trailing: StatusChip(status: cert['status']!),
            ),
          )),
        ]),
      ),
    );
  }
}
