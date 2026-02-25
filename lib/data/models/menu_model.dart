import 'package:equatable/equatable.dart';

class MenuCategoryModel extends Equatable {
  const MenuCategoryModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.sortOrder = 0,
  });

  final String id;
  final String restaurantId;
  final String name;
  final int sortOrder;

  factory MenuCategoryModel.fromJson(Map<String, dynamic> json) {
    return MenuCategoryModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      name: json['name'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'sort_order': sortOrder,
    };
  }

  @override
  List<Object?> get props => [id, restaurantId, name, sortOrder];
}

class MenuItemModel extends Equatable {
  const MenuItemModel({
    required this.id,
    required this.categoryId,
    required this.restaurantId,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    this.isAvailable = true,
  });

  final String id;
  final String categoryId;
  final String restaurantId;
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;
  final bool isAvailable;

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      restaurantId: json['restaurant_id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'restaurant_id': restaurantId,
      'name': name,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'is_available': isAvailable,
    };
  }

  @override
  List<Object?> get props => [
        id, categoryId, restaurantId, name, price, 
        description, imageUrl, isAvailable
      ];
}
