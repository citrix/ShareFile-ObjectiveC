//
// SFStorageCenter.h
//
// Autogenerated by a tool
//  Copyright (c) 2016 Citrix ShareFile. All rights reserved.
//

#import "SFODataObject.h"

@class SFZone;

@interface SFStorageCenter : SFODataObject
{
}

@property (nonatomic, strong) SFZone *Zone;
@property (nonatomic, strong) NSString *Address;
@property (nonatomic, strong) NSString *LocalAddress;
@property (nonatomic, strong) NSString *ExternalAddress;
@property (nonatomic, strong) NSString *DefaultExternalUrl;
@property (nonatomic, strong) NSString *HostName;
@property (nonatomic, strong) NSString *Services;
@property (nonatomic, strong) NSString *Version;
@property (nonatomic, strong) NSNumber *Enabled;
@property (nonatomic, strong) NSDate *LastHeartBeat;
@property (nonatomic, strong) NSString *ExternalUrl;
@property (nonatomic, strong) NSString *MetadataProxyAddress;
@property (nonatomic, strong) NSDate *LastPingBack;


@end
