//
// SFEnsSubscriberConfiguration.h
//
// Autogenerated by a tool
//  Copyright (c) 2016 Citrix ShareFile. All rights reserved.
//

#import "SFODataObject.h"


@interface SFEnsSubscriberConfiguration : SFODataObject
{
}

@property (nonatomic, strong) NSNumber *IsEnsEnabled;
@property (nonatomic, strong) NSString *EnsServerUrl;
@property (nonatomic, strong) NSString *Version;
@property (nonatomic, strong) NSString *RecommendedPollingSyncInterval;
@property (nonatomic, strong) NSString *RecommendedNotificationSyncInterval;
@property (nonatomic, strong) NSNumber *NotificationConfigurationCount;
@property (nonatomic, strong) NSNumber *FailSafePollingCount;
@property (nonatomic, strong) NSNumber *MaxNotificationSyncWaitCount;


@end
