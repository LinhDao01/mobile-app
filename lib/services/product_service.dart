import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

import '../models/product.dart';
import 'pocketbase_client.dart';

class ProductService {
  String _getFeaturedImageUrl(PocketBase pb, RecordModel productModel) {
    final featuredImageName = productModel.getStringValue('featuredImage');
    return pb.files.getURL(productModel, featuredImageName).toString();
  }

  Future<Product?> addProduct(Product product) async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.record!.id;

      final productModel = await pb.collection('products').create(body: {
        ...product.toJson(),
        'userId': userId,
      }, files: [
        http.MultipartFile.fromBytes(
          'featuredImage',
          await product.featuredImage!.readAsBytes(),
          filename: product.featuredImage!.uri.pathSegments.last,
        ),
      ]);

      return product.copyWith(
        id: productModel.id,
        imageUrl: _getFeaturedImageUrl(pb, productModel),
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<Product>> fetchProducts({bool filteredByUser = false}) async {
    final List<Product> products = [];
    try {
      final pb = await getPocketbaseInstance();

      // Kiểm tra nếu chưa đăng nhập
      final userId = pb.authStore.record?.id;
      if (filteredByUser && userId == null) {
        throw Exception("User not logged in yet!");
      }

      // Lấy danh sách sản phẩm
      final filterQuery = filteredByUser ? "userId = '$userId'" : null;
      final productModels =
          await pb.collection('products').getFullList(filter: filterQuery);

      for (final productModel in productModels) {
        products.add(
          Product.fromJson(
            productModel.toJson()
              ..addAll(
                  {'imageUrl': _getFeaturedImageUrl(pb, productModel) ?? ''}),
          ),
        );
      }

      return products;
    } catch (e) {
      print("Error when fetch products: $e");
      return [];
    }
  }

  Future<Product?> updateProduct(Product product) async {
    try {
      final pb = await getPocketbaseInstance();
      final productModel = await pb.collection('products').update(
            product.id!,
            body: product.toJson(),
            files: product.featuredImage != null
                ? [
                    http.MultipartFile.fromBytes(
                      'featuredImage',
                      await product.featuredImage!.readAsBytes(),
                      filename: product.featuredImage!.uri.pathSegments.last,
                    ),
                  ]
                : [],
          );

      return product.copyWith(
        imageUrl: product.featuredImage != null
            ? _getFeaturedImageUrl(pb, productModel)
            : product.imageUrl,
      );
    } catch (e) {
      print("Error when get product list: $e");
      return null;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      final pb = await getPocketbaseInstance();
      await pb.collection('products').delete(id);
      return true;
    } catch (e) {
      print("Error when delete product: $e");
      return false;
    }
  }
}
