import 'package:bazzone_driver/features/home/domain/entities/order_status.dart';

export 'order_status.dart' show OrderStatus, ActiveOrderPhase;

class Order {
  const Order({
    required this.id,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.price,
    required this.description,
    required this.distanceToClientKm,
    required this.distanceToPointKm,
    required this.customerRating,
    required this.customerName,
    required this.status,
    this.customerAvatarUrl,
    this.commentTags = const [],
    this.activePhase = ActiveOrderPhase.headingToClient,
    this.offerTimeoutSeconds = 20,
  });

  final String id;
  final String pickupAddress;
  final String destinationAddress;
  final String price;
  final String description;
  final double distanceToClientKm;
  final double distanceToPointKm;
  final double customerRating;
  final String customerName;
  final String? customerAvatarUrl;
  final List<String> commentTags;
  final OrderStatus status;
  final ActiveOrderPhase activePhase;
  final int offerTimeoutSeconds;

  bool get isOffer => status == OrderStatus.offered;
  bool get isActive => status == OrderStatus.active;

  Order copyWith({
    OrderStatus? status,
    ActiveOrderPhase? activePhase,
    int? offerTimeoutSeconds,
  }) {
    return Order(
      id: id,
      pickupAddress: pickupAddress,
      destinationAddress: destinationAddress,
      price: price,
      description: description,
      distanceToClientKm: distanceToClientKm,
      distanceToPointKm: distanceToPointKm,
      customerRating: customerRating,
      customerName: customerName,
      customerAvatarUrl: customerAvatarUrl,
      commentTags: commentTags,
      status: status ?? this.status,
      activePhase: activePhase ?? this.activePhase,
      offerTimeoutSeconds: offerTimeoutSeconds ?? this.offerTimeoutSeconds,
    );
  }

  static const mockOffer = Order(
    id: 'order-001',
    pickupAddress: 'Горький 1/2',
    destinationAddress: 'Логвиненко 10',
    price: '250 с',
    description:
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
        'Sed do eiusmod tempor incididunt ut labore.',
    distanceToClientKm: 0.7,
    distanceToPointKm: 4,
    customerRating: 4.7,
    customerName: 'Таңсулуу',
    customerAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&fit=crop',
    status: OrderStatus.offered,
    commentTags: ['С ребенком', 'Нужна помощь', 'Перевоз животных'],
  );
}
