import 'package:excel/excel.dart';

class ExcelStyles {
  static const _navy = '#1F3A5F';
  static const _onPrimary = '#FFFFFF';
  static const _accent = '#DCE6F2';
  static const _onAccent = '#1F3A5F';
  static const _labelFill = '#EEF2F7';
  static const _labelText = '#33415C';
  static const _zebra = '#F7F9FC';
  static const _white = '#FFFFFF';
  static const _border = '#C5CEDB';
  static const _doneGreen = '#2E7D32';
  static const _pendingText = '#8A94A6';

  static Border _thinBorder(String color) => Border(
    borderStyle: BorderStyle.Thin,
    borderColorHex: ExcelColor.fromHexString(color),
  );

  static CellStyle _base() => CellStyle(
    leftBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString(_border)),
    rightBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString(_border)),
    topBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString(_border)),
    bottomBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.fromHexString(_border)),
    fontFamily: 'Calibri',
  );

  static CellStyle headerStyle() => _base().copyWith(
    boldVal: true,
    fontColorHexVal: ExcelColor.fromHexString(_onPrimary),
    backgroundColorHexVal: ExcelColor.fromHexString(_navy),
    horizontalAlignVal: HorizontalAlign.Center,
    verticalAlignVal: VerticalAlign.Center,
  );

  static CellStyle labelStyle() => _base().copyWith(
    boldVal: true,
    fontColorHexVal: ExcelColor.fromHexString(_labelText),
    backgroundColorHexVal: ExcelColor.fromHexString(_labelFill),
    horizontalAlignVal: HorizontalAlign.Left,
    verticalAlignVal: VerticalAlign.Center,
  );

  static CellStyle valueStyle({bool zebra = false}) => _base().copyWith(
    backgroundColorHexVal: ExcelColor.fromHexString(zebra ? _zebra : _white),
    horizontalAlignVal: HorizontalAlign.Left,
    verticalAlignVal: VerticalAlign.Center,
    textWrappingVal: TextWrapping.WrapText,
  );

  static CellStyle checklistHeaderStyle() => headerStyle();

  static CellStyle cellStyle({
    bool zebra = false,
    bool done = false,
    bool bold = false,
    bool wrap = false,
    HorizontalAlign align = HorizontalAlign.Center,
  }) => _base().copyWith(
    boldVal: bold,
    fontColorHexVal: ExcelColor.fromHexString(done ? _doneGreen : '#1B1F27'),
    backgroundColorHexVal: ExcelColor.fromHexString(zebra ? _zebra : _white),
    horizontalAlignVal: align,
    verticalAlignVal: VerticalAlign.Center,
    textWrappingVal: wrap ? TextWrapping.WrapText : null,
  );

  static CellStyle groupBandStyle() => _base().copyWith(
    boldVal: true,
    fontColorHexVal: ExcelColor.fromHexString(_onAccent),
    backgroundColorHexVal: ExcelColor.fromHexString(_accent),
    horizontalAlignVal: HorizontalAlign.Left,
    verticalAlignVal: VerticalAlign.Center,
  );

  static CellStyle footerStyle() => CellStyle(
    fontColorHex: ExcelColor.fromHexString(_pendingText),
    fontSize: 9,
    italic: true,
    horizontalAlign: HorizontalAlign.Right,
  );
}