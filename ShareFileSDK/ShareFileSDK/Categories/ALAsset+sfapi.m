#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

#import "ALAsset+sfapi.h"

@implementation ALAsset (sfapi)

- (SFAUploadSpecificationRequest *)uploadSpecificationRequestWithFileName:(NSString *)fileName parentFolderURL:(NSURL *)parentFolderURL description:(NSString *)description shouldOverwrite:(BOOL)overwrite uploadMethod:(SFAUploadMethod)method {
    SFAUploadSpecificationRequest *request = nil;
    ALAssetRepresentation *defaultRep = [self defaultRepresentation];
    if (defaultRep) {
        NSURL *uri = [defaultRep url];
        long long size = [defaultRep size];
        NSString *type = [self valueForProperty:ALAssetPropertyType];
        NSDate *date = (NSDate *)[self valueForProperty:ALAssetPropertyDate];
        if (uri && size > 0 && type && date) {
            // url format e.g. "assets-library://asset/asset.M4V?id=1000000000&ext=M4V"
            // get the extension
            NSString *extension = [self fileExtension];
            
            NSString *mFileName = fileName;
            // create a filename if one was not given
            if (mFileName.length == 0) {
                // create the user friendly date
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"dd-MMM-yyyy.(hh.mm.ss)"];
                [formatter setLocale:[NSLocale currentLocale]];
                NSString *dateString = [formatter stringFromDate:date];
                
                // get the type
                // determine the filename to use
                if ([type isEqualToString:ALAssetTypePhoto]) {
                    mFileName = [NSString stringWithFormat:@"photo-%@%@", dateString, (extension ?[NSString stringWithFormat : @".%@", extension] : @"")];
                }
                else if ([type isEqualToString:ALAssetTypeVideo]) {
                    mFileName = [NSString stringWithFormat:@"capture-%@%@", dateString, (extension ?[NSString stringWithFormat : @".%@", extension] : @"")];
                }
                else {
                    // type unknown
                    mFileName = [NSString stringWithFormat:@"unknown-%@%@", dateString, (extension ?[NSString stringWithFormat : @".%@", extension] : @"")];
                }
            }
            // enqueue the new upload
            request = [[SFAUploadSpecificationRequest alloc] init];
            request.fileName = mFileName;
            request.title = request.fileName;
            request.destinationURI = parentFolderURL;
            request.details = description;
            request.overwrite = overwrite;
            request.method = method;
            return request;
        }
    }
    return nil;
}

- (NSString *)fileExtension {
    ALAssetRepresentation *defaultRep = [self defaultRepresentation];
    if (defaultRep) {
        NSURL *uri = [defaultRep url];
        if (uri) {
            NSString *sourcePath = [uri absoluteString];
            NSString *extension = nil;
            NSRange extRange = [sourcePath rangeOfString:@"ext="];
            if (extRange.location != NSNotFound) {
                extension = [sourcePath substringFromIndex:extRange.location + extRange.length];
            }
            return extension;
        }
    }
    return nil;
}

@end

#pragma clang diagnostic pop
