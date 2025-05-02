// The internal and external endpoints

class InternalEndPoints {
  static String userId = "";
  static String email = "";
  static String profileUrl = "";
  static const String socketUrl = 'http://10.0.2.2:3000';
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
  static const deleteChat = 'api/v1/conversations/:conversationId';
  static const blockmessaging = 'api/v1/user/block/:user_id';
  static const fetchChats = 'api/v1/conversations';
  static const startnewchat = 'api/v1/conversations/start-conversation/:user2ID';
  static const gotospecificchat = 'api/v1/conversations/:conversationId';
  static const sendmessage = 'api/v1/conversations/:conversationId/send-message';
  static const markread = 'api/v1/conversations/:conversationId/read';
  static const getallcounts = 'api/v1/conversation/unread-conversations';
  static const markunread= 'api/v1/conversations/:conversationId/unread';
}
