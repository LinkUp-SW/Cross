// The internal and external endpoints

class InternalEndPoints {
  static String token = "";
}

class ExternalEndPoints {
  static const baseUrl = 'http://10.0.2.2:3000/api/v1/';
  static const receivedConnectionInvitations =
      'user/my-network/invitation-manager/received';
  static const sentConnectionInvitations =
      'user/my-network/invitation-manager/sent';
  static const acceptConnectionInvitation = "user/accept/:user_id";
  static const ignoreConnectionInvitation =
      "user/my-network/invitation-manager/ignore/:user_id";
  static const withdrawConnectionInvitation =
      "user/my-network/invitation-manager/withdraw/:user_id";
  static const connectionsCount = 'user/my-network/connections/count';
}
