#import <Foundation/Foundation.h>

/**
 *  This class's methods can be used to override default behavior of SDK when instantiating OData Model classes.
 *  By default SDK instantiates appropiate models from its provided models, incase you want SDK to use your overriden
 *  implementation, then you can add a mapping for that default class.
 */
@interface SFAModelClassMapper : NSObject

/**
 *  Add a mapping for default model class. The SDK will start instantiating objects of new model class in place of default model class.
 *
 *  @param defaultModelClass The default model class for which mapping to be created.
 *  @param newModelClass     The new model class whose objects are to be instantiated in place of default model class.
 */
+ (void)addMappingForDefaultModelClass:(Class)defaultModelClass withNewModelClass:(Class)newModelClass;
/**
 *  Remove mapping for the provided default model class.
 *
 *  @param defaultModelClass The default model class for which mapping needs to be removed.
 */
+ (void)removeMappingForDefaultModelClass:(Class)defaultModelClass;
/**
 *  Removes all mappings for the provided default model class.
 */
+ (void)removeAllMappings;
/**
 *  Provides mapped model class for the provided default model class.
 *
 *  @param defaultModelClass The default model class for which mapping is to be returned.
 *
 *  @return The mapped model class or passed Class parameter if no mapping is found.
 */
+ (Class)mappedModelClassForDefaultModelClass:(Class)defaultModelClass;

@end
