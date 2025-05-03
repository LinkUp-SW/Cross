// The internal and external endpoints

class InternalEndPoints {
  static String userId = "";
  static String email = "";
  static String profileUrl = "assets/images/profile.png";
  static String firstname = "You";
  static String lastname = "J";
  static const String socketUrl = 'http://10.0.2.2:3000';
}

class ExternalEndPoints {
  // static const baseUrl = 'https://api.linkup-egypt.tech/';
  static const baseUrl = 'http://10.0.2.2:3000/'; // for localhosting
  static const receivedConnectionInvitations =
      'api/v1/user/my-network/invitation-manager/received';
  static const sentConnectionInvitations =
      'api/v1/user/my-network/invitation-manager/sent';
  static const acceptConnectionInvitation = "api/v1/user/accept/:user_id";
  static const ignoreConnectionInvitation =
      'api/v1/user/my-network/invitation-manager/ignore/:user_id';
  static const withdrawConnectionInvitation =
      "api/v1/user/my-network/invitation-manager/withdraw/:user_id";
  static const connectionsAndFollowingsCounts =
      'api/v1/user/my-network/connections/count';
  static const connectionsList =
      'api/v1/user/my-network/invite-connect/connections/:user_id';
  static const removeConnection =
      'api/v1/user/my-network/connections/remove/:user_id';
  static const userId = 'api/v1/user/my-network/connections/count';
  static const followingsList =
      'api/v1/user/my-network/network-manager/following';
  static const unfollow = 'api/v1/user/unfollow/:user_id';
  static const addEducation = 'api/v1/user/add-education';
  static const connect = 'api/v1/user/connect/:user_id';
  static const peopleYouMayKnow = 'api/v1/user/people-you-may-know';
  static const peopleSearch = 'api/v1/search/users';

  static const getUserEducation = 'api/v1/user/profile/education/:user_id';
  static const getUserExperience = 'api/v1/user/profile/experience/:user_id';
  static const userProfileAbout = 'api/v1/user/profile/about/:user_id';
  static const getUserLicenses = 'api/v1/user/profile/licenses/:user_id';
  static const addLicense = 'api/v1/user/add-license';
  static const updateLicense = 'api/v1/user/update-license/:licenseId';
  static const deleteLicense = 'api/v1/user/delete-license/:licenseId';

  static const currentPlan = 'api/v1/user/subscription/status';
  static const subscriptionPaymentSession = 'api/v1/user/subscription/checkout';
  static const cancelPremiumSubscription = 'api/v1/user/subscription/cancel';
  static const resumePremiumSubscription = 'api/v1/user/subscription/resume';

  static const deleteChat = 'api/v1/conversations/:conversationId';
  static const blockmessaging = 'api/v1/user/block/:user_id';
  static const fetchChats = 'api/v1/conversations';
  static const startnewchat =
      'api/v1/conversations/start-conversation/:user2ID';
  static const gotospecificchat = 'api/v1/conversations/:conversationId';
  static const sendmessage =
      'api/v1/conversations/:conversationId/send-message';
  static const markread = 'api/v1/conversations/:conversationId/read';
  static const getallcounts = 'api/v1/conversation/unread-conversations';
  static const markunread = 'api/v1/conversations/:conversationId/unread';
}
