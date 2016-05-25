static NSString *const SFAJson = @"json";
static NSString *const SFAApiV3 = @"apiv3";
static NSString *const SFAGet = @"GET";
static NSString *const SFAPost = @"POST";

static NSString *const SFAIndex = @"index";
static NSString *const SFAByteOffset = @"byteOffset";
static NSString *const SFAHash = @"hash";

static NSString *const SFAErrorString = @"error";
static NSString *const SFAErrorMessage = @"errorMessage";
static NSString *const SFAErrorCode = @"errorCode";
static NSString *const SFAValue = @"value";
static NSString *const SFADisplayName = @"displayname";
static NSString *const SFAFileName = @"filename";
static NSString *const SFAId = @"id";
static NSString *const SFAMd5 = @"md5";
static NSString *const SFASize = @"size";
static NSString *const SFAUploadId = @"uploadid";

static NSString *const SFARetryCount = @"RetryCount";
static NSString *const SFAUpload = @"upload";
static NSString *const SFAContentDisposition = @"Content-Disposition: attachment; form-data;";
static NSString *const SFAContentTypeOctectStream = @"Content-Type: application/octet-stream\r\n";
static NSString *const SFAUploadFileName = @"name=\"File1\"; filename=";
static NSString *const SFAContentType = @"Content-Type";
static NSString *const SFAContentLength = @"Content-Length";
static NSString *const SFAMultiPartFormData = @"multipart/form-data; boundary=";
static NSString *const SFAUploadError = @"Unable to upload file.";
static NSString *const SFAFileReadError = @"Unable to read data from file.";

static NSString *const SFADownload = @"Download";
static NSString *const SFARange = @"Range";
static NSString *const SFABytes = @"bytes";

static NSString *const SFAMethod = @"method";
static NSString *const SFARaw = @"raw";
static NSString *const SFAFileSize = @"fileSize";
static NSString *const SFABatchId = @"batchId";
static NSString *const SFABatchLast = @"batchLast";
static NSString *const SFACanResume = @"canResume";
static NSString *const SFAStartOver = @"startOver";
static NSString *const SFAUnzip = @"unzip";
static NSString *const SFATool = @"tool";
static NSString *const SFATitle = @"title";
static NSString *const SFADetails = @"details";
static NSString *const SFASendGuid = @"sendGuid";
static NSString *const SFAThreadCount = @"threadCount";
static NSString *const SFAOverwrite = @"overwrite";
static NSString *const SFAIsSend = @"isSend";
static NSString *const SFAResponseFormat = @"responseFormat";
static NSString *const SFANotify = @"notify";
static NSString *const SFAClientCreatedDateUTC = @"clientCreatedDateUTC";
static NSString *const SFAClientModifiedDateUTC = @"clientModifiedDateUTC";

static NSString *const SFALogTrace = @"TRACE";
static NSString *const SFALogDebug = @"DEBUG";
static NSString *const SFALogInfo = @"INFO";
static NSString *const SFALogWarn = @"WARN";
static NSString *const SFALogError = @"ERROR";
static NSString *const SFALogFatal = @"FATAL";

static NSString *const SFAAccessToken = @"access_token";
static NSString *const SFACode = @"code";

static NSString *const SFAMutableArrayClassName = @"NSMutableArray";
static NSString *const SFAMutableStringClassName = @"NSMutableString";
static NSString *const SFAMutableDictionaryClassName = @"NSMutableDictionary";
static NSString *const SFAMutableSetClassName = @"NSMutableSet";
static NSString *const SFANsObjectClassName = @"NSObject";
static NSString *const SFAOdataMetadataKey = @"odata.metadata";
static NSString *const SFAODataTypeKey = @"odata.type";

static NSString *const SFAExpiresIn = @"expires_in";
static NSString *const SFAAppCp = @"appcp";
static NSString *const SFAApiCp = @"apicp";
static NSString *const SFASubDomain = @"subdomain";
static NSString *const SFAErrorDescription = @"error_description";
static NSString *const SFAOAuthErrorString = @"OAuth Error";
static NSString *const SFADescription = @"Description";
static NSString *const SFADescriptionError = @"Error";
static NSString *const SFAState = @"state";

static NSString *const SFARefreshToken = @"refresh_token";
static NSString *const SFATokenType = @"token_type";

static NSString *const SFAClientId = @"client_id";
static NSString *const SFAClientSecret = @"client_secret";
static NSString *const SFAGrantType = @"grant_type";
static NSString *const SFAAuthorizationCode = @"authorization_code";
static NSString *const SFAUsername = @"username";
static NSString *const SFAPassword = @"password";
static NSString *const SFARequirev3 = @"requirev3";
static NSString *const SFAAssertion = @"assertion";

static NSString *const SFAAction = @"action";
static NSString *const SFAApiRequestString = @"apiRequest";
static NSString *const SFAAuthContextKey = @"authContext";
static NSString *const SFABearer = @"Bearer";
static NSString *const SFAAuthorization = @"Authorization";
static NSString *const SFAXSFApiTool = @"X-SFAPI-Tool";
static NSString *const SFAXSFAPIToolVersion = @"X-SFAPI-ToolVersion";
static NSString *const SFAXDeviceId = @"X-SFAPI-DeviceId";
static NSString *const SFAXDeviceName = @"X-SFAPI-DeviceName";
static NSString *const SFAXUserInitiated = @"X-SFAPI-UserInitiated";
static NSString *const SFAErrorParsingResponse = @"Error Parsing Response";
static NSString *const SFADomainInvalidResponseError = @"Invalid Response Error";
static NSString *const SFAInvalidClass = @"Invalid Class";
static NSString *const SFAInvalidClassFormat = @"Response Class of a Query should be of type NSObject";
static NSString *const SFARequestTimeout = @"Request timeout";
static NSString *const SFADomainHttpReqError = @"Http Request Erro";
static NSString *const SFAErrorResponseContent = @"Unable to retrieve HTTP Response Message Content";
static NSString *const SFAContentLengthError = @"Content-Length Error";
static NSString *const SFAWWWAuthenticate = @"WWW-Authenticate";
static NSString *const SFALocationHeader = @"Location";
static NSString *const SFAErrorAuthenticationFailed = @"Authentication failed with status";
static NSString *const SFAErrorProxyAuthFailed = @"ProxyAuthentication failed with status code";
static NSString *const SFAErrorAuthChallengeCanceled = @"Authentication challenge canceled";
static NSString *const SFADomainProxyAuthFailed = @"Proxy Authentication Failed";
static NSString *const SFARedirectionRespReceived = @"Redirect response received";
static NSString *const SFAErrorInvalidResponse = @"Invalid Response Error";
static NSString *const SFAApplicationJson = @"application/json";
static NSString *const SFASessionLogin = @"Sessions/Login";

static NSString *const SFAXHttpMethodOverride = @"X-Http-Method-Override";
static NSString *const SFAXClientCapabilities = @"X-SF-ClientCapabilities";
static NSString *const SFAAcceptLanguage = @"Accept-Language";
static NSString *const SFAccept = @"Accept";

static NSString *const SFAFormatBaseUri = @"Unable to create a BaseUri from the provided uri.  The uri start the following format: https://secure.sf-api.com/sf/v3/";

static NSString *const SFAFormatIds = @"Expected argument to be a NSURL or NSString";
static NSString *const SFAFormatBaseUrlNil = @"baseUrl cannot be nil ensure the propery has been passed in correctly";

static NSString *const SFAKeySelect = @"$select";
static NSString *const SFAKeyExpand = @"$expand";
static NSString *const SFAKeyTop = @"$top";
static NSString *const SFAKeySkip = @"$skip";
static NSString *const SFAKeyFilter = @"$filter";

static NSString *const SFAErrorConnection = @"Can not establish connection.";

static NSString *const SFAAsyncOperationSchedule = @"Async Operation Scheduled";

static NSString *const SFAMessage = @"Mesage";
static NSString *const SFADomain = @"Domain";
static NSString *const SFAType = @"Type";
static NSString *const SFARequest = @"Request";
static NSString *const SFAURL = @"URL";
static NSString *const SFAHeader = @"Header";

static NSString *const SFAPS = @"PS";
static NSString *const SFAProtocol = @"protocol";
static NSString *const SFAHost = @"host";
static NSString *const SFAPort = @"port";
static NSString *const SFARealm = @"realm";
static NSString *const SFAProxyType = @"proxyType";
static NSString *const SFAFilePartString = @"FilePart";

static NSString *const SFAAddingOauthCredential = @"Adding OAuth Credentials";
static NSString *const SFAFailedToAddOauthCredentials = @"Failed to add OAuth credentials";

static NSString *const SFAToolName = @"SF Client SDK";
static NSString *const SFAToolVersion = @"3.0";
static NSTimeInterval const SFAHttpTimeout = 100;

static long long const SFAEpochTicks = 621355968000000000;
static long long const SFATicksPerSecond = 10000000;

static NSString *const SFATrueString = @"True";
static NSString *const SFAFalseString = @"False";

// Folder IDs
/**
 *  All Shared / Shared With Me
 */
static NSString *const SFFolderID_AllShared = @"allshared";
/**
 *  Top Folder
 */
static NSString *const SFFolderID_TopFolder = @"top";
/**
 *  File Box
 */
static NSString *const SFFolderID_FileBox = @"box";
/**
 *  Favorited Folders
 */
static NSString *const SFFolderID_Favorites = @"favorites";

// Connectors
/**
 *  Network Shares (CIFS) folderId (new Connector Group design)
 */
static NSString *const SFFolderID_NetworkShares = @"c-cifs";
/**
 *  SharePoint folderId (new Connector Group design)
 */
static NSString *const SFFolderID_SharePointShares = @"c-sp";
/**
 *  Network Shares (CIFS) folderId (pre-Connector Groups design - can still be present in some V1 calls)
 */
static NSString *const SFFolderID_NetworkShares_legacy = @"networkshareconnectors";
/**
 *  SharePoint folderId (pre-Connector Groups design - can still be present in some V1 calls)
 */
static NSString *const SFFolderID_SharePointShares_legacy = @"sharepointconnectors";

/**
 *  Connector Groups folderId
 */
static NSString *const SFFolderID_ConnectorGroups = @"connectors";

// Personal Cloud connectors
/**
 *  Personal Cloud 'pseudo folder' folderId
 */
static NSString *const SFFolderID_PersonalCloud = @"c-pcc";
/**
 *  Box folderId (Personal Cloud)
 */
static NSString *const SFFolderID_BoxConnector = @"c-Box";
/**
 *  Dropbox folderId (Personal Cloud)
 */
static NSString *const SFFolderID_Dropbox = @"c-Dropbox";
/**
 *  OneDrive folderId (Personal Cloud)
 */
static NSString *const SFFolderID_OneDrive = @"c-OneDrive";
/**
 *  GoogleDrive folderId (Personal Cloud)
 */
static NSString *const SFFolderID_GoogleDrive = @"c-GoogleDrive";

// Office 365 connectors
/**
 *  Office 365 'pseudo folder' folderId
 */
static NSString *const SFFolderID_Office365 = @"c-office365";
/**
 *  SharePointOnline folderId (Office 365)
 */
static NSString *const SFFolderID_SharePointOnline = @"c-sp365";
/**
 *  OneDrive for Business folderId (Office 365)
 */
static NSString *const SFFolderID_OneDriveBusiness = @"c-odb365";
/**
 *  ShareConnect
 */
static NSString *const SFFolderID_ShareConnect = @"c-shareconnect";
/**
 *  ShareConnectMac
 */
static NSString *const SFFolderID_ShareConnectMac = @"fohMac";
/**
 *  ShareConnectPC
 */
static NSString *const SFFolderID_ShareConnectPC = @"fohPC";
/**
 *  ShareConnectRootFolderId
 * "c2Nyb290" is base64 value of "scroot" and this is not expected to change
 */
static NSString *const SFFolderID_ShareConnectRoot = @"c2Nyb290";
