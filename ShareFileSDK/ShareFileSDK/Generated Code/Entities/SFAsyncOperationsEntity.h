//
//  SFAsyncOperationsEntity.h
//
//  Autogenerated by a tool.
//  Copyright (c) 2016 Citrix ShareFile. All rights reserved.
//

#import "SFODataEntityBase.h"

@class SFAsyncOperation;

@interface SFAsyncOperationsEntity : SFODataEntityBase
{
}

/**
   @abstract Get AsyncOperation by ID
   Retrieve a single Async Op record by ID
   @param id
   @return A single Async Operation record
 */
- (SFApiQuery *)getWithUrl:(NSURL *)url;

/**
   @abstract Get List of AsyncOperations by Operation Batch ID
   Retrieves all AsyncOperations on the specified batch
   @param id
   @return A Feed of AsyncOperation objects, containing all items in the specified batch
 */
- (SFApiQuery *)getByBatchWithId:(NSString *)Id;

/**
   @abstract Get progress of AsyncOperations by Operation Batch ID
   Retrieves an AsyncOperation containing batch progress by Operation Batch ID
   @param id
   @return An Async Operation object containing batch progress
 */
- (SFApiQuery *)getBatchWithId:(NSString *)Id;

/**
   @abstract Get List of AsyncOperations by Folder
   Retrieves all AsyncOperations associated with the calling user and the Item ID
   @param id
   @return A Feed of AsyncOperation objects, containing all pending operations in the specific folder, for the authenticated SDK user
 */
- (SFApiQuery *)getByFolderWithId:(NSString *)Id;
- (SFApiQuery *)createWithAsyncOp:(SFAsyncOperation *)asyncOp;

/**
   @abstract Cancel AsyncOperation
   Cancels a single Async operation record
   @param id
   @return The modified Async Operation record
 */
- (SFApiQuery *)cancelWithUrl:(NSURL *)url;

/**
   @abstract Delete AsyncOperation
   Cancels a single Async operation record (same as /Cancel)
   @param id
 */
- (SFApiQuery *)deleteWithUrl:(NSURL *)url;

/**
   @abstract Cancel an Operation Batch
   Cancel an Async Operation batch - all unfinished Async Operation records in that batchwill be moved to Cancelled state.
   @param id
   @return A list of the modified Async Operations in the batch
 */
- (SFApiQuery *)cancelBatchWithId:(NSString *)Id;

/**
   @abstract Changes the state of an AsyncOperation
   @description
   { "State": "..." }
   Only the State parameter is updated, other fields are ignored
   @param id
   @param newAsyncOp
   @return The modified Async Operation
 */
- (SFApiQuery *)updateWithUrl:(NSURL *)url andNewAsyncOp:(SFAsyncOperation *)newAsyncOp;
@end
