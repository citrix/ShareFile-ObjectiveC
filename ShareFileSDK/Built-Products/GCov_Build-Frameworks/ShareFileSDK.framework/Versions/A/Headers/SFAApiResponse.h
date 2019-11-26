#import <Foundation/Foundation.h>

@protocol SFAApiErrorResponse <NSObject>

@property (nonatomic, getter = isError) BOOL error;
@property (nonatomic) NSString *errorMessage;
@property (nonatomic) int errorCode;

@end

@interface SFAApiResponse : NSObject <SFAApiErrorResponse>

@property (nonatomic, strong) id value;

@end
