//
// SFMetadata.h
//
// Autogenerated by a tool
//  Copyright (c) 2016 Citrix ShareFile. All rights reserved.
//

#import "SFODataObject.h"


@interface SFMetadata : SFODataObject
{
}

/**
   The name of a custom metadata entry
 */
@property (nonatomic, strong) NSString *Name;
/**
   The value of a custom metadata entry
 */
@property (nonatomic, strong) NSString *Value;
/**
   Whether the metadata entry is public or private. Used only by the zone or storage center metadata where only zone admins have access to private metadata.
 */
@property (nonatomic, strong) NSNumber *IsPublic;


@end
