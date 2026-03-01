import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:worshippro/models/liturgy.dart';
import 'package:worshippro/models/liturgy_block.dart';
import 'package:worshippro/models/block_type.dart';

/// Servicio para generar y compartir PDFs de liturgias
class PdfService {
  /// Genera un PDF para una liturgia y devuelve el archivo
  static Future<File> generateLiturgyPdf(Liturgy liturgy) async {
    final pdf = pw.Document();

    final dateStr = DateFormat('EEEE, d MMMM yyyy', 'es_ES').format(liturgy.fecha);
    final timeStr = liturgy.hora;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(liturgy, dateStr, timeStr),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.SizedBox(height: 10),
          if (liturgy.descripcion != null && liturgy.descripcion!.isNotEmpty)
            _buildDescription(liturgy.descripcion!),
          if (liturgy.bloques.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            _buildSummaryBar(liturgy),
            pw.SizedBox(height: 20),
            ...liturgy.bloques.asMap().entries.map(
              (entry) => _buildBlockCard(entry.key + 1, entry.value),
            ),
          ] else
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 40),
              child: pw.Center(
                child: pw.Text(
                  'Este culto no tiene bloques definidos.',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey600,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final sanitizedTitle = liturgy.titulo
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    final file = File('${dir.path}/culto_$sanitizedTitle.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  /// Comparte el PDF usando el sheet nativo del dispositivo
  static Future<void> sharePdf(Liturgy liturgy) async {
    final file = await generateLiturgyPdf(liturgy);
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: liturgy.titulo,
      text: 'Orden del culto: ${liturgy.titulo}',
    );
  }

  /// Guarda el PDF usando un diálogo para que el usuario elija la ubicación
  static Future<String?> savePdf(Liturgy liturgy) async {
    final file = await generateLiturgyPdf(liturgy);
    final sanitizedTitle = liturgy.titulo
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    
    final params = SaveFileDialogParams(
      sourceFilePath: file.path,
      fileName: 'culto_$sanitizedTitle.pdf',
    );
    
    final filePath = await FlutterFileDialog.saveFile(params: params);
    return filePath;
  }

  // ── Componentes del PDF ──

  static pw.Widget _buildHeader(Liturgy liturgy, String dateStr, String? timeStr) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 6,
              height: 50,
              decoration: const pw.BoxDecoration(
                color: PdfColors.orange,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(3)),
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    liturgy.titulo,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    timeStr != null ? '$dateStr · $timeStr' : dateStr,
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(color: PdfColors.grey300, thickness: 1),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Generado con WorshipPro',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
        ),
        pw.Text(
          'Página ${context.pageNumber} de ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
        ),
      ],
    );
  }

  static pw.Widget _buildDescription(String descripcion) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.amber50,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.amber200),
      ),
      child: pw.Text(
        descripcion,
        style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800),
      ),
    );
  }

  static pw.Widget _buildSummaryBar(Liturgy liturgy) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _summaryItem('Bloques', '${liturgy.bloques.length}'),
          _summaryItem('Duración total', liturgy.duracionTotalFormateada),
        ],
      ),
    );
  }

  static pw.Widget _summaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
  }

  static pw.Widget _buildBlockCard(int index, LiturgyBlock block) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Encabezado del bloque
          pw.Row(
            children: [
              pw.Container(
                width: 28,
                height: 28,
                decoration: pw.BoxDecoration(
                  color: _blockColor(block.tipo),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Center(
                  child: pw.Text(
                    '$index',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Text(
                  block.tipo.displayName,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: pw.BoxDecoration(
                  color: PdfColors.orange50,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Text(
                  '${block.duracionMinutos} min',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.orange900,
                  ),
                ),
              ),
            ],
          ),
          // Descripción
          if (block.descripcion != null && block.descripcion!.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Text(
              block.descripcion!,
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
            ),
          ],
          // Responsables
          if (block.responsables.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Row(
              children: [
                pw.Text(
                  'Responsables: ',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    block.responsables.join(', '),
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                ),
              ],
            ),
          ],
          // Canciones (para bloques de adoración)
          if (block.isAdoracion && block.canciones.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Canciones:',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey600,
              ),
            ),
            pw.SizedBox(height: 4),
            ...block.canciones.map(
              (song) => pw.Padding(
                padding: const pw.EdgeInsets.only(left: 12, bottom: 3),
                child: pw.Row(
                  children: [
                    pw.Text('♪ ', style: const pw.TextStyle(fontSize: 10)),
                    pw.Expanded(
                      child: pw.Text(
                        song.tono != null
                            ? '${song.nombre} (${song.tono})'
                            : song.nombre,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          // Comentarios
          if (block.comentarios != null && block.comentarios!.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColors.yellow50,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Nota: ',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      block.comentarios!,
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Color según tipo de bloque
  static PdfColor _blockColor(BlockType tipo) {
    switch (tipo) {
      case BlockType.adoracionAlabanza:
        return PdfColors.purple;
      case BlockType.oracion:
        return PdfColors.blue;
      case BlockType.lecturaBiblica:
        return PdfColors.teal;
      case BlockType.reflexion:
        return PdfColors.indigo;
      case BlockType.accionGracias:
        return PdfColors.green;
      case BlockType.ofrendas:
        return PdfColors.amber;
      case BlockType.anuncios:
        return PdfColors.orange;
      case BlockType.saludos:
        return PdfColors.cyan;
      case BlockType.despedida:
        return PdfColors.pink;
      case BlockType.otros:
        return PdfColors.grey;
    }
  }
}
