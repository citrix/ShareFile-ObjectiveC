//
//  ShareFileSDK_iOS.h
//  ShareFileSDK-iOS
//
//  Created by Fabien Lydoire on 25/11/2019.
//  Copyright © 2019 Fabien Lydoire. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for ShareFileSDK_iOS.
FOUNDATION_EXPORT double ShareFileSDK_iOSVersionNumber;

//! Project version string for ShareFileSDK_iOS.
FOUNDATION_EXPORT const unsigned char ShareFileSDK_iOSVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <ShareFileSDK_iOS/PublicHeader.h>

#import "ShareFileSDK.h"
#import "SFASDKAuthHandler.h"
#import "SFASDKAuthHandlerProtected.h"
#import "SFAJSONToODataMapper.h"
#import "SFACompositeUploaderTask.h"
#import "SFAFilePart.h"
#import "SFAHttpResponseActionAsyncCallback.h"
#import "SFAAsyncUploaderBaseProtected.h"
#import "SFAResponse.h"
#import "SFAHttpRequestUtils.h"
#import "SFADownloadTask.h"
#import "SFAHTTPAuthenticationChallengeProtected.h"
#import "NSDictionary+sfapi.h"
#import "SFAAsyncFileDownloaderProtected.h"
#import "SFIItemInfo+sfapi.h"
#import "SFIModelConstants.h"
#import "SFAUploaderTask.h"
#import "SFABearerAuthParser.h"
#import "SFAAsyncMultiChunkFileUploader.h"
#import "SFAApiResponse.h"
#import "SFAConnectionAuthParser.h"
#import "SFABaseAuthHandlerProtected.h"
#import "SFAZoneAuthentication.h"
#import "NSMutableArray+sfapi.h"
#import "NSURLProtectionSpace+sfapi.h"
#import "SFARequestProviderFactory.h"
#import "SFAApiRequest.h"
#import "SFAAsyncThreadedFileUploader.h"
#import "NSHTTPURLResponse+sfapi.h"
#import "NSURL+sfapi.h"
#import "SFABackgroundSessionManagerInternal.h"
#import "SFIODataFeed+sfapi.h"
#import "SFACryptoUtils.h"
#import "SFAAsyncStandardFileUploaderPrivate.h"
#import "SFASharedThreadManager.h"
#import "NSDate+sfapi.h"
#import "SFAUtils.h"
#import "SFAStartsWithFilter.h"
#import "SFAAsyncFileDownloaderInternal.h"
#import "NSObject+sfapi.h"
#import "SFABase64.h"
#import "SFAAsyncStandardFileUploader.h"
#import "SFIEntityConstants.h"
#import "SFIHttpMethodConstants.h"
#import "SFAUploaderBaseProtected.h"
#import "NSStream+sfapi.h"
#import "SFAConstants.h"
#import "SFAAsyncStreamedFileUploader.h"
#import "NSArray+sfapi.h"
#import "SFAHttpTask.h"
#import "SFAClientProtected.h"
#import "SFABaseTask.h"
#import "SFAStopwatch.h"
#import "SFIODataObject+sfapi.h"
#import "SFACredentialCacheProtected.h"
#import "SFAConsumerConnectorAuthParser.h"
#import "SFABackgroundUploadInitiationTask.h"
