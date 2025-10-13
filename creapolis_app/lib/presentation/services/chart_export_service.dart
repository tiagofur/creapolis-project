import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Servicio para exportar gráficos de burndown/burnup
class ChartExportService {
  /// Captura el widget como imagen y la comparte
  static Future<void> exportAsImage(GlobalKey key, String chartName) async {
    try {
      final RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      // Capturar imagen con alta calidad
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Guardar temporalmente
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/chart_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // Compartir
      await Share.shareXFiles(
        [XFile(filePath)],
        text: '$chartName',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Guarda la imagen en el dispositivo
  static Future<String?> saveAsImage(GlobalKey key, String chartName) async {
    try {
      final RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Obtener directorio de documentos
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/chart_${chartName.replaceAll(' ', '_')}_$timestamp.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      return filePath;
    } catch (e) {
      rethrow;
    }
  }

  /// Exporta como PDF (simplificado - captura como imagen y la convierte)
  /// Para un PDF real con múltiples páginas, se necesitaría el paquete 'pdf'
  static Future<void> exportAsPDF(GlobalKey key, String chartName) async {
    try {
      // Por ahora, exportamos como imagen PNG
      // En una implementación completa, usaríamos el paquete 'pdf' para generar un PDF real
      await exportAsImage(key, chartName);
    } catch (e) {
      rethrow;
    }
  }
}
