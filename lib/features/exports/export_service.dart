import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'dart:html' as html;
import 'dart:io';
import '../records/service_record.dart';
import 'vehicle_service_record_pdf.dart';
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
      await _downloadWeb(bytes, r);
    } else {
      await _saveNative(bytes, r);
    }
  }

  static Future<void> _downloadWeb(List<int> bytes, ServiceRecord r) async {
    try {
      final uint8list = Uint8List.fromList(bytes);
      final blob = html.Blob([uint8list]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = filename(r, 'xlsx');
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
      debugPrint('Excel export: download triggered for ${filename(r, 'xlsx')}');
    } catch (e) {
      debugPrint('ERROR: Excel export failed: $e');
    }
  }

  static Future<void> _saveNative(List<int> bytes, ServiceRecord r) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${filename(r, 'xlsx')}');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)]);
  }
}