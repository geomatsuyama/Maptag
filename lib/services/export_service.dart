import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../models/mapillary_image.dart';

class ExportService {
  Future<String> exportToJson(List<MapillaryImage> images, {String? filename}) async {
    try {
      final jsonData = images.map((img) => img.toJson()).toList();
      final jsonString = JsonEncoder.withIndent('  ').convert(jsonData);
      
      final directory = await getApplicationDocumentsDirectory();
      final fileName = filename ?? 'mapillary_export_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonString);
      return file.path;
    } catch (e) {
      throw Exception('Error exporting to JSON: $e');
    }
  }

  Future<String> exportToExcel(List<MapillaryImage> images, {String? filename}) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Mapillary Images'];

      // Add headers
      final headers = [
        'Image ID',
        'Latitude',
        'Longitude',
        'Altitude',
        'Compass Angle',
        'Captured At',
        'Sequence ID',
        'Creator Username',
        'Creator ID',
        'Image URL',
        'Thumbnail URL',
        'Camera Make',
        'Camera Model',
        'Width',
        'Height',
        'Is Panorama',
        'Organization ID',
      ];

      for (int col = 0; col < headers.length; col++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
            .value = TextCellValue(headers[col]);
      }

      // Add data rows
      for (int row = 0; row < images.length; row++) {
        final imageData = images[row].toExcelRow();
        int col = 0;
        
        for (var header in headers) {
          final value = imageData[header];
          final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1));
          
          if (value is num) {
            cell.value = DoubleCellValue(value.toDouble());
          } else if (value is bool) {
            cell.value = BoolCellValue(value);
          } else {
            cell.value = TextCellValue(value?.toString() ?? '');
          }
          
          col++;
        }
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName = filename ?? 'mapillary_export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('${directory.path}/$fileName');
      
      final excelBytes = excel.encode();
      if (excelBytes != null) {
        await file.writeAsBytes(excelBytes);
        return file.path;
      } else {
        throw Exception('Failed to encode Excel file');
      }
    } catch (e) {
      throw Exception('Error exporting to Excel: $e');
    }
  }

  Future<String> exportAnalysisResults(
    List<MapillaryImage> images,
    Map<String, String> analysisResults, {
    String? filename,
    bool asExcel = true,
  }) async {
    try {
      if (asExcel) {
        return await _exportAnalysisToExcel(images, analysisResults, filename: filename);
      } else {
        return await _exportAnalysisToJson(images, analysisResults, filename: filename);
      }
    } catch (e) {
      throw Exception('Error exporting analysis results: $e');
    }
  }

  Future<String> _exportAnalysisToJson(
    List<MapillaryImage> images,
    Map<String, String> analysisResults, {
    String? filename,
  }) async {
    final combinedData = images.map((img) {
      final imgJson = img.toJson();
      imgJson['ai_analysis'] = analysisResults[img.id] ?? 'No analysis available';
      return imgJson;
    }).toList();

    final jsonString = JsonEncoder.withIndent('  ').convert(combinedData);
    
    final directory = await getApplicationDocumentsDirectory();
    final fileName = filename ?? 'analysis_export_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${directory.path}/$fileName');
    
    await file.writeAsString(jsonString);
    return file.path;
  }

  Future<String> _exportAnalysisToExcel(
    List<MapillaryImage> images,
    Map<String, String> analysisResults, {
    String? filename,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Analysis Results'];

    // Headers
    final headers = [
      'Image ID',
      'Latitude',
      'Longitude',
      'Captured At',
      'Camera Make',
      'Camera Model',
      'AI Analysis Result',
      'Image URL',
    ];

    for (int col = 0; col < headers.length; col++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
          .value = TextCellValue(headers[col]);
    }

    // Data rows
    for (int row = 0; row < images.length; row++) {
      final img = images[row];
      final analysis = analysisResults[img.id] ?? 'No analysis available';
      
      final rowData = [
        img.id,
        img.latitude.toString(),
        img.longitude.toString(),
        img.capturedAt.toIso8601String(),
        img.cameraMake ?? '',
        img.cameraModel ?? '',
        analysis,
        img.imageUrl,
      ];

      for (int col = 0; col < rowData.length; col++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1))
            .value = TextCellValue(rowData[col]);
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    final fileName = filename ?? 'analysis_export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File('${directory.path}/$fileName');
    
    final excelBytes = excel.encode();
    if (excelBytes != null) {
      await file.writeAsBytes(excelBytes);
      return file.path;
    } else {
      throw Exception('Failed to encode Excel file');
    }
  }
}
