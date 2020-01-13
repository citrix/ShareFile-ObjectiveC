//
// SFIServicesCollection.h
//
// Autogenerated by a tool
//  Copyright (c) 2016 Citrix ShareFile. All rights reserved.
//

#import "SFIODataObject.h"

@class SFIService;

@interface SFIServicesCollection : SFIODataObject
{
}

/**
   RightSignature account service
 */
@property (nonatomic, strong) SFIService *RightSignature;
/**
   ShareConnect account service
 */
@property (nonatomic, strong) SFIService *ShareConnect;
/**
ShareFile Legal account service
*/
@property (nonatomic, strong) SFIService *ShareFileLegal;


@end
