import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'dart:io';
import '../records/service_record.dart';
import 'vehicle_service_record_pdf.dart';
import 'export_download.dart';
import 'export_workbook.dart';

class ExportService {
  static String filename(ServiceRecord r, String ext) {
    final now = DateTime.now();
    final dt = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}';
    final parts = <String>[];
    if (r.vehicleNumber.isNotEmpty) parts.add(r.vehicleNumber);
    if (r.licensePlate.isNotEmpty) parts.add(r.licensePlate);
    if (r.vin.isNotEmpty) parts.add(r.vin);
    final idPart = parts.isEmpty ? r.id : parts.join('-');
    return 'service-$idPart-$dt.$ext';
  }

  static Future<void> pdf(ServiceRecord r) async {
    final bytes = await VehicleServiceRecordPdf.generate(r);
    await Printing.sharePdf(bytes: bytes, filename: filename(r, 'pdf'));
  }

  static Future<void> xlsx(ServiceRecord r) async {
    final book = ExportWorkbook.build(r);
    final bytes = book.encode();
    if (bytes == null || bytes.isEmpty) {
      debugPrint('ERROR: Excel encode returned null or empty bytes');
      return;
    }
    debugPrint('Excel export: generated ${bytes.length} bytes');

    if (kIsWeb) {
      await downloadXlsxWeb(bytes, filename(r, 'xlsx'));
    } else {
      await _saveNative(bytes, r);
    }
  }

  static Future<void> _saveNative(List<int> bytes, ServiceRecord r) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${filename(r, 'xlsx')}');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)]);
  }
}