import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../records/service_record.dart';
import 'vehicle_service_record_pdf.dart';

class ExportService {
  static Future<void> pdf(ServiceRecord r) async {
    final bytes = await VehicleServiceRecordPdf.generate(r);
    await Printing.sharePdf(bytes: bytes, filename: 'service-${r.id}.pdf');
  }
  static Future<void> xlsx(ServiceRecord r) async {
    final book = Excel.createExcel(); final summary = book['Summary'];
    for (final row in [['Vehicle', r.vehicleNumber], ['Date', r.dateStarted], ['Miles', r.miles], ['Hours', r.hours], ['Service type', r.serviceType], ['Technician', r.technician.name], ['Notes', r.notes], ['Next steps', r.nextSteps]]) { summary.appendRow(row.map((x) => TextCellValue('$x')).toList()); }
    final steps = book['Checklist']; steps.appendRow(['Item', 'Done', 'Value', 'Notes'].map((x) => TextCellValue(x)).toList()); for (final s in r.steps) { steps.appendRow([s.title, s.done ? '\u2713' : '', s.value, s.notes].map((x) => TextCellValue(x)).toList()); }
    final bytes = book.encode(); if (bytes == null) return; final file = File('${(await getTemporaryDirectory()).path}/service-${r.id}.xlsx'); await file.writeAsBytes(bytes); await Share.shareXFiles([XFile(file.path)]);
  }
}
