#import <Foundation/Foundation.h>
#import "SFAODataParameterCollection.h"
#import "SFAODataAction.h"
#import "SFAFilter.h"
#import "SFATransferTask.h"
#import "SFAHttpBodyDataProvider.h"

@class SFApiQuery;

/**
 *  SFAQuery protocol provides inteface between query object and provider's setting up task for executing them.
 */
@protocol SFAQuery <NSObject>
/**
 *  Class for expected response of query. It is used if class of response can not be determined using meta-data.
 */
@property (nonatomic, strong) Class responseClass;
/**
 *  BOOL specifying if expected response is SFODataFeed. In this case responseClass is Class of objects inside SFODataFeed.
 */
@property (nonatomic) BOOL isODataFeed;

/**
 *  Creates a task conforming to SFATransferTask and starts the task, configuring it with provided parameters.
 *
 *  @param callbackQueue      NSOperationQueue on which the callbacks will be called. For SFAAsyncRequestProvider:if nil, defaults to main queue.
 *  @param completionCallback SFATask completion callback.
 *  @param cancelCallback     SFATask cancel callback.
 *
 *  @return Returns initilized and started task, conforming SFATransferTask, configured with provided parameters.
 */
- (id <SFATransferTask> )executeAsyncWithCallbackQueue:(NSOperationQueue *)callbackQueue completionCallback:(SFATaskCompletionCallback)completionCallback cancelCallback:(SFATaskCancelCallback)cancelCallback;
/**
 *  Add filter to the query.
 *
 *  @param filter Filter conforming to SFAFilter.
 *
 *  @return Returns query reference for function call chaining.
 */
- (SFApiQuery *)filterBy:(id <SFAFilter> )filter;
/**
 *  Add a property to expand, leveraging ShareFile's OData support.
 *
 *  @param expandProperty NSString name of property to expand.
 *
 *  @return Returns query reference for function call chaining.
 */
- (SFApiQuery *)expandProperty:(NSString *)expandProperty;
/**
 *  Add a properties to expand, leveraging ShareFile's OData support.
 *
 *  @param expandProperties NSArray of NSString objects having name of properties to expand.
 *
 *  @return Returns query reference for function call chaining.
 */
- (SFApiQuery *)expandProperties:(NSArray *)expandProperties;
/**
 *  Add a property to select, leveraging ShareFile's OData support.
 *
 *  @param selectProperty NSString name of property to select.
 *
 *  @return Returns query reference for function call chaining.
 *
 *  All other properties in reponse will have default value. This is convenient for reducing payloads on the wire.
 */
- (SFApiQuery *)selectProperty:(NSString *)selectProperty;
/**
 *  Add a properties to select, leveraging ShareFile's OData support. See expandProperties.
 *
 *  @param selectProperties NSArray of NSString objects having name of properties to select.
 *
 *  @return Returns query reference for function call chaining.
 */
- (SFApiQuery *)selectProperties:(NSArray *)selectProperties;
/**
 *  Number of row/entries/models to skip in ODataFeed.
 *
 *  @param skip int number of row/entries to skip.
 *
 *  @return Returns query reference for function call chaining.
 */
- (SFApiQuery *)skip:(int)skip;
/**
 *  Limit the size of response by limiting returned rows/entries/models to top 'x'. 'x' being the number specified.
 *
 *  @param skip int number to which to limit response rows/entries/models.
 *
 *  @return Returns query reference for function call chaining.
 */
- (SFApiQuery *)top:(int)top;
/**
 *  Add HTTP header value that will be added URL request.
 *
 *  @param key   NSString identifying the HTTP header field.
 *  @param value NSString value of HTTP header field.
 *
 *  @return Returns query reference for function call chaining.
 */
- (SFApiQuery *)addHeaderWithKey:(NSString *)key value:(NSString *)value;
/**
 *  Set Base URL of ShareFile
 *
 *  @param url NSURL representing URL of ShareFile.
 *
 *  @return Returns query reference for function call chaining.
 */
- (SFApiQuery *)setBaseUrl:(NSURL *)url;

@end

/**
 *  Protocol with only read only properties of Query.
 */
@protocol SFAReadOnlyQuery <NSObject>
/**
 *  The HTTP request method. e.g. @"GET".
 */
@property (nonatomic, strong, readonly) NSString *httpMethod;
/**
 *  The HTTP request body provider.
 */
@property (nonatomic, strong, readonly) id <SFAHttpBodyDataProvider> body;
/**
 *  Name of entity thats making the call. ShareFile URL can be of the form: scheme://sudomain.domain/from(id1,id2)/action(param1=val1,param2=val2)/subaction1(val3,val4)/subaction2(param5=val5,param=6=val6)?q1=vq1)
 */
@property (nonatomic, strong, readonly) NSString *from;
/**
 *  NSArray of SFAODataAction. ShareFile URL can be of the form: scheme://sudomain.domain/from(id1,id2)/action(param1=val1,param2=val2)/subaction1(val3,val4)/subaction2(param5=val5,param=6=val6)?q1=vq1
 */
@property (nonatomic, strong, readonly) NSArray *subActions;
/**
 *  SFAODataAction specifying action. ShareFile URL can be of the form: scheme://sudomain.domain/from(id1,id2)/action(param1=val1,param2=val2)/subaction1(val3,val4)/subaction2(param5=val5,param=6=val6)?q1=vq1
 */
@property (nonatomic, strong, readonly) SFAODataAction *action;
/**
 *  Dictionary containing HTTP request headers.
 */
@property (nonatomic, strong, readonly) NSDictionary *headers;
/**
 *  ODataParameterCollection having query string key value pairs. ShareFile URL can be of the form: scheme://sudomain.domain/from(id1,id2)/action(param1=val1,param2=val2)/subaction1(val3,val4)/subaction2(param5=val5,param=6=val6)?q1=vq1
 */
@property (nonatomic, strong, readonly) SFAODataParameterCollection *queryString;
/**
 *  ODataParameterCollection having ids key value pair. ids can be used as URL if they combine to become a valid URL. ShareFile URL can be of the form: scheme://sudomain.domain/from(id1,id2)/action(param1=val1,param2=val2)/subaction1(val3,val4)/subaction2(param5=val5,param=6=val6)?q1=vq1
 */
@property (nonatomic, strong, readonly) SFAODataParameterCollection *ids;

@end
/**
 *  Protocol with only read only properties of OData Query.
 */
@protocol SFAReadOnlyODataQuery <SFAReadOnlyQuery>
/**
 *  Limit the size of response by limiting returned rows/entries/models to top 'x'. 'x' being the number specified.
 */
@property (nonatomic, readonly) int top;
/**
 *  Number of row/entries/models to skip in ODataFeed.
 */
@property (nonatomic, readonly) int skip;
/**
 *  NSArray of NSString objects having name of properties to select, leveraging ShareFile's OData support.
 */
@property (nonatomic, strong, readonly) NSArray *selectProperties;
/**
 *  NSArray of NSString objects having name of properties to expand, leveraging ShareFile's OData support.
 */
@property (nonatomic, strong, readonly) NSArray *expandProperties;
/**
 *  Filter applied to query, leveraging ShareFile's OData support.
 */
@property (nonatomic, strong, readonly) id <SFAFilter> filter;

@end
