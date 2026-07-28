import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../records/service_record.dart';

enum ItemStatus { yes, no }

class ChecklistItem {
  final String item;
  final ItemStatus status;
  final String value;
  final String notes;
  const ChecklistItem({required this.item, required this.status, this.value = '', this.notes = ''});
}

class VehicleServiceRecordPdf {
  VehicleServiceRecordPdf._();

  static final PdfColor _navy = PdfColor.fromHex('#1F2A44');
  static final PdfColor _steel = PdfColor.fromHex('#3D5A80');
  static final PdfColor _lightGrey = PdfColor.fromHex('#F2F4F7');
  static final PdfColor _midGrey = PdfColor.fromHex('#D8DCE3');
  static final PdfColor _textGrey = PdfColor.fromHex('#333333');
  static final PdfColor _green = PdfColor.fromHex('#1E7B34');
  static final PdfColor _red = PdfColor.fromHex('#B3261E');

  static Future<Uint8List> generate(ServiceRecord r) async {
    final doc = pw.Document(title: 'Vehicle Service Record - Vehicle ${r.vehicleNumber}');
    final baseStyle = pw.TextStyle(fontSize: 9.5, color: _textGrey);
    final boldStyle = baseStyle.copyWith(fontWeight: pw.FontWeight.bold);
    final serviceDate = DateTime.tryParse(r.dateStarted) ?? DateTime.now();
    final items = r.steps.map((s) => ChecklistItem(
      item: s.title,
      status: s.done ? ItemStatus.yes : ItemStatus.no,
      value: s.value,
      notes: s.notes,
    )).toList();
    final nextSteps = r.nextSteps.split('\n').where((s) => s.trim().isNotEmpty).toList();

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.fromLTRB(47, 43, 47, 50),
      header: (context) {
        if (context.pageNumber != 1) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 6),
            decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _midGrey))),
            child: pw.Text('Vehicle Service Record  •  Vehicle ${r.vehicleNumber}',
              style: pw.TextStyle(fontSize: 9, color: _steel, fontWeight: pw.FontWeight.bold)),
          );
        }
        return pw.SizedBox();
      },
      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 8),
        child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(fontSize: 8, color: _midGrey)),
      ),
      build: (context) => [
        _titleBlock(),
        pw.SizedBox(height: 4),
        pw.Divider(thickness: 1.4, color: _steel),
        pw.SizedBox(height: 10),
        _infoTable(r, serviceDate, baseStyle, boldStyle),
        pw.SizedBox(height: 18),
        _sectionHeader('Inspection Checklist'),
        _checklistTable(items, baseStyle),
        if (nextSteps.isNotEmpty) ...[
          pw.SizedBox(height: 20),
          _sectionHeader('Next Steps'),
          pw.Divider(thickness: 0.75, color: _midGrey),
          pw.SizedBox(height: 6),
          ...nextSteps.map((step) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Bullet(text: step, style: pw.TextStyle(fontSize: 10, color: _textGrey), bulletColor: _steel),
          )),
        ],
        if (r.notes.isNotEmpty) ...[
          pw.SizedBox(height: 20),
          _sectionHeader('Notes'),
          pw.Divider(thickness: 0.75, color: _midGrey),
          pw.SizedBox(height: 6),
          pw.Text(r.notes, style: pw.TextStyle(fontSize: 10, color: _textGrey)),
        ],
      ],
    ));
    return doc.save();
  }

  static pw.Widget _titleBlock() => pw.Text('Vehicle Service Record',
    style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: _navy));

  static pw.Widget _sectionHeader(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Text(text, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _navy)),
  );

  static pw.Widget _infoTable(ServiceRecord r, DateTime serviceDate, pw.TextStyle baseStyle, pw.TextStyle boldStyle) {
    pw.Widget label(String s) => pw.Text(s, style: boldStyle);
    pw.Widget value(String s) => pw.Text(s, style: baseStyle);
    final workers = r.workerNames.join(', ');
    final rows = <List<pw.Widget>>[
      [label('Technician'), value(r.technician.name), label('Vehicle #'), value(r.vehicleNumber)],
      [label('Phone'), value(r.technician.phone), label('Service Date'), value(_formatDate(serviceDate))],
      [label('Email'), value(r.technician.email), label('Service Type'), value(r.serviceType)],
      [label('Mileage'), value('${_formatNumber(r.miles ?? 0)} mi'), label('Engine Hours'), value('${_formatNumber(r.hours ?? 0)} hrs')],
      if (workers.isNotEmpty) [label('Workers'), value(workers), label(''), value('')],
    ];
    return pw.Table(
      columnWidths: const {
        0: pw.FlexColumnWidth(1.0), 1: pw.FlexColumnWidth(2.3),
        2: pw.FlexColumnWidth(1.1), 3: pw.FlexColumnWidth(2.1),
      },
      children: rows.map((r) => pw.TableRow(
        decoration: pw.BoxDecoration(
          color: _lightGrey,
          border: pw.Border(bottom: pw.BorderSide(color: _midGrey, width: 0.5)),
        ),
        children: r.map((w) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5), child: w,
        )).toList(),
      )).toList(),
    );
  }

  static pw.Widget _checklistTable(List<ChecklistItem> items, pw.TextStyle baseStyle) {
    pw.Widget headerCell(String s) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: pw.Text(s, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
    );
    pw.Widget cell(pw.Widget child) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6), child: child,
    );

    final headerRow = pw.TableRow(
      decoration: pw.BoxDecoration(color: _navy),
      children: [headerCell('Item'), headerCell('Status'), headerCell('Value'), headerCell('Notes')],
    );

    final dataRows = <pw.TableRow>[];
    for (var i = 0; i < items.length; i++) {
      final it = items[i];
      dataRows.add(pw.TableRow(
        decoration: pw.BoxDecoration(
          color: i.isEven ? _lightGrey : PdfColors.white,
          border: pw.Border(
            bottom: pw.BorderSide(
              color: i == items.length - 1 ? _steel : _midGrey,
              width: i == items.length - 1 ? 0.75 : 0.5,
            ),
          ),
        ),
        children: [
          cell(pw.Text(it.item, style: baseStyle)),
          cell(_statusPill(it.status)),
          cell(pw.Text(it.value, style: baseStyle)),
          cell(pw.Text(it.notes, style: baseStyle)),
        ],
      ));
    }

    return pw.Table(
      border: pw.TableBorder.all(color: _steel, width: 0.75),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.35), 1: pw.FlexColumnWidth(0.85),
        2: pw.FlexColumnWidth(1.35), 3: pw.FlexColumnWidth(3.0),
      },
      children: [headerRow, ...dataRows],
    );
  }

  static pw.Widget _statusPill(ItemStatus status) {
    switch (status) {
      case ItemStatus.yes:
        return pw.Text('Done', style: pw.TextStyle(fontSize: 9.5, color: _green, fontWeight: pw.FontWeight.bold));
      case ItemStatus.no:
        return pw.Text('', style: pw.TextStyle(fontSize: 9.5, color: _red));
    }
  }

  static String _formatDate(DateTime d) {
    const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  static String _formatNumber(num n) {
    final s = n.toInt().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
