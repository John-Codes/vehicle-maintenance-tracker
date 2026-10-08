import 'package:excel/excel.dart';
import '../maintenance_lists/schedule_checklist.dart';
import '../records/service_record.dart';
import 'excel_styles.dart';
import 'export_cell_ops.dart';

class ExportWorkbook {
  static Excel build(ServiceRecord r) {
    final book = Excel.createExcel();
    final sheet = book['Sheet1'];

    const widths = [14.0, 18.0, 32.0, 9.0, 18.0, 46.0];
    for (var i = 0; i < widths.length; i++) {
      sheet.setColumnWidth(i, widths[i]);
    }

    var row = 0;

    // Banner
    ExportCellOps.merged(sheet, row, 0, 5, 'SERVICE REPORT'.toUpperCase(), ExcelStyles.headerStyle());
    sheet.setRowHeight(row++, 42);

    // Spacer
    row++;

    // Info block
    final fields = [
      ['Vehicle', r.vehicleNumber],
      ['License Plate', r.licensePlate],
      ['VIN', r.vin],
      ['Date', r.dateStarted],
      ['Miles', r.miles?.toString() ?? ''],
      ['Hours', r.hours?.toString() ?? ''],
      ['Service type', r.serviceType],
      ['Technician', r.technician.name],
      ['Workers', r.workerNames.join(', ')],
      ['Location', 'Captured per-step'],
      ['Notes', r.notes],
      ['Next steps', r.nextSteps],
    ];
    for (var i = 0; i < fields.length; i++) {
      ExportCellOps.cell(sheet, row, 0, fields[i][0], ExcelStyles.labelStyle());
      ExportCellOps.merged(sheet, row, 1, 5, fields[i][1], ExcelStyles.valueStyle(zebra: i.isOdd));
      sheet.setRowHeight(row, 24);
      row++;
    }

    // Spacer
    row += 2;

    // Checklist header
    const headers = ['Frequency', 'Component', 'Item', 'Done', 'Value', 'Notes'];
    for (var i = 0; i < headers.length; i++) {
      ExportCellOps.cell(sheet, row, i, headers[i].toUpperCase(), ExcelStyles.checklistHeaderStyle());
    }
    sheet.setRowHeight(row, 28);
    row++;

    // Group by frequency
    final groups = <String, List<ScheduleChecklistRow>>{};
    for (final item in scheduleChecklist(r.schedule)) {
      final parts = item.item.split(' · ');
      final freq = parts.isNotEmpty ? parts[0] : '';
      groups.putIfAbsent(freq, () => []).add(item);
    }

    groups.forEach((freq, list) {
      // Group band
      ExportCellOps.merged(sheet, row, 0, 5, '${freq.toUpperCase()}  ·  ${list.length} item${list.length == 1 ? '' : 's'}', ExcelStyles.groupBandStyle());
      sheet.setRowHeight(row, 24);
      row++;

      for (var i = 0; i < list.length; i++) {
        final item = list[i];
        final s = item.step;
        final parts = item.item.split(' · ');
        final comp = parts.length > 1 ? parts[1] : '';
        final itemTitle = parts.length > 2 ? parts[2] : item.item;
        ExportCellOps.cell(sheet, row, 0, freq, ExcelStyles.cellStyle(zebra: i.isOdd));
        ExportCellOps.cell(sheet, row, 1, comp, ExcelStyles.cellStyle(zebra: i.isOdd, bold: true, align: HorizontalAlign.Left));
        ExportCellOps.cell(sheet, row, 2, itemTitle, ExcelStyles.cellStyle(zebra: i.isOdd, wrap: true, align: HorizontalAlign.Left));
        ExportCellOps.cell(sheet, row, 3, s.done ? '☑' : '☐', ExcelStyles.cellStyle(zebra: i.isOdd, done: s.done, align: HorizontalAlign.Center));
        ExportCellOps.cell(sheet, row, 4, s.value, ExcelStyles.cellStyle(zebra: i.isOdd));
        ExportCellOps.cell(sheet, row, 5, s.notes, ExcelStyles.cellStyle(zebra: i.isOdd, wrap: true, align: HorizontalAlign.Left));
        sheet.setRowHeight(row, 22);
        row++;
      }
    });

    // Footer
    row++;
    ExportCellOps.merged(sheet, row, 0, 5, 'Generated ${_fmtDate(DateTime.now())}', ExcelStyles.footerStyle());

    return book;
  }

  static String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final l = d.toLocal();
    return '${l.year}-${two(l.month)}-${two(l.day)} ${two(l.hour)}:${two(l.minute)}';
  }
}