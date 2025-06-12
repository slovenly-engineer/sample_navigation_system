import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/router_provider.dart';
import '../models/product_model.dart';

class ProductPage extends ConsumerWidget {
  final String productId;
  final ProductModel? initialData;

  const ProductPage({
    super.key,
    required this.productId,
    this.initialData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.read(navigationServiceProvider);

    // Use initial data if provided, otherwise create dummy data
    final product = initialData ?? ProductModel(
      id: productId,
      name: 'Product $productId',
      description: 'This is a great product with amazing features.',
      price: 99.99,
      imageUrl: 'https://via.placeholder.com/300',
      stock: 10,
      category: 'Electronics',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => nav.showSnackBar('Share feature coming soon!'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.shopping_bag, size: 100, color: Colors.grey),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Category and Stock
                  Row(
                    children: [
                      Chip(
                        label: Text(product.category),
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${product.stock} in stock',
                        style: TextStyle(
                          color: product.stock > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  
                  // Actions
                  if (product.stock > 0)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final confirmed = await nav.showConfirmDialog(
                            title: 'Add to Cart',
                            message: 'Add ${product.name} to your cart?',
                            confirmButtonText: 'Add',
                          );
                          
                          if (confirmed == true) {
                            nav.showSnackBar(
                              'Added to cart!',
                              action: SnackBarAction(
                                label: 'View Cart',
                                onPressed: () => nav.showSnackBar('Cart feature coming soon!'),
                              ),
                            );
                            
                            // Return the product data when popping
                            nav.pop(product);
                          }
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Add to Cart'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Out of Stock',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}