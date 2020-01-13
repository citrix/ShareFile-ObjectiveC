//
//  SFIRemoteUploadsEntity.h
//
//  Autogenerated by a tool.
//  Copyright (c) 2016 Citrix ShareFile. All rights reserved.
//

#import "SFIODataEntityBase.h"

@class SFIRemoteUploadRequestParams;
@class SFIRemoteUpload;

@interface SFIRemoteUploadsEntity : SFIODataEntityBase
{

}
-(SFApiQuery*)get;
-(SFApiQuery*)getPublic;
-(SFApiQuery*)getWithUrl:(NSURL*)url;
-(SFApiQuery*)upload2WithUrl:(NSURL*)url uploadParams:(SFIRemoteUploadRequestParams*)uploadParams userId:(NSString*)userId andExpirationDays:(NSNumber*)expirationDays;
-(SFApiQuery*)createWithRemoteUpload:(SFIRemoteUpload*)remoteUpload;
-(SFApiQuery*)updateWithRemoteUpload:(SFIRemoteUpload*)remoteUpload;
-(SFApiQuery*)deleteWithId:(NSString*)Id;
-(SFApiQuery*)getUsers;
-(SFApiQuery*)validateRemoteUploadUserWithId:(NSString*)Id andEmail:(NSString*)email;
@end
