@interface SFAApiRequest ()

- (void)setQueryBase:(SFAQueryBase *)queryBase;
- (NSString *)queryStringForUrl;

@end
