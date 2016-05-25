//
// SFAccessControlParam.h
//
// Autogenerated by a tool
//  Copyright (c) 2016 Citrix ShareFile. All rights reserved.
//

#import "SFODataObject.h"

@class SFAccessControl;

@interface SFAccessControlParam : SFODataObject
{
}

/**
   AccessControl.Item is inherited from AccessControlsBulkParams and cannot be specified here
 */
@property (nonatomic, strong) SFAccessControl *AccessControl;
/**
   Defines whether this principal should receieve a notice on the permission grant.
   If not specified it is inherited AccessControlsBulkParams
 */
@property (nonatomic, strong) NSNumber *NotifyUser;
/**
   Custom notification message, if any
   If not specified it is inherited AccessControlsBulkParams
 */
@property (nonatomic, strong) NSString *NotifyMessage;
/**
   Defines whether this ACL change should be applied recursively
 */
@property (nonatomic, strong) NSNumber *Recursive;


@end
