import 'package:excel/excel.dart';

class ExportCellOps {
  static void cell(Sheet s, int row, int col, String text, CellStyle style) {
    s.updateCell(
      CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
      TextCellValue(text),
      cellStyle: style,
    );
  }

  static void merged(Sheet s, int row, int c1, int c2, String text, CellStyle style) {
    for (var c = c1; c <= c2; c++) {
      s.updateCell(
        CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row),
        TextCellValue(c == c1 ? text : ''),
        cellStyle: style,
      );
    }
    if (c2 > c1) {
      s.merge(
        CellIndex.indexByColumnRow(columnIndex: c1, rowIndex: row),
        CellIndex.indexByColumnRow(columnIndex: c2, rowIndex: row),
        customValue: TextCellValue(text),
      );
    }
  }
}