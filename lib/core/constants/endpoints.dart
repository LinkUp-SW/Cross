// The internal and external endpoints

class InternalEndPoints {
  static String userId = "";
  static String email = "";
}

class ExternalEndPoints {
  static const baseUrl = 'http://10.0.2.2:3000/';
  static const receivedConnectionInvitations =
      'v1/user/my-network/invitation-manager/received';
  static const sentConnectionInvitations =
      'v1/user/my-network/invitation-manager/sent';
  static const acceptConnectionInvitation = "v1/user/accept/:user_id";
  static const ignoreConnectionInvitation =
      'v1/user/my-network/invitation-manager/ignore/:user_id';
  static const withdrawConnectionInvitation =
      "v1/user/my-network/invitation-manager/withdraw/:user_id";
  static const connectionsAndFollowingsCounts =
      'v1/user/my-network/connections/count';
  static const connectionsList =
      'v1/user/my-network/invite-connect/connections/:user_id';
  static const removeConnection =
      'v1/user/my-network/connections/remove/:user_id';
  static const userId = 'v1/user/my-network/connections/count';
  static const followingsList = 'v1/user/my-network/network-manager/following';
  static const unfollow = 'v1/user/unfollow/:user_id';

  static const addEducation = 'v1/user/profile/education/:user_id'; 

}
