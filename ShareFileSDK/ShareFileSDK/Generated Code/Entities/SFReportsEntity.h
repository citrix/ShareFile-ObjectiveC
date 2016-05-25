//
//  SFReportsEntity.h
//
//  Autogenerated by a tool.
//  Copyright (c) 2016 Citrix ShareFile. All rights reserved.
//

#import "SFODataEntityBase.h"

@class SFReport;

@interface SFReportsEntity : SFODataEntityBase
{
}

/**
   @abstract Get Reports for Current Account
   Returns all the reports configured for the current account. By expanding the Records property, a list of all ReportRecords can be accessed as well.@return Reports for current account
 */
- (SFApiQuery *)get;

/**
   @abstract Get Report by ID
   Returns a single report specified by id. The Records property is expandable.
   @param id
   @return Single Report
 */
- (SFApiQuery *)getWithUrl:(NSURL *)url;

/**
   @abstract Get recent reports
   Returns the most recent reports run for the current account. 10 reports are returned unless otherwise specified.
   @param maxReports
   @return List of reports
 */
- (SFApiQuery *)getRecentWithMaxReports:(NSNumber *)maxReports;

/**
   @abstract Get recurring reports
   Returns all recurring reports for the current account.@return List of reports
 */
- (SFApiQuery *)getRecurring;

/**
   @abstract Get Report Record by ID
   Returns a single record.
   @param id
   @return Single Record
 */
- (SFApiQuery *)getRecordWithId:(NSString *)Id;

/**
   @abstract Get all Records by Report ID
   Returns all records for a single report.
   @param id
   @return Records for a Report
 */
- (SFApiQuery *)getRecordsWithUrl:(NSURL *)url;

/**
   @abstract Create Report
   @description
   {
   "Id": "rs24f83e-b147-437e-9f28-e7d03634af42"
   "Title": "Usage Report",
   "ReportType": "Activity",
   "ObjectType": "Account",
   "ObjectId": "a024f83e-b147-437e-9f28-e7d0ef634af42",
   "DateOption": "Last30Days",
   "SaveFormat": "Excel"
   }
   Creates a new Report.
   @param report
   @param runOnCreate
   @return the created report
 */
- (SFApiQuery *)createWithReport:(SFReport *)report andRunOnCreate:(NSNumber *)runOnCreate;

/**
   @abstract Update Report
   @description
   {
   "Title": "Usage Report",
   "ReportType": "Activity",
   "ObjectType": "Account",
   "ObjectId": "a024f83e-b147-437e-9f28-e7d03634af42",
   "DateOption": "Last30Days",
   "Frequency": "Once"
   }
   Updates an existing report
   @param report
   @return the updated report
 */
- (SFApiQuery *)updateWithReport:(SFReport *)report;

/**
   @abstract Delete Report
   Removes a report from the system
   @param id
 */
- (SFApiQuery *)deleteWithUrl:(NSURL *)url;

/**
   @abstract Run Report
   Run a report and get the run id.@return ReportRecord
 */
- (SFApiQuery *)getRunWithUrl:(NSURL *)url;

/**
   @abstract Get a preview location for the report
   
   @param reportUrl
 */
- (SFApiQuery *)previewWithReportUrl:(NSURL *)reportUrl;

/**
   @abstract Get JSON Data
   Get the JSON data for a report
   @param id
   @return JSON Formatted Report Results
 */
- (SFApiQuery *)getJsonDataWithId:(NSString *)Id;

/**
   @abstract Save a folder to a folder location
   
   @param reportUrl
   @param folderId
 */
- (SFApiQuery *)moveWithReportUrl:(NSURL *)reportUrl andFolderId:(NSString *)folderId;

/**
   @abstract Get spreadsheet data
   Get the spreadsheet data for a report
   @param id
   @return Excel Formatted Report Results
 */
- (SFApiQuery *)downloadDataWithId:(NSString *)Id;
@end
