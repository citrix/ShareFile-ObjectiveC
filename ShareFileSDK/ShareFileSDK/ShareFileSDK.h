//--Config
#import "SFAConfig.h"
//--

//--ModelMapper
#import "SFAModelClassMapper.h"
//--

//--Credentials
#import "SFACredentialCache.h"
#import "SFAOAuth2Credential.h"
//--

//--SFIEntitiesAndModels
#import "SFIEntitiesAndModels.h"
//--

//-- FileSystem
#import "SFAFileInfo.h"
//--

//-- Transfers
#import "SFATransferProgress.h"
#import "SFAUploadResponse.h"
#import "SFAUploadSpecificationRequest.h"
//--

//-- Transfers/Downloaders
#import "SFADownloaderConfig.h"
#import "SFAAsyncFileDownloader.h"
//--

//-- Transfers/Uploaders
#import "SFAFileUploaderConfig.h"
#import "SFAUploaderBase.h"
#import "SFAAsyncUploaderBase.h"
//--

//-- Transfers/BackgroundTransfers
#import "SFABackgroundSessionManager.h"
#import "SFABackgroundSessionConfiguration.h"
#import "SFAURLSessionTaskRuntimeAssociationKeys.h"
#import "SFAURLSessionTaskHttpDelegate.h"
//--

//-- Logging
#import "SFALogLevel.h"
#import "SFALogger.h"
#import "SFADefaultLogger.h"
#import "SFALoggingProvider.h"
#import "SFAActionStopwatch.h"
//--

//-- Utils
// None is public
//--

//-- Events
#import "SFAEventHandlerResponse.h"
#import "SFAChangeDomainCallback.h"
#import "SFAErrorCallback.h"
//--

//-- Categories
#import "SFIItemsEntity+sfapi.h"
#import "NSString+sfapi.h"
#if TARGET_OS_IPHONE
#import "ALAsset+sfapi.h"
#endif
//

//--Security
#if ShareFile

#import "SFAZoneAuthentication.h"

#endif
//--

//--Security/Authentication
#import "SFAWebAuthenticationHelper.h"
#import "SFAAuthHandling.h"
#import "SFAuthenticationContext.h"
//--

//--Security/Authentication/OAuth2
#import "SFAOAuthResponse.h"
#import "SFAOAuthResponseBase.h"
#import "SFAOAuthError.h"
#import "SFAOAuthAuthorizationCode.h"
#import "SFAOAuthToken.h"
#import "SFAOAuth2AuthenticationHelper.h"
#import "SFAOAuthService.h"
//--

//--Requests
#import "SFAQuery.h"
#import "SFAODataParameter.h"
#import "SFAODataParameterCollection.h"
#import "SFAQueryBase.h"
#import "SFApiQuery.h"
#import "SFAHttpRequestResponseDataContainer.h"
#import "SFAHttpBodyDataProvider.h"

//--Requests/Filters
#import "SFAFilter.h"
#import "SFAEqualToFilter.h"
#import "SFAEndsWithFilter.h"
#import "SFASubstringFilter.h"
#import "SFATypeFilter.h"
//--

//--Requests/Providers
#import "SFAAsyncRequestProvider.h"
#import "SFABaseRequestProvider.h"
//--

//--Tasks
#import "SFATask.h"
#import "SFATransferTask.h"
#import "SFAHttpTaskExternal.h"
#import "SFADownloadTaskExternal.h"
#import "SFABackgroundUploadInitiationResponse.h"
//--

//--Errors
#import "SFAError.h"
#import "SFAAsyncOperationScheduledError.h"
#import "SFAWebAuthenticationError.h"
#import "SFAODataRequestError.h"
//--

//--Enum
#import "SFAEventHandlerResponseAction.h"
#import "SFAItemAlias.h"
//--

#import "SFAConfiguration.h"
#import "SFABaseAuthHandler.h"
#import "SFAClient.h"
