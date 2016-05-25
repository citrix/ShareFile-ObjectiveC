# ShareFile Objective-C SDK Documentation



## License

All code is licensed under the [MIT-License](https://github.com/citrix/ShareFile-PowerShell/blob/master/ShareFileSnapIn/LICENSE.txt).

<br />

## Getting Started

* Before continuing, familiarize yourself with the [ShareFile API](https://api.sharefile.com/rest) and it's methodology.
* Please make sure you are running XCode version 7.2+

<br />

## Sample Code
Example functions demonstrated: authenticate, upload, download, and create share links.

* [Sample Code](./ShareFileSDK/Misc/GenericSampleCode.m)

Once you configure credentials in "Misc/ShareFileSDKSampleCred.plist", building the app will:

1. Authenticate using the [Password Authentication](#authentication) method as described below.
2. Create a folder at the root level of your ShareFile account called "Sample Folder".
3. Upload "Misc/Sample.png" to that folder.
4. Download "Sample.png".
5. Display the image in a UIImageView.
6. Send a share notification to `shareEmail` as configured in "Misc/ShareFileSDKSampleCred.plist".
7. Provide a share link directly in the console. 

<br />

## Documentation

* [Definitions](#definitions)
* [Authentication](#authentication)
* [Queries](#queries)
    * [Common](#queries)
    * [oData](#leveraging-odata)
* [Upload and Download](#upload-and-download)

<br />
<br />

### Definitions

* `applicationControlPlane` - Describes the domain that the ShareFile account is available on.
    * For example: `sharefile.com`, `securevdr.com`, `sharefile.eu`, etc.
* `authorizationUrl` - The initial url that should be visited to being web authentication.
* `client_id` - The identifier that is uniquely identifies an OAuth client consumer.
* `client_secret` - This is a shared secret that is required to exchange an `OAuthAuthorizationCode` for an `OAuthToken`.
* `completionUri` - Alias for `redirectUri`. Used primarily in `SFAOAuth2AuthenticationHelper`.
* `OAuthAuthorizationCode` - One-time use code that is returned as part of an oauth `code` grant request. We provide a class with the specific properties for this type of response.
* `OAuthToken` - Used to authenticate with ShareFile, specifically using AccessToken - however, this is taken care of for you by the SDK.
* `redirectUri` - Resource that can be used to track when authentication is complete. Generally, this resource is controlled by the OAuth client consumer.
* `state` - Token created by the OAuth consumer to associate an authorization request
with an authorization response.

<br />
<br />

### Authentication

* Authentication with ShareFile v3 API makes use of [OAuth 2.0 protocol](http://api.sharefile.com/rest/oauth2.aspx).
* Some helper methods and classes are provided to make authentication easier for consumers. 
* Once successfully authenticated, an instance of ShareFileClient `sfaClient` will be available to execute [queries](#queries) and [tasks](#upload-and-download).

<br />

##### Web Authentication

If you use your own mechanism for tracking when authentication is complete (based on `redirectUri`), it is still advisable to use `OAuth2AuthenticationHelper` to translate the `Url` to `id<SFAOAuthResponse>`.

```objectivec
NSURL *redirectUrl = [NSURL URLWithString:@"https://secure.sharefile.com/oauth/oauthcomplete.aspx"];
// Recommended this value is held on to to verify the authentication response.
NSString *state = [[NSUUID UUID] UUIDString];
SFAClient *sfaClient = [[SFAClient alloc] initWithBaseUrl:@"https://secure.sf-api.com/sf/v3/" andConfiguration:nil];
SFAOAuthService *oauthService = [[SFAOAuthService alloc] initWithSFAClient:sfaClient clientId:@"<client_id>" clientSecret:@"<client_secret>"];
[oauthService authorizationUrlForDomain:@"<domain>" responseType:@"code" clientId:@"<client_Id>" 
                                                    redirectUrl:redirectUrl.absoluteString state:state additionalQueryParams:nil subdomain:nil];
```

<br />

Open up a web view or web browser and use `authorizationUrl` to load the page. To assist in tracking when authentication has completed,
create an instance of `SFAOAuth2AuthenticationHelper` passing `redirectUrl` to `initWithUrl:`. 

<br />

In the case you're using a web browser, you will need to register a custom URL Scheme for your application, so that the browser re-opens your application on redirection.
Then, in your AppDelegate’s methods, fetch the URL and follow the process below. [Apple's iOS library](https://developer.apple.com/library/ios/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/Inter-AppCommunication/Inter-AppCommunication.html) describes how to register and use custom URL Schemes.

```objectivec
SFAOAuth2AuthenticationHelper *authenticationHelper = [[SFAOAuth2AuthenticationHelper alloc] initWithUrl:redirectUrl];
```

<br />

In `UIWebviewDelegate` for navigation event or application launching, check the `navigationUrl` that is being loaded as follows:

```objectivec
NSURL *navigationUrl = [NSURL URLWithString:@""];
id<SFAOAuthResponse> oauthResponse = [authenticationHelper isComplete:navigationUrl];
if (oauthResponse)
{
    if ([oauthResponse isKindOfClass:[SFAOAuthError class]])
        {
            // handle error
        }
    if ([oauthResponse isKindOfClass:[SFAOAuthAuthorizationCode class]])
        {
            // exchange authorization code for OAuthToken
        }
}
```

<br />

To exchange an `OAuthAuthorizationCode` for an `OAuthToken`:

```objectivec
SFApiQuery *query = [oauthService tokenQueryFromAuthorizationCode:authorizationCode];
[sfaClient executeQueryAsync:query
            callbackQueue:nil
        completionCallback:^(id returnValue, SFAError *error, NSDictionary *additionalInfo) 
        {
            if (error)
            {
                // handle error
            }
            else if ([returnValue isKindOfClass:[SFAOAuthToken class]])
            {
                SFAOAuthToken *token = (SFAOAuthToken *)returnValue;
                [sfaClient addOAuthToken:token];
                sfaClient.baseUrl = [token getUrl];
            }
        }];
```

<br />

##### Password Authentication
In order to complete this authentication you'll need a `username`, `password`, `subdomain`, and `applicationControlPlane`.

```objectivec
SFAClient *sfaClient = [[SFAClient alloc] initWithBaseUrl:@"https://secure.sf-api.com/sf/v3/" andConfiguration:nil];
SFAOAuthService *oauthService = [[SFAOAuthService alloc] initWithSFAClient:sfaClient clientId:@"<client_id>" clientSecret:@"<client_secret>"];
SFApiQuery *query = [oauthService passwordGrantRequestQueryForUsername:@"<email>" password:@"<password>" 
subdomain:@"<subdomain>" applicationControlPlane:@"<applicationControlPlane>"];
[sfaClient executeQueryAsync:query
            callbackQueue:nil
        completionCallback:^(id returnValue, SFAError *error, NSDictionary *additionalInfo) 
        {
            if (error)
            {
                //handle error
            }
            else if ([returnValue isKindOfClass:[SFAOAuthToken class]])
            {
                SFAOAuthToken *token = (SFAOAuthToken *)returnValue;
                [sfaClient addOAuthToken:token];
                sfaClient.baseUrl = [token getUrl];
            }
        }];
```

<br />

##### SAML Authentication
This authentication method assumes you have a mechanism for obtaining a SAML assertion, `samlAssertion` from the user's IdP.

```objectivec
SFAClient *sfaClient = [[SFAClient alloc] initWithBaseUrl:@"https://secure.sf-api.com/sf/v3/" andConfiguration:nil];
SFAOAuthService *oauthService = [[SFAOAuthService alloc] initWithSFAClient:sfaClient clientId:@"<client_id>" clientSecret:@"<client_secret>"];
SFApiQuery *query = [oauthService tokenQueryFromSamlAssertion:@"<samlAssertion>" 
subdomain:@"<subdomain>" applicationControlPlane:@"<applicationControlPlane>"];
[sfaClient executeQueryAsync:query
            callbackQueue:nil
        completionCallback:^(id returnValue, SFAError *error, NSDictionary *additionalInfo) 
        {
            if (error)
            {
                //handle error
            }
            else if ([returnValue isKindOfClass:[SFAOAuthToken class]])
            {
                SFAOAuthToken *token = (SFAOAuthToken *)returnValue;
                [sfaClient addOAuthToken:token];
                sfaClient.baseUrl = [token getUrl];
            }
        }];
```

<br />

##### Refreshing an OAuthToken
Any OAuthToken that is obtained using a `code` grant type can be refreshed. This allows a consumer to silently reauthenticate with the ShareFile API without needing to prompt the user. This is useful if you plan on caching the OAuthToken. The sample below assumes you have already pulled an instance of `SFAOAuthToken` as `cachedOAuthToken` from some local cache.

```objectivec
SFAClient *sfaClient = [[SFAClient alloc] initWithBaseUrl:@"https://secure.sf-api.com/sf/v3/" andConfiguration:nil];
SFAOAuthService *oauthService = [[SFAOAuthService alloc] initWithSFAClient:sfaClient clientId:@"<client_id>" clientSecret:@"<client_secret>"];
SFApiQuery *query = [oauthService refreshOAuthTokenQuery:cachedOAuthToken];
[sfaClient executeQueryAsync:query
            callbackQueue:nil
        completionCallback:^(id returnValue, SFAError *error, NSDictionary *additionalInfo) 
        {
            if (error)
            {
                //handle error
            }
            else if ([returnValue isKindOfClass:[SFAOAuthToken class]])
            {
                SFAOAuthToken *token = (SFAOAuthToken *)returnValue;
                [sfaClient addOAuthToken:token];
                sfaClient.baseUrl = [token getUrl];
            }
        }];
```

<br />
<br />

## Queries

##### Notes
* Object of type `id<SFAQuery>` (Note:`SFApiQuery` is a class which conforms to `SFAQuery` protocol) is used to represent and contains information regarding any action that needs to be performed using ShareFile's REST API.
* Any query can be executed asyncronously using API provider by `SFAClient`, the most useful of which is `- (void)executeQueryAsync:callbackQueue:completionCallback:`.

<br />

#### Start a Session

```objectivec
SFApiQuery *query = [sfaClient.sessions loginWithAuthmethod:nil andAuthcomparison:nil];
```

<br />

#### End Session

```objectivec
SFApiQuery *query = [sfaClient.sessions delete];
[sfaClient clearCredentials];
```

<br />

#### Get the Current User
A User in ShareFile derives from the `SFPrincipal` object. Most consumers will be interested in `SFUser` and `SFAccountUser`. The `SFAccountUser` type designates the user to be an Employee and will have some additional properties available.

```objectivec
SFApiQuery *query = [sfaClient.users getWithId:@"<id>" andEmailAddress:@"<email>"];
```

<br />

#### Get the Default Folder for a User
This call will return the default folder for the currently authenticated User.

```objectivec
SFApiQuery *query = [[sfaClient.items get];
```

<br />

#### Get the Contents of a Folder

```objectivec
SFApiQuery *query = [sfaClient.items getChildrenWithUrl:<URL> andIncludeDeleted:@NO];
```

<br />

#### Create a Folder

```objectivec
SFFolder *newFolder = [[SFFolder alloc] init];
newFolder.Name = @"Sample Folder";
newFolder.Description = @"Created by SF Client SDK";
SFApiQuery *query = [sfaClient.items createFolderWithParentUrl:parentFolder.url folder:newFolder overwrite:@YES andPassthrough:@NO];
```

<br />

#### Search

```objectivec
SFApiQuery *query = [sfaClient.items searchWithQuery:@"query"];
```
<br />

#### Access Aliased Folders
Because Aliased folders are not exposed alongside standard folders, you must use `SFAItemAlias` instead.

```objectivec
NSURL *itemUrl = [sfaClient.items urlWithItemAlias:SFAItemAliasTop];
```
<br />
<br />

## Leveraging oData
ShareFile supports the oData protocol which provides standard ways of handling common tasks such as:

* Selecting specific properties
* Expanding Navigation properties such as `Folder.Children`
* Performing paging operations

<br />

#### Select
The following `SFApiQuery` will only select the Name property. If you execute this, all other properties will be their default values. This is convenient for reducing payloads on the wire.

```objectivec
SFApiQuery *query = [[sfaClient.items get] selectProperty:@"Name"];
```

<br />

#### Expand
The following `SFApiQuery` will expand `Children`. Since we know we are querying for a `Folder` we can ask ShareFile to go ahead and return the list of Children.  This helps reduce the number of round trips required. Note `Chlidren` is presented as a `NSMutableArray` instead of an `SFODataFeed`.

```objectivec
SFApiQuery *query = [[sfaClient.items get] expandProperty:@"Children"];
```

<br />

#### Top/Skip
When working with `SFODataFeed` responses, you can limit the size of the response by using `Top` and `Skip`. The following `SFApiQuery` will return up to 10 Children and skip the first 10.

```objectivec
SFApiQuery *query = [[[sfaClient.items getChildrenWithUrl:<url> andIncludeDeleted:@YES] top:10] skip:10];
```

To support paging `SFODataFeed` will also return a nextLink which will compute the Top and Skip values for you.


<br />
<br />

## Upload and Download

##### Notes
* `id<SFATask>`, `id<SFATransferTask>` and `id<SFADownloadTask>` are objects that perform the action represented by the `id<SFAQuery>` type object.
* You can also cancel a task, track progress and perform many other action on a task depending on its type. See API Reference for detail. You can also refer to the `iOSSample` and `MacOSXSample` included in the project

<br />

#### Download

```objectivec
SFAFileInfo *info = [[SFAFileInfo alloc] initWithFilePath:<filePath>];
NSFileHandle *handle = [info fileHandleForWritingCreateIfNeeded:YES];
SFAAsyncFileDownloader *fileDownloader = [self.client asyncFileDownloaderForItem:downloadItem withDownloaderConfig:nil];
id<SFADownloadTask> task = [fileDownloader downloadAsyncToFileHandle:handle
                                            withTransferMetadata:nil
                                            callbackQueue:nil
                                            completionCallback:nil
                                            cancelCallback:nil
                                            progressCallback:nil
                                            dataReceivedCallback:nil];
```

<br />

#### Upload

```objectivec
NSString *path = [[NSBundle mainBundle] pathForResource:<filename> ofType:<extension>];
SFAUploadSpecificationRequest *request = [SFAUploadSpecificationRequest new];
request.fileName = [NSString stringWithFormat:@"%@.%@", filename, extension];
request.title = request.fileName;
request.details = @"Sample Details";
request.method = SFAUploadMethodStandard;
request.overwrite = YES;
request.parent = destinationFolder.url;
SFAAsyncUploaderBase *uploaderBase = [self.client asyncFileUploaderWithUploadSpecificationRequest:request 
                                        filePath:path fileUploaderConfig:nil expirationDays:-1];
// Now use one of `SFAAsyncUploaderBase`'s uploadAsync API. See samples for more detail.
id<SFATransferTask> task = [uploaderBase uploadAsyncWithCallbackQueue:nil completionCallback:nil cancelCallback:nil progressCallback:nil];
```

<br />

#### Get transfer progress
For task's that conform to SFATransferTask you can track progress using Progress Callback or Progress Notification - see the sample app for details.