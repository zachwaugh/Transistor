#import <Foundation/Foundation.h>

int main (int argc, const char * argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

  if (argc > 1)
  {
    NSString *event = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
    NSFileHandle *input = [NSFileHandle fileHandleWithStandardInput];
    NSData *data = [input readDataToEndOfFile];
    
    NSString *info = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    // Only handling songstart event at the moment
    if ([event isEqualToString:@"songstart"])
    {
      NSLog(@"-- handled event: %@", event);
      [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"TransistorSongStartEventNotification" object:info];
    }
  }

	[pool drain];
	return 0;
}
