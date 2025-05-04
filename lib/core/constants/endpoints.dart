// The internal and external endpoints

class InternalEndPoints {
  static String userId = "";
  static String email = "";
  static String profileUrl = "";
}

class ExternalEndPoints {
  //static const baseUrl = 'https://api.linkup-egypt.tech/';
  static const baseUrl = 'http://10.0.2.2:3000/'; // for localhosting
  static const receivedConnectionInvitations = 'api/v1/user/my-network/invitation-manager/received';
  static const sentConnectionInvitations = 'api/v1/user/my-network/invitation-manager/sent';
  static const acceptConnectionInvitation = "api/v1/user/accept/:user_id";
  static const ignoreConnectionInvitation = 'api/v1/user/my-network/invitation-manager/ignore/:user_id';
  static const withdrawConnectionInvitation = "api/v1/user/my-network/invitation-manager/withdraw/:user_id";
  static const connectionsAndFollowingsCounts = 'api/v1/user/my-network/connections/count';
  static const connectionsList = 'api/v1/user/my-network/invite-connect/connections/:user_id';
  static const removeConnection = 'api/v1/user/my-network/connections/remove/:user_id';
  static const userId = 'api/v1/user/my-network/connections/count';
  static const followingsList = 'api/v1/user/my-network/network-manager/following';
  static const unfollow = 'api/v1/user/unfollow/:user_id';
  static const getnotifiacations= 'api/v1/notifications/get-notifications';
  static const marknotificationasread=  'api/v1/notifications/:notificationId/read';
  static const getunreadnotifications= 'api/v1/notifications/unread-count';
}
