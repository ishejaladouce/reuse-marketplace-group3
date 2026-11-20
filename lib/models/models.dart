enum OrderStatus { paidHeld, inTransit, delivered, completed }

class Conversation {
  final String id, name, item, lastMessage, time;
  final int unread;
  final bool buying; // true = I'm the buyer, false = I'm the seller
  const Conversation(this.id, this.name, this.item, this.lastMessage, this.time,
      {this.unread = 0, this.buying = true});
}

class ChatMessage {
  final String text, time;
  final bool mine;
  const ChatMessage(this.text, this.time, {this.mine = false});
}

class Order {
  final String id, item, counterparty, date;
  final int price; // RWF
  final bool isPurchase;
  OrderStatus status;
  bool reviewed;
  Order(this.id, this.item, this.counterparty, this.date, this.price,
      {required this.isPurchase, required this.status, this.reviewed = false});
}

enum NotificationKind { match, priceDrop, payment, message, interest, sold }

class AppNotification {
  final NotificationKind kind;
  final String title, body, time;
  bool unread;
  AppNotification(this.kind, this.title, this.body, this.time, {this.unread = false});
}

class LookingForPost {
  final String author, item, category, location, condition, time;
  final int budget; // RWF
  final int replies;
  const LookingForPost(this.author, this.item, this.category, this.budget,
      this.location, this.condition, this.time, this.replies);
}

String rwf(int amount) {
  final s = amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
  return '$s RWF';
}
