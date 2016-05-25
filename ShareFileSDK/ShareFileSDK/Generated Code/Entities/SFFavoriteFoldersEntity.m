//
//  SFFavoriteFoldersEntity.m
//
//  Autogenerated by a tool.
//  Copyright (c) 2016 Citrix ShareFile. All rights reserved.
//

#import "SFHttpMethodConstants.h"
#import "SFEntityConstants.h"
#import "SFFavoriteFoldersEntity.h"
#import "SFODataEntityBase.h"
#import "SFFavoriteFolder.h"


@implementation SFFavoriteFoldersEntity
- (SFApiQuery *)getByUserWithUrl:(NSURL *)url {
    SFApiQuery *sfApiQuery = [[SFApiQuery alloc] initWithClient:self.client];
    sfApiQuery.responseClass = [SFFavoriteFolder class];
    sfApiQuery.isODataFeed = YES;
    
    [sfApiQuery setFrom:kSFEntities_Users];
    [sfApiQuery setAction:@"FavoriteFolders"];
    [sfApiQuery addIds:url];
    [sfApiQuery setHttpMethod:kSFHttpMethodGET];
    return sfApiQuery;
}

- (SFApiQuery *)getByUserWithItemUrl:(NSURL *)itemUrl andUserid:(NSString *)userid {
    SFApiQuery *sfApiQuery = [[SFApiQuery alloc] initWithClient:self.client];
    sfApiQuery.responseClass = [SFFavoriteFolder class];
    sfApiQuery.isODataFeed = NO;
    
    [sfApiQuery setFrom:kSFEntities_Users];
    [sfApiQuery setAction:@"FavoriteFolders"];
    [sfApiQuery addIds:itemUrl];
    [sfApiQuery addActionIds:userid];
    [sfApiQuery setHttpMethod:kSFHttpMethodGET];
    return sfApiQuery;
}

- (SFApiQuery *)getFavoriteFolderByItemWithParentUrl:(NSURL *)parentUrl {
    SFApiQuery *sfApiQuery = [[SFApiQuery alloc] initWithClient:self.client];
    sfApiQuery.responseClass = [SFFavoriteFolder class];
    sfApiQuery.isODataFeed = NO;
    
    [sfApiQuery setFrom:kSFEntities_Items];
    [sfApiQuery setAction:@"FavoriteFolder"];
    [sfApiQuery addIds:parentUrl];
    [sfApiQuery setHttpMethod:kSFHttpMethodGET];
    return sfApiQuery;
}

- (SFApiQuery *)getWithUrl:(NSURL *)url {
    SFApiQuery *sfApiQuery = [[SFApiQuery alloc] initWithClient:self.client];
    sfApiQuery.responseClass = [SFFavoriteFolder class];
    sfApiQuery.isODataFeed = NO;
    
    [sfApiQuery setFrom:kSFEntities_FavoriteFolders];
    [sfApiQuery addIds:url];
    [sfApiQuery setHttpMethod:kSFHttpMethodGET];
    return sfApiQuery;
}

- (SFApiQuery *)createByUserWithUrl:(NSURL *)url andFolder:(SFFavoriteFolder *)folder {
    SFApiQuery *sfApiQuery = [[SFApiQuery alloc] initWithClient:self.client];
    sfApiQuery.responseClass = [SFFavoriteFolder class];
    sfApiQuery.isODataFeed = NO;
    
    [sfApiQuery setFrom:kSFEntities_Users];
    [sfApiQuery setAction:@"FavoriteFolders"];
    [sfApiQuery addIds:url];
    [sfApiQuery setBody:folder];
    [sfApiQuery setHttpMethod:kSFHttpMethodPOST];
    return sfApiQuery;
}

- (SFApiQuery *)deleteWithUrl:(NSURL *)url andItemid:(NSString *)itemid {
    SFApiQuery *sfApiQuery = [[SFApiQuery alloc] initWithClient:self.client];
    
    [sfApiQuery setFrom:kSFEntities_Users];
    [sfApiQuery setAction:@"FavoriteFolders"];
    [sfApiQuery addIds:url];
    [sfApiQuery addActionIds:itemid];
    [sfApiQuery setHttpMethod:kSFHttpMethodDELETE];
    return sfApiQuery;
}

- (SFApiQuery *)deleteByUserWithUrl:(NSURL *)url andItemId:(NSString *)itemId {
    SFApiQuery *sfApiQuery = [[SFApiQuery alloc] initWithClient:self.client];
    
    [sfApiQuery setFrom:kSFEntities_Users];
    [sfApiQuery setAction:@"FavoriteFolders"];
    [sfApiQuery addIds:url];
    [sfApiQuery addActionIds:itemId];
    [sfApiQuery setHttpMethod:kSFHttpMethodDELETE];
    return sfApiQuery;
}

@end
