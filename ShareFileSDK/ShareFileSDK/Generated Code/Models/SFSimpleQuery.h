//
// SFSimpleQuery.h
//
// Autogenerated by a tool
//  Copyright (c) 2016 Citrix ShareFile. All rights reserved.
//

#import "SFODataObject.h"


@interface SFSimpleQuery : SFODataObject
{
}

/**
   Item type to search for (ex "File", "Folder", etc.)
 */
@property (nonatomic, strong) NSString *ItemType;
/**
   Parent id constraint on search results
 */
@property (nonatomic, strong) NSString *ParentID;
/**
   Creator id constraint on search results
 */
@property (nonatomic, strong) NSString *CreatorID;
/**
   Search term to search for
 */
@property (nonatomic, strong) NSString *SearchQuery;
/**
   Item creation date range constraint start date in UTC
 */
@property (nonatomic, strong) NSString *CreateStartDate;
/**
   Item creation date range constraint end date in UTC
 */
@property (nonatomic, strong) NSString *CreateEndDate;
/**
   Whether item content should be included in the search or not.
 */
@property (nonatomic, strong) NSNumber *ItemNameOnly;


@end
