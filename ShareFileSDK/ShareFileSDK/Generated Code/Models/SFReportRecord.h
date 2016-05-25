//
// SFReportRecord.h
//
// Autogenerated by a tool
//  Copyright (c) 2016 Citrix ShareFile. All rights reserved.
//

#import "SFODataObject.h"

@class SFReport;

@interface SFReportRecord : SFODataObject
{
}

@property (nonatomic, strong) SFReport *Report;
/**
   The Start Date of the range the ReportRecord will be run against
 */
@property (nonatomic, strong) NSDate *StartDate;
/**
   The End Date of the range the ReportRecord will be run against
 */
@property (nonatomic, strong) NSDate *EndDate;
/**
   The Time this ReportRecord began processing
 */
@property (nonatomic, strong) NSDate *StartRunTime;
/**
   The Time this ReportRecord finished processing
 */
@property (nonatomic, strong) NSDate *EndRunTime;
@property (nonatomic, strong) NSString *Status;
@property (nonatomic, strong) NSNumber *HasData;
@property (nonatomic, strong) NSString *Message;


@end
