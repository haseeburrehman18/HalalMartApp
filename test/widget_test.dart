import 'package:flutter_test/flutter_test.dart';
import 'package:halal_verify/models/product_model.dart';

void main() {
  test('ProductModel calculates discounted pricing correctly', () {
    final product = ProductModel(
      id: 'test-product',
      sellerId: 'seller-1',
      sellerName: 'Test Shop',
      name: 'Test Product',
      slug: 'test-product',
      description: 'A product used for tests.',
      price: 100,
      discountPrice: 75,
      category: 'Snacks',
      imageUrl: '',
      certStatus: CertificationStatus.approved,
      createdAt: DateTime(2026),
    );

    expect(product.hasDiscount, isTrue);
    expect(product.finalPrice, 75);
    expect(product.discountPercent, 25);
    expect(product.formattedPrice, r'$75.00');
    expect(product.formattedOriginalPrice, r'$100.00');
  });
}
