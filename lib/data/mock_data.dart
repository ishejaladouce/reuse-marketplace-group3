import '../models/models.dart';

/// In-memory sample data. Replace with Firestore streams when the backend is wired up.
class MockData {
  static final conversations = <Conversation>[
    const Conversation('c1', 'Sarah M.', 'Oak dining table', 'Yes, it is in great condition.', '2m', unread: 2),
    const Conversation('c2', 'Jean K.', 'Linen lounge sofa', 'Would 70,000 RWF be okay?', '1h', unread: 1),
    const Conversation('c3', 'Aime U.', 'Wired working desk', 'Thanks for the extra photos.', 'Yesterday', buying: false),
    const Conversation('c4', 'David N.', 'iPhone 11, 128GB', 'Payment confirmed in Reuse.', 'Mon', buying: false),
  ];

  static final chats = <String, List<ChatMessage>>{
    'c1': const [
      ChatMessage('Hi Sarah, is the dining table still available?', '10:02', mine: true),
      ChatMessage('Yes, it is. It seats six.', '10:05'),
      ChatMessage('Could you share a photo of the legs?', '10:06', mine: true),
      ChatMessage('Yes, it is in great condition.', '10:08'),
    ],
  };

  static final orders = <Order>[
    Order('RM-1042', 'Oak dining table', 'Sarah M.', '17 Nov', 120000,
        isPurchase: true, status: OrderStatus.delivered),
    Order('RM-1038', 'Brown leggings', 'Aline T.', '12 Nov', 8000,
        isPurchase: true, status: OrderStatus.inTransit),
    Order('RM-1021', 'Study lamp', 'Eric B.', '02 Nov', 15000,
        isPurchase: true, status: OrderStatus.completed, reviewed: true),
    Order('RM-1040', 'iPhone 11, 128GB', 'David N.', '15 Nov', 240000,
        isPurchase: false, status: OrderStatus.paidHeld),
    Order('RM-1019', 'Wired working desk', 'Aime U.', '30 Oct', 45000,
        isPurchase: false, status: OrderStatus.completed),
  ];

  static final notifications = <AppNotification>[
    AppNotification(NotificationKind.match, 'New match found',
        'A listing matching your request has been added.', '5m', unread: true),
    AppNotification(NotificationKind.priceDrop, 'Price drop',
        'An item you saved is now cheaper.', '1h', unread: true),
    AppNotification(NotificationKind.payment, 'Payment successful',
        'Your payment is held until you confirm delivery.', '3h'),
    AppNotification(NotificationKind.message, 'New message',
        'Sarah sent you a message about Oak dining table.', '3h'),
    AppNotification(NotificationKind.interest, 'New buyer interest',
        'Someone is interested in your iPhone 11.', 'Yesterday'),
    AppNotification(NotificationKind.sold, 'Item sold',
        'Your Wired working desk was collected and the payment released.', 'Mon'),
  ];

  static final posts = <LookingForPost>[
    const LookingForPost('Queen R.', 'Brown leggings', 'Clothing', 30000, 'Kigali', 'Like new', '20m', 3),
    const LookingForPost('Prince N.', 'Used laptop, 8GB RAM', 'Electronics', 250000, 'Kimironko', 'Good', '2h', 5),
    const LookingForPost('Meghan K.', 'Study chair', 'Furniture', 25000, 'Remera', 'Good', '5h', 1),
    const LookingForPost('Annie U.', 'Hardcover novels', 'Books', 10000, 'Kigali', 'Fair', 'Yesterday', 0),
  ];
}
