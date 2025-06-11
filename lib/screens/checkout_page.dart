import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/navigation_service.dart';
import '../models/cart_item.dart';
import '../models/shipping_address.dart';
import '../models/payment_method.dart';
import '../routes/app_route.dart';

class CheckoutPage extends ConsumerWidget {
  final List<CartItem> items;
  final ShippingAddress address;
  final PaymentMethod paymentMethod;

  const CheckoutPage({
    super.key,
    required this.items,
    required this.address,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.read(navigationServiceProvider);

    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    final tax = subtotal * 0.08;
    final shipping = subtotal > 50 ? 0.0 : 5.99;
    final total = subtotal + tax + shipping;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ...items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.product.name} x${item.quantity}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                        ],
                      ),
                    )),
                    const Divider(height: 24),
                    _buildPriceRow('Subtotal', subtotal),
                    _buildPriceRow('Tax', tax),
                    _buildPriceRow('Shipping', shipping),
                    const Divider(height: 24),
                    _buildPriceRow(
                      'Total',
                      total,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Shipping Address
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Shipping Address',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextButton(
                          onPressed: () => nav.showSnackBar(
                            message: 'Change address feature coming soon!',
                          ),
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(address.fullName),
                    Text(address.formattedAddress),
                    Text(address.phoneNumber),
                  ],
                ),
              ),
            ),

            // Payment Method
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment Method',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextButton(
                          onPressed: () => nav.showSnackBar(
                            message: 'Change payment method feature coming soon!',
                          ),
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _getPaymentIcon(paymentMethod.type),
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(paymentMethod.displayText),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Place Order Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final confirmed = await nav.showConfirmDialog(
                      title: 'Confirm Order',
                      message: 'Place order for \$${total.toStringAsFixed(2)}?',
                      confirmText: 'Place Order',
                    );

                    if (confirmed == true) {
                      await nav.showAlert(
                        title: 'Order Placed!',
                        message: 'Your order has been successfully placed. '
                            'Order number: #${DateTime.now().millisecondsSinceEpoch}',
                        buttonText: 'OK',
                      );
                      
                      // Navigate back to home
                      nav.go(const Home());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: Text(
                    'Place Order - \$${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: style,
          ),
        ],
      ),
    );
  }

  IconData _getPaymentIcon(PaymentType type) {
    switch (type) {
      case PaymentType.creditCard:
      case PaymentType.debitCard:
        return Icons.credit_card;
      case PaymentType.paypal:
        return Icons.account_balance_wallet;
      case PaymentType.applePay:
        return Icons.apple;
      case PaymentType.googlePay:
        return Icons.g_mobiledata;
    }
  }
}