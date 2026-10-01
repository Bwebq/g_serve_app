import 'package:flutter/material.dart';
import '../services/api_config.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

void showServerConfigDialog(
  BuildContext context, {
  VoidCallback? onConfigSaved,
}) {
  final ipController = TextEditingController(text: ApiConfig.baseUrl);
  bool testing = false;
  String? statusMessage;
  bool? testResult;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.settings_ethernet, color: AppTheme.primaryBlue, size: 22),
              SizedBox(width: 8),
              Text(
                'Pengaturan IP Server',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agar HP dapat terhubung ke Laravel di laptop, hubungkan HP ke Wi-Fi / Hotspot yang sama dengan laptop.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textGrey, height: 1.4),
                ),
                const SizedBox(height: 12),
                const Text(
                  'PILIH PRESET IP:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ActionChip(
                      label: const Text('Wi-Fi PC (192.168.11.164)', style: TextStyle(fontSize: 11)),
                      backgroundColor: const Color(0xFFEBF3FE),
                      onPressed: () {
                        setDialogState(() {
                          ipController.text = ApiConfig.defaultLanUrl;
                        });
                      },
                    ),
                    ActionChip(
                      label: const Text('Hotspot (192.168.137.1)', style: TextStyle(fontSize: 11)),
                      backgroundColor: const Color(0xFFF1F5F9),
                      onPressed: () {
                        setDialogState(() {
                          ipController.text = ApiConfig.defaultHotspotUrl;
                        });
                      },
                    ),
                    ActionChip(
                      label: const Text('Emulator (10.0.2.2)', style: TextStyle(fontSize: 11)),
                      backgroundColor: const Color(0xFFF1F5F9),
                      onPressed: () {
                        setDialogState(() {
                          ipController.text = ApiConfig.defaultEmulatorUrl;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'URL ENDPOINT API:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: ipController,
                  decoration: InputDecoration(
                    hintText: 'http://192.168.11.164:8000/api',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  style: const TextStyle(fontSize: 12.5, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Text(
                    'Perintah Laravel di terminal PC:\nphp artisan serve --host=0.0.0.0 --port=8000',
                    style: TextStyle(fontSize: 11, color: Color(0xFF92400E), height: 1.3),
                  ),
                ),
                if (statusMessage != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        testResult == true ? Icons.check_circle : Icons.error_outline,
                        size: 16,
                        color: testResult == true ? const Color(0xFF16A34A) : AppTheme.accentRed,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          statusMessage!,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: testResult == true ? const Color(0xFF16A34A) : AppTheme.accentRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
              ),
              onPressed: testing
                  ? null
                  : () async {
                      setDialogState(() {
                        testing = true;
                        statusMessage = 'Menguji koneksi ke server...';
                        testResult = null;
                      });
                      final newUrl = ipController.text.trim();
                      await ApiConfig.saveBaseUrl(newUrl);
                      final online = await ApiService.instance.checkConnection();
                      setDialogState(() {
                        testing = false;
                        testResult = online;
                        statusMessage = online
                            ? 'Koneksi BERHASIL! Server siap digunakan.'
                            : 'Koneksi gagal. Cek apakah Laravel menyala & satu Wi-Fi.';
                      });
                      if (onConfigSaved != null) {
                        onConfigSaved();
                      }
                    },
              child: testing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Simpan & Tes'),
            ),
          ],
        );
      },
    ),
  );
}
