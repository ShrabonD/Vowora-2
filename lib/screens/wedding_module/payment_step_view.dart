import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/vowora_theme.dart';
import '../../models/wedding_booking_model.dart';
import '../../providers/wedding_wizard_provider.dart';
import '../../widgets/vowora_payment_gateway_sheet.dart';

class PaymentStepView extends StatelessWidget {
  const PaymentStepView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeddingWizardProvider>(context);
    final booking = provider.booking;
    final payments = booking.paymentHistory;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step 12: Payment & Receipts 💳',
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Record advance payments & view official booking invoices.',
            style: GoogleFonts.plusJakartaSans(
              color: VoworaColors.champagneGold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),

          // Payment Overview Cards
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Estimated Cost:', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12)),
                    Text('৳${booking.totalEstimatedCost.toStringAsFixed(0)}', style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Paid So Far:', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF6FCFB0), fontSize: 12, fontWeight: FontWeight.bold)),
                    Text('৳${booking.totalPaidAmount.toStringAsFixed(0)}', style: GoogleFonts.playfairDisplay(color: const Color(0xFF6FCFB0), fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Divider(color: Colors.white.withValues(alpha: 0.15)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Remaining Balance:', style: GoogleFonts.plusJakartaSans(color: VoworaColors.champagneGold, fontSize: 13, fontWeight: FontWeight.bold)),
                    Text('৳${booking.remainingBalance.toStringAsFixed(0)}', style: GoogleFonts.playfairDisplay(color: VoworaColors.champagneGold, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Add Payment Button & History
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Payment History', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showAddPaymentModal(context, provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: VoworaColors.champagneGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Record Pay'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: payments.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final pay = payments[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pay.serviceName, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('${DateFormat('MMM dd, yyyy').format(pay.date)} • ${pay.paymentMethod}', style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 10.5)),
                      ],
                    ),
                    Text('৳${pay.amount.toStringAsFixed(0)}', style: GoogleFonts.playfairDisplay(color: const Color(0xFF6FCFB0), fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                provider.setStep(13); // Continue to Summary
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: VoworaColors.champagneGold,
                foregroundColor: const Color(0xFF141210),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              child: Text(
                'Continue to Summary',
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentModal(BuildContext context, WeddingWizardProvider provider) {
    final booking = provider.booking;
    VoworaPaymentGatewaySheet.show(
      context,
      payableAmount: booking.remainingBalance > 0 ? booking.remainingBalance : booking.totalEstimatedCost,
      serviceTitle: 'Wedding Package & Services Settlement',
      weddingId: booking.weddingId,
      onPaymentCompleted: (record) {
        provider.addPaymentRecord(record);
      },
    );
  }
}
