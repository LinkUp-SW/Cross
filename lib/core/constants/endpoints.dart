// The internal and external endpoints

class InternalEndPoints {
  static String userId = "";
  static String email = "";
  static String profileUrl = "";
}

class ExternalEndPoints {
  // static const baseUrl = 'https://api.linkup-app.tech/';
  //static const baseUrl = 'http://10.0.2.2:3000/'; // for localhosting
  static const baseUrl = 'http://127.0.0.1:3000/'; // for localhosting
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


}
