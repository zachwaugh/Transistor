/* NSObject+PWObject.h */

#import <Foundation/Foundation.h>


@interface NSObject (PWObject)

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

@end