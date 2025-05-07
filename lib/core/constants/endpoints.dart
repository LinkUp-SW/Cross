// The internal and external endpoints

class InternalEndPoints {
  static String userId = "";
  static String email = "";
  static String firstName = "";
  static String lastName = "";
  static String profileUrl = "";
  static String profileImage = "";
  static const String socketUrl = 'http://10.0.2.2:3000';
}

class ExternalEndPoints {
  //static const baseUrl = 'https://api.linkup-app.tech/';
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
  static const follow = 'api/v1/user/follow/:user_id';
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

  static const topJobs = 'api/v1/jobs/get-top-jobs';
  static const jobDetails = 'api/v1/jobs/get-job/:jobId';
  static const getJobs = 'api/v1/jobs/get-jobs';
  static const saveJob = 'api/v1/jobs/save-jobs/:jobId';
  static const unsaveJob = 'api/v1/jobs/unsave-jobs/:jobId';
  static const getSavedJobs = 'api/v1/jobs/get-saved-jobs';
  static const searchJobs = 'api/v1/jobs/search-jobs';
  static const applyForJob = 'api/v1/job-application/apply-for-job';
  static const createJobApplication =
      'api/v1/job-application/create-job-application/:job_id';
  static const getJobApplications =
      'api/v1/job-application/get-job-applications/:job_id';
  static const getAppliedJobs = 'api/v1/job-application/get-applied-jobs';
  static const updateJobApplicationStatus =
      'api/v1/job-application/update-job-application-status/:application_id';
      static const createCompanyProfile='api/v1/company/create-company-profile';
  static const getCompanyProfile='api/v1/company/get-company-all-view/:companyId';
  static const getJobsFromCompany = 'api/v1/company/get-jobs-from-company/:organization_id';
}
