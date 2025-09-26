import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.discountPercentage,
    required super.rating,
    required super.stock,
    required super.brand,
    required super.category,
    required super.thumbnail,
    required super.images,
    required super.tags,
    required super.sku,
    required super.weight,
    required super.dimensions,
    required super.warrantyInformation,
    required super.shippingInformation,
    required super.availabilityStatus,
    required super.reviews,
    required super.returnPolicy,
    required super.minimumOrderQuantity,
    required super.meta,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      print('DEBUG: ProductModel.fromJson - Parsing product with id: ${json['id']}');
      return ProductModel(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String,
        price: (json['price'] as num).toDouble(),
        discountPercentage: (json['discountPercentage'] as num).toDouble(),
        rating: (json['rating'] as num).toDouble(),
        stock: json['stock'] as int,
        brand: json['brand'] as String? ?? '',
        category: json['category'] as String? ?? '',
        thumbnail: json['thumbnail'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        sku: json['sku'] as String? ?? '',
        weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
        dimensions: json['dimensions'] != null 
            ? (() {
                try {
                  return DimensionsModel.fromJson(json['dimensions'] as Map<String, dynamic>);
                } catch (e) {
                  print('DEBUG: ProductModel.fromJson - Error parsing dimensions, using defaults: $e');
                  return const DimensionsModel(width: 0.0, height: 0.0, depth: 0.0);
                }
              })()
            : const DimensionsModel(width: 0.0, height: 0.0, depth: 0.0),
        warrantyInformation: json['warrantyInformation'] as String? ?? 'No warranty information available',
        shippingInformation: json['shippingInformation'] as String? ?? 'Standard shipping',
        availabilityStatus: json['availabilityStatus'] as String? ?? 'In Stock',
        reviews: json['reviews'] != null 
            ? (json['reviews'] as List<dynamic>)
                .map((review) {
                  try {
                    return ReviewModel.fromJson(review as Map<String, dynamic>);
                  } catch (e) {
                    print('DEBUG: ProductModel.fromJson - Error parsing review, skipping: $e');
                    return null;
                  }
                })
                .where((review) => review != null)
                .cast<ReviewModel>()
                .toList()
            : [],
        returnPolicy: json['returnPolicy'] as String? ?? '30-day return policy',
        minimumOrderQuantity: json['minimumOrderQuantity'] as int? ?? 1,
        meta: json['meta'] != null 
            ? (() {
                try {
                  return ProductMetaModel.fromJson(json['meta'] as Map<String, dynamic>);
                } catch (e) {
                  print('DEBUG: ProductModel.fromJson - Error parsing meta, using defaults: $e');
                  return ProductMetaModel(
                    createdAt: DateTime.now().toIso8601String(),
                    updatedAt: DateTime.now().toIso8601String(),
                    barcode: '',
                    qrCode: '',
                  );
                }
              })()
            : ProductMetaModel(
                createdAt: DateTime.now().toIso8601String(),
                updatedAt: DateTime.now().toIso8601String(),
                barcode: '',
                qrCode: '',
              ),
      );
    } catch (e, stackTrace) {
      print('DEBUG: ProductModel.fromJson - Error parsing product: $e');
      print('DEBUG: ProductModel.fromJson - Stack trace: $stackTrace');
      print('DEBUG: ProductModel.fromJson - JSON keys: ${json.keys.toList()}');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'category': category,
      'thumbnail': thumbnail,
      'images': images,
      'tags': tags,
      'sku': sku,
      'weight': weight,
      'dimensions': (dimensions as DimensionsModel).toJson(),
      'warrantyInformation': warrantyInformation,
      'shippingInformation': shippingInformation,
      'availabilityStatus': availabilityStatus,
      'reviews': (reviews as List<ReviewModel>).map((review) => review.toJson()).toList(),
      'returnPolicy': returnPolicy,
      'minimumOrderQuantity': minimumOrderQuantity,
      'meta': (meta as ProductMetaModel).toJson(),
    };
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      title: product.title,
      description: product.description,
      price: product.price,
      discountPercentage: product.discountPercentage,
      rating: product.rating,
      stock: product.stock,
      brand: product.brand,
      category: product.category,
      thumbnail: product.thumbnail,
      images: product.images,
      tags: product.tags,
      sku: product.sku,
      weight: product.weight,
      dimensions: product.dimensions,
      warrantyInformation: product.warrantyInformation,
      shippingInformation: product.shippingInformation,
      availabilityStatus: product.availabilityStatus,
      reviews: product.reviews,
      returnPolicy: product.returnPolicy,
      minimumOrderQuantity: product.minimumOrderQuantity,
      meta: product.meta,
    );
  }

  @override
  ProductModel copyWith({
    int? id,
    String? title,
    String? description,
    double? price,
    double? discountPercentage,
    double? rating,
    int? stock,
    String? brand,
    String? category,
    String? thumbnail,
    List<String>? images,
    List<String>? tags,
    String? sku,
    double? weight,
    Dimensions? dimensions,
    String? warrantyInformation,
    String? shippingInformation,
    String? availabilityStatus,
    List<Review>? reviews,
    String? returnPolicy,
    int? minimumOrderQuantity,
    ProductMeta? meta,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      rating: rating ?? this.rating,
      stock: stock ?? this.stock,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      thumbnail: thumbnail ?? this.thumbnail,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      sku: sku ?? this.sku,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      warrantyInformation: warrantyInformation ?? this.warrantyInformation,
      shippingInformation: shippingInformation ?? this.shippingInformation,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      reviews: reviews ?? this.reviews,
      returnPolicy: returnPolicy ?? this.returnPolicy,
      minimumOrderQuantity: minimumOrderQuantity ?? this.minimumOrderQuantity,
      meta: meta ?? this.meta,
    );
  }
}

class DimensionsModel extends Dimensions {
  const DimensionsModel({
    required super.width,
    required super.height,
    required super.depth,
  });

  factory DimensionsModel.fromJson(Map<String, dynamic> json) {
    try {
      return DimensionsModel(
        width: (json['width'] as num).toDouble(),
        height: (json['height'] as num).toDouble(),
        depth: (json['depth'] as num).toDouble(),
      );
    } catch (e) {
      print('DEBUG: DimensionsModel.fromJson - Error parsing dimensions: $e');
      print('DEBUG: DimensionsModel.fromJson - JSON keys: ${json.keys.toList()}');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'depth': depth,
    };
  }

  factory DimensionsModel.fromEntity(Dimensions dimensions) {
    return DimensionsModel(
      width: dimensions.width,
      height: dimensions.height,
      depth: dimensions.depth,
    );
  }

  @override
  DimensionsModel copyWith({
    double? width,
    double? height,
    double? depth,
  }) {
    return DimensionsModel(
      width: width ?? this.width,
      height: height ?? this.height,
      depth: depth ?? this.depth,
    );
  }
}

class ReviewModel extends Review {
  const ReviewModel({
    required super.rating,
    required super.comment,
    required super.date,
    required super.reviewerName,
    required super.reviewerEmail,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    try {
      return ReviewModel(
        rating: json['rating'] as int,
        comment: json['comment'] as String,
        date: json['date'] as String,
        reviewerName: json['reviewerName'] as String,
        reviewerEmail: json['reviewerEmail'] as String,
      );
    } catch (e) {
      print('DEBUG: ReviewModel.fromJson - Error parsing review: $e');
      print('DEBUG: ReviewModel.fromJson - JSON keys: ${json.keys.toList()}');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
      'date': date,
      'reviewerName': reviewerName,
      'reviewerEmail': reviewerEmail,
    };
  }

  factory ReviewModel.fromEntity(Review review) {
    return ReviewModel(
      rating: review.rating,
      comment: review.comment,
      date: review.date,
      reviewerName: review.reviewerName,
      reviewerEmail: review.reviewerEmail,
    );
  }

  @override
  ReviewModel copyWith({
    int? rating,
    String? comment,
    String? date,
    String? reviewerName,
    String? reviewerEmail,
  }) {
    return ReviewModel(
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      date: date ?? this.date,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewerEmail: reviewerEmail ?? this.reviewerEmail,
    );
  }
}

class ProductMetaModel extends ProductMeta {
  const ProductMetaModel({
    required super.createdAt,
    required super.updatedAt,
    required super.barcode,
    required super.qrCode,
  });

  factory ProductMetaModel.fromJson(Map<String, dynamic> json) {
    return ProductMetaModel(
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      barcode: json['barcode'] as String,
      qrCode: json['qrCode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'barcode': barcode,
      'qrCode': qrCode,
    };
  }

  factory ProductMetaModel.fromEntity(ProductMeta meta) {
    return ProductMetaModel(
      createdAt: meta.createdAt,
      updatedAt: meta.updatedAt,
      barcode: meta.barcode,
      qrCode: meta.qrCode,
    );
  }

  @override
  ProductMetaModel copyWith({
    String? createdAt,
    String? updatedAt,
    String? barcode,
    String? qrCode,
  }) {
    return ProductMetaModel(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      barcode: barcode ?? this.barcode,
      qrCode: qrCode ?? this.qrCode,
    );
  }
}
