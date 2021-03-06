//
//  SFRemoteUploadsEntity.m
//
//  Autogenerated by a tool.
//  Copyright (c) 2016 Citrix ShareFile. All rights reserved.
//

#import "SFHttpMethodConstants.h"
#import "SFEntityConstants.h"
#import "SFRemoteUploadsEntity.h"
#import "SFODataEntityBase.h"
#import "SFRemoteUpload.h"
#import "SFRemoteUploadRequestParams.h"
#import "SFUploadSpecification.h"
#import "SFContact.h"
#import "SFUser.h"


@implementation SFRemoteUploadsEntity
-(SFApiQuery*)get
{
	SFApiQuery *sfApiQuery = [[SFApiQuery alloc] initWithClient:self.client];
	sfApiQuery.responseClass = [SFRemoteUpload class];
	sfApiQuery.isODataFeed = YES;

	[sfApiQuery setFrom:kSFEntities_RemoteUploads];
	[sfApiQuery setHttpMethod:kSFHttpMethodGET];
	return sfApiQuery;
}

-(SFApiQuery*)getPublic
{
	SFApiQuery *sfApiQuery = [[SFApiQuery alloc] initWithClient:self.client];
	sfApiQuery.responseClass = [SFRemoteUpload class];
	sfApiQuery.isODataFeed = NO;

	[sfApiQuery setFrom:kSFEntities_RemoteUploads];
	[sfApiQuery setAction:@"Public"];
	[sfApiQuery setHttpMethod:kSFHttpMethodGET];
	return sfApiQuery;
}

-(SFApiQuery*)getWithUrl:(NSURL*)url
{
	SFApiQuery *sfApiQuery = [[SFApiQuery alloc] initWithClient:self.client];
	sfApiQuery.responseClass = [SFRemoteUpload class];
	sfApiQuery.isODataFeed = NO;

	[sfApiQuery setFrom:kSFEntities_RemoteUploads];
	[sfApiQuery addIds:url];
	[sfApiQuery setHttpMethod:kSFHttpMethodGET];
	return sfApiQuery;
}

-(SFApiQuery*)upload2WithUrl:(NSURL*)url uploadParams:(SFRemoteUploadRequestParams*)uploadParams userId:(NSString*)userId andExpirationDays:(NSNumber*)expirationDays
{
	SFApiQuery *sfApiQuery = [[SFApiQuery alloc] initWithClient:self.client];
	sfApiQuery.responseClass = [SFUploadSpecification class];
	sfApiQuery.isODataFeed = NO;

	[sfApiQuery setFrom:kSFEntities_RemoteUploads];
	[sfApiQuery setAction:@"Upload2"];
	[sfApiQuery addIds:url];
	[sfApiQuery addQueryString:@"userId" withValue:userId];
	[sfApiQuery addQueryString:@"expirationDays" withValue:expirationDays];
	[sfApiQuery setBody:uploadParams];
	[sfApiQuery setHttpMethod:kSFHttpMethodPOST];
	return sfApiQuery;
}

-(SFApiQuery*)createWithRemoteUpload:(SFRemoteUpload*)remoteUpload
{
	SFApiQuery *sfApiQuery = [[SFApiQuery alloc] initWithClient:self.client];
	sfApiQuery.responseClass = [SFRemoteUpload class];
	sfApiQuery.isODataFeed = NO;

	[sfApiQuery setFrom:kSFEntities_RemoteUploads];
	[sfApiQuery setBody:remoteUpload];
	[sfApiQuery setHttpMethod:kSFHttpMethodPOST];
	return sfApiQuery;
}

-(SFApiQuery*)updateWithRemoteUpload:(SFRemoteUpload*)remoteUpload
{
	SFApiQuery *sfApiQuery = [[SFApiQuery alloc] initWithClient:self.client];
	sfApiQuery.responseClass = [SFRemoteUpload class];
	sfApiQuery.isODataFeed = NO;

	[sfApiQuery setFrom:kSFEntities_RemoteUploads];
	[sfApiQuery setBody:remoteUpload];
	[sfApiQuery setHttpMethod:kSFHttpMethodPATCH];
	return sfApiQuery;
}

-(SFApiQuery*)deleteWithId:(NSString*)Id
{
	SFApiQuery *sfApiQuery = [[SFApiQuery alloc] initWithClient:self.client];

	[sfApiQuery setFrom:kSFEntities_RemoteUploads];
	[sfApiQuery addQueryString:@"Id" withValue:Id];
	[sfApiQuery setHttpMethod:kSFHttpMethodDELETE];
	return sfApiQuery;
}

-(SFApiQuery*)getUsers
{
	SFApiQuery *sfApiQuery = [[SFApiQuery alloc] initWithClient:self.client];
	sfApiQuery.responseClass = [SFContact class];
	sfApiQuery.isODataFeed = YES;

	[sfApiQuery setFrom:kSFEntities_RemoteUploads];
	[sfApiQuery setAction:@"Users"];
	[sfApiQuery setHttpMethod:kSFHttpMethodGET];
	return sfApiQuery;
}

-(SFApiQuery*)validateRemoteUploadUserWithId:(NSString*)Id andEmail:(NSString*)email
{
	SFApiQuery *sfApiQuery = [[SFApiQuery alloc] initWithClient:self.client];
	sfApiQuery.responseClass = [SFUser class];
	sfApiQuery.isODataFeed = NO;

	[sfApiQuery setFrom:kSFEntities_RemoteUploads];
	[sfApiQuery setAction:@"ValidateRemoteUploadUser"];
	[sfApiQuery addQueryString:@"Id" withValue:Id];
	[sfApiQuery addQueryString:@"email" withValue:email];
	[sfApiQuery setHttpMethod:kSFHttpMethodPOST];
	return sfApiQuery;
}

@end