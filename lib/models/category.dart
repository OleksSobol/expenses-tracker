class Category {
  final int? id;
  final String name;
  final String icon; // just store an emoji/icon name
  final String color;

  Category({this.id, required this.name, required this.icon, required this.color});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: map['color'],
    );
  }
}
