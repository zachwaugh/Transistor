#import <Foundation/Foundation.h>

int main (int argc, const char * argv[])
{
	@autoreleasepool
	{
		if (argc > 1)
		{
			NSString *event = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
			NSFileHandle *input = [NSFileHandle fileHandleWithStandardInput];
			NSData *data = [input readDataToEndOfFile];
			
			NSString *info = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			
			//NSLog(@"event: %@, info:\n%@", event, info);
			
			// Only handling songstart event at the moment
			if ([event isEqualToString:@"songstart"])
			{
				[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"TransistorSongStartEventNotification" object:info];
			}
		}
	}
	return 0;
}
