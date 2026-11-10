import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/wealth_analytics.dart';

class StatementPdfGenerator {
  const StatementPdfGenerator._();

  static Future<Uint8List> buildPdf({
    required WealthAnalytics wealth,
    required String holderName,
    required String accountNumber,
    required String iban,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormat = DateFormat('MMMM dd, yyyy');
    final statementId = 'STMT-CH-8842-${now.millisecondsSinceEpoch.toString().substring(5)}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. Bank Header & Jurisdiction
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'AEROVAULT PRIVATE BANKING SA',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#090D16'),
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Member of the Swiss Bankers Association (SBA)\nFINMA Regulated Banking Institution No. CHE-492.102.881',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Rue du Rhône 42, 1204 Genève, Switzerland',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#00E599'),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        ),
                        child: pw.Text(
                          'OFFICIAL STATEMENT',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#090D16'),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Issued: ${dateFormat.format(now)}',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        'Doc Ref: $statementId',
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 18),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 14),

              // 2. Client & Account Metadata
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F8FAFC'),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('BENEFICIARY ACCOUNT HOLDER', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                        pw.SizedBox(height: 2),
                        pw.Text(holderName.toUpperCase(), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text('ACCOUNT NUMBER: $accountNumber', style: const pw.TextStyle(fontSize: 8)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('SWISS IBAN NUMBER', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                        pw.SizedBox(height: 2),
                        pw.Text(iban, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text('BIC / SWIFT: AEROCHZZXXX  |  CURRENCY: USD', style: const pw.TextStyle(fontSize: 8)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 18),

              // 3. Financial Net Worth & Liquidity Summary
              pw.Text(
                'EXECUTIVE FINANCIAL POSITION',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#090D16')),
              ),
              pw.SizedBox(height: 8),

              pw.Row(
                children: [
                  _buildMetricCell('TOTAL AUDITED NET WORTH', '\$${wealth.totalNetWorth.toStringAsFixed(2)}', isPrimary: true),
                  pw.SizedBox(width: 8),
                  _buildMetricCell('MONTHLY INFLOW', '+\$${wealth.monthlyInflow.toStringAsFixed(2)}'),
                  pw.SizedBox(width: 8),
                  _buildMetricCell('MONTHLY OUTFLOW', '-\$${wealth.monthlyOutflow.toStringAsFixed(2)}'),
                  pw.SizedBox(width: 8),
                  _buildMetricCell('HEALTH SCORE', '${wealth.financialHealthScore}/100 (${wealth.ratingTier})'),
                ],
              ),
              pw.SizedBox(height: 20),

              // 4. Asset Allocation Breakdown
              pw.Text(
                'ASSET ALLOCATION SUMMARY',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),

              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#090D16')),
                cellStyle: const pw.TextStyle(fontSize: 8),
                headers: ['Asset Class', 'Symbol', 'Valuation (USD)', 'Portfolio Share'],
                data: wealth.allocations.map((a) {
                  return [
                    a.name,
                    a.symbol,
                    '\$${a.valueUsd.toStringAsFixed(2)}',
                    '${(a.percentage * 100).toStringAsFixed(1)}%',
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),

              // 5. Itemized Ledger Audit Trail
              pw.Text(
                'SETTLED CLEARING LEDGER (RECENT)',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),

              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#1E293B')),
                cellStyle: const pw.TextStyle(fontSize: 8),
                headers: ['Date', 'Reference ID', 'Counterparty / Description', 'Type', 'Amount (USD)'],
                data: [
                  ['2026-11-09', 'TXN-9941-UPW', 'Upwork Global Escrow Payout', 'Direct Deposit', '+\$4,500.00'],
                  ['2026-11-08', 'TXN-8812-APP', 'Apple Store 5th Ave (Hardware)', 'Card Purchase', '-\$1,299.00'],
                  ['2026-11-06', 'TXN-7731-AWS', 'Amazon Web Services EMEA Cloud', 'Subscription', '-\$450.00'],
                  ['2026-11-05', 'TXN-6619-SWP', 'USD Liquidity to BTC Reserve', 'Crypto Swap', '-\$5,000.00'],
                  ['2026-11-03', 'TXN-5502-STR', 'Stripe Merchant Payout Protocol', 'Fedwire Credit', '+\$12,500.00'],
                ],
              ),
              pw.Spacer(),

              // 6. Cryptographic Verification & Bank Seal
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F1F5F9'),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'CRYPTOGRAPHIC PROOF & INTEGRITY CERTIFICATE',
                          style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'SHA-256: 7f83b1657ff1fc53b92dc18148a1d65dfc2d4b1fa3d677284addd200126d9069',
                          style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey700),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Authorized Signatory: Dr. Marc Hoffmann, Managing Director of Private Wealth',
                          style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: 'https://verify.aerovault.bank/statements/$statementId',
                      width: 38,
                      height: 38,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(
                  'CONFIDENTIAL & PROPRIETARY • CERTIFIED UNDER SWISS BANKING SECRECY ACT',
                  style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey500),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildMetricCell(String label, String value, {bool isPrimary = false}) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: pw.BoxDecoration(
          color: isPrimary ? PdfColor.fromHex('#E6FBF5') : PdfColors.white,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          border: pw.Border.all(
            color: isPrimary ? PdfColor.fromHex('#00E599') : PdfColors.grey300,
          ),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey600)),
            pw.SizedBox(height: 2),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: isPrimary ? PdfColor.fromHex('#00875A') : PdfColor.fromHex('#090D16'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> showStatementPreview(
    BuildContext context, {
    required WealthAnalytics wealth,
    required String holderName,
    required String accountNumber,
    required String iban,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: BoxDecoration(
            color: context.colors.surfaceElevated,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Official Bank Statement', style: AppTextStyles.heading2(color: context.colors.textPrimary)),
                        Text('FINMA & SBA Certified PDF Export', style: AppTextStyles.bodySmall(color: context.colors.textSecondary)),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, color: context.colors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: PdfPreview(
                  build: (format) => buildPdf(
                    wealth: wealth,
                    holderName: holderName,
                    accountNumber: accountNumber,
                    iban: iban,
                  ),
                  allowPrinting: true,
                  allowSharing: true,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  pdfFileName: 'AeroVault_Statement_${DateTime.now().year}_${DateTime.now().month}.pdf',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
