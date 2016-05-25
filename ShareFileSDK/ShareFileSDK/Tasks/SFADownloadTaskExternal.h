/**
 *  Callback to be called as Task receives data from server. You can use this callback to change data before its written to file. Useful in case you want the data to be encrypted before being writter to file. If 'nil' is returned the data is not written to file.
 *  `receivedData`: NSData representing chunk of data received from server.
 *  Returns NSData representing mutated data.
 */
typedef NSData * (^SFADownloadTaskDataReceivedCallback)(NSData *receivedData);

/**
 *  The SFADownloadTask protocol provides methods for API user to interact with task's used for downloading data.
 */
@protocol SFADownloadTask <SFATransferTask>

/**
 *  Task's data received callback. See SFADownloadTaskDataReceivedCallback.
 */
@property (atomic, copy) SFADownloadTaskDataReceivedCallback dataReceivedCallback;

@end
