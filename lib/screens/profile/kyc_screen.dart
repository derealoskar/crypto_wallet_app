import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_models.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  int _step = 0;
  static const _titles = [
    'Personal Information',
    'Phone Verification',
    'Identity Document',
    'Selfie Verification',
    'Review',
  ];

  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _otpController = TextEditingController();
  String? _documentType = 'National ID Card';
  bool _documentUploaded = false;
  bool _selfieCaptured = false;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  bool get _canContinue {
    switch (_step) {
      case 0:
        return _nameController.text.trim().isNotEmpty &&
            _dobController.text.trim().isNotEmpty &&
            _addressController.text.trim().isNotEmpty;
      case 1:
        return _otpController.text.trim().length == 6;
      case 2:
        return _documentUploaded;
      case 3:
        return _selfieCaptured;
      default:
        return true;
    }
  }

  Future<void> _next() async {
    if (_step < _titles.length - 1) {
      setState(() => _step++);
      return;
    }
    setState(() => _submitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    context.read<UserProvider>().updateKycStatus(KycStatus.pending);
    setState(() => _submitting = false);
    setState(() => _step++); // move to result screen
  }

  @override
  Widget build(BuildContext context) {
    final isResult = _step >= _titles.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(isResult ? 'Verification Result' : 'KYC · ${_titles[_step]}'),
      ),
      body: SafeArea(
        child: isResult ? _buildResult() : _buildStep(),
      ),
    );
  }

  Widget _buildStep() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
          child: Row(
            children: [
              for (int i = 0; i < _titles.length; i++)
                Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i <= _step ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _stepContent(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: PrimaryButton(
            label: _step == _titles.length - 1 ? 'Submit for Review' : 'Continue',
            loading: _submitting,
            onPressed: _canContinue ? _next : null,
          ),
        ),
      ],
    );
  }

  Widget _stepContent() {
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Legal Name'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _dobController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Date of Birth', hintText: 'DD/MM/YYYY'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000, 1, 1),
                  firstDate: DateTime(1930),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  _dobController.text = '${date.day}/${date.month}/${date.year}';
                  setState(() {});
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Residential Address'),
              onChanged: (_) => setState(() {}),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We sent a 6-digit code to your registered phone number.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Verification Code'),
            ),
            TextButton(onPressed: () {}, child: const Text('Resend code')),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _documentType,
              decoration: const InputDecoration(labelText: 'Document Type'),
              items: const ['National ID Card', "Driver's License", 'International Passport']
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => _documentType = v),
            ),
            const SizedBox(height: AppSpacing.md),
            _uploadBox(
              uploaded: _documentUploaded,
              label: 'Upload front of document',
              onTap: () => setState(() => _documentUploaded = true),
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Take a clear selfie so we can match it to your document photo.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            _uploadBox(
              uploaded: _selfieCaptured,
              label: 'Capture selfie',
              icon: Icons.face_retouching_natural_rounded,
              onTap: () => setState(() => _selfieCaptured = true),
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _reviewRow('Full name', _nameController.text),
            _reviewRow('Date of birth', _dobController.text),
            _reviewRow('Address', _addressController.text),
            _reviewRow('Document type', _documentType ?? '-'),
            _reviewRow('Document uploaded', _documentUploaded ? 'Yes' : 'No'),
            _reviewRow('Selfie captured', _selfieCaptured ? 'Yes' : 'No'),
          ],
        );
    }
  }

  Widget _reviewRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodySmall),
            Flexible(
              child: Text(value, style: AppTextStyles.bodyMedium, textAlign: TextAlign.end),
            ),
          ],
        ),
      );

  Widget _uploadBox({
    required bool uploaded,
    required String label,
    IconData icon = Icons.upload_file_rounded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: uploaded ? AppColors.success.withValues(alpha: 0.06) : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: uploaded ? AppColors.success : AppColors.border,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              uploaded ? Icons.check_circle_rounded : icon,
              size: 36,
              color: uploaded ? AppColors.success : AppColors.textMuted,
            ),
            const SizedBox(height: 10),
            Text(
              uploaded ? 'Uploaded' : label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: uploaded ? AppColors.success : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(color: AppColors.warning, shape: BoxShape.circle),
            child: const Icon(Icons.hourglass_top_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Submitted for Review', style: AppTextStyles.headingLarge, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your documents are being reviewed. This usually takes less than 24 hours. '
            'We\'ll notify you once verification is complete.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Done',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
