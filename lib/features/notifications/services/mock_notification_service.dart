import 'notification_service.dart';
import '../model/notification_model.dart';

class MockNotificationService extends NotificationService {
  @override
  Future<List<NotificationModel>> fetchNotifications() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      NotificationModel(
        type: NotificationFilter.posts,
        id: '1',
        profilePic: 'https://via.placeholder.com/150',
        name: 'John Doe',
        message: 'liked your post.',
        time: '2h ago',
        isRead: false,
      ),
      NotificationModel(
        type: NotificationFilter.posts,
        id: '2',
        profilePic: 'https://via.placeholder.com/150',
        name: 'Jane Smith',
        message: 'commented on your post.',
        time: '5h ago',
        isRead: true,
      ),
      NotificationModel(
        type: NotificationFilter.all,
        id: '3',
        profilePic: 'https://via.placeholder.com/150',
        name: 'Alice Brown',
        message: 'sent you a connection request.',
        time: '1d ago',
        isRead: false,
      ),
      NotificationModel(
        type: NotificationFilter.jobs,
        id: '4',
        profilePic: 'https://via.placeholder.com/150',
        name: 'Bob Johnson',
        message: 'shared a job posting with you.',
        time: '3d ago',
        isRead: true,
      ),
      NotificationModel(
        type: NotificationFilter.all,
        id: '5',
        profilePic: 'https://via.placeholder.com/150',
        name: 'Charlie White',
        message: 'sent you a message.',
        time: '30m ago',
        isRead: false,
      ),
      NotificationModel(
        type: NotificationFilter.mentions,
        id: '6',
        profilePic: 'https://via.placeholder.com/150',
        name: 'David Green',
        message: 'mentioned you in a comment.',
        time: '10m ago',
        isRead: false,
      ),
      NotificationModel(
        type: NotificationFilter.jobs,
        id: '7',
        profilePic: 'https://via.placeholder.com/150',
        name: 'Emma Wilson',
        message: 'applied for a job you posted.',
        time: '6h ago',
        isRead: true,
      ),
      NotificationModel(
        type: NotificationFilter.all,
        id: '8',
        profilePic: 'https://via.placeholder.com/150',
        name: 'Frank Taylor',
        message: 'accepted your connection request.',
        time: '2d ago',
        isRead: true,
      ),
      NotificationModel(
        type: NotificationFilter.all,
        id: '9',
        profilePic: 'https://via.placeholder.com/150',
        name: 'Grace Miller',
        message: 'replied to your message.',
        time: '15m ago',
        isRead: false,
      ),
      NotificationModel(
        type: NotificationFilter.mentions,
        id: '10',
        profilePic: 'https://via.placeholder.com/150',
        name: 'Henry Brown',
        message: 'mentioned you in a post.',
        time: '5d ago',
        isRead: true,
      ),
    ];
  }
}
