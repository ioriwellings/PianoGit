
//
//  NSString+URLConnection.m
//  Moko
//
//  Created by Iori Yang on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSString+URLConnection.h"
#import "Reachability.h"
#import "IoriURLConnection.h"

#define CACHEPATH @"cacheDir"

@interface IoriConnectionDelegate : NSObject <NSURLConnectionDataDelegate>
{
}
@property (readonly) NSMutableData *data;
@property (nonatomic, strong) NSString* filePath;
@property (nonatomic, strong) void (^operationCompletionBlock)(NSData* fileData, NSError *error);
@property (nonatomic, strong) void (^operationProgressBlock)(float progress);
@property (nonatomic, readwrite) float expectedContentLength;
@property (nonatomic, readwrite) float receivedContentLength;
@end

@implementation IoriConnectionDelegate
{
    NSMutableData *__data;
    NSOutputStream *__fileStream;
    NSURLResponse *__response;
}

-(NSMutableData*)getData
{
    return __data;
}

//- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
//- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
//- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request NS_AVAILABLE(10_6, 3_0);
//- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
//- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [__data appendData:data];
    
    if(self.filePath)
    {
        NSInteger       dataLength;
        const uint8_t * dataBytes;
        NSInteger       bytesWritten;
        NSInteger       bytesWrittenSoFar;
        
        //    assert(conn == self.connection);
        
        dataLength = [data length];
        dataBytes  = [data bytes];
        
        bytesWrittenSoFar = 0;
        do
        {
            bytesWritten = [__fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
            assert(bytesWritten != 0);
            if (bytesWritten == -1)
            {
                //            [self _stopReceiveWithStatus:@"File write error"];
                break;
            }
            else
            {
                bytesWrittenSoFar += bytesWritten;
            }
        }
        while (bytesWrittenSoFar != dataLength);
    }
    
    if(self.operationProgressBlock)
    {
        //If its -1 that means the header does not have the content size value
        if(self.expectedContentLength != NSURLResponseUnknownLength)
        {
            self.receivedContentLength += data.length;
            self.operationProgressBlock(self.receivedContentLength/self.expectedContentLength);
        }
        else
        {
            //we dont know the full size so always return -1 as the progress
            self.operationProgressBlock(-1);
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //[NSThread sleepForTimeInterval:5];
    self.expectedContentLength = response.expectedContentLength;
    self.receivedContentLength = 0.0;
    __response = response;
    
    __data = [[NSMutableData alloc] init];
    if(self.filePath)
    {
        __fileStream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:NO];
        [__fileStream open];
    }
    //#pragma unused(theConnection)
    //    NSHTTPURLResponse * httpResponse;
    //    NSString *          contentTypeHeader;
    //
    //    assert(theConnection == self.connection);
    //
    //    httpResponse = (NSHTTPURLResponse *) response;
    //    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    //
    //    if ((httpResponse.statusCode / 100) != 2) {
    //        [self stopReceiveWithStatus:[NSString stringWithFormat:@"HTTP error %zd", (ssize_t) httpResponse.statusCode]];
    //    } else {
    //        // -MIMEType strips any parameters, strips leading or trailer whitespace, and lower cases
    //        // the string, so we can just use -isEqual: on the result.
    //        contentTypeHeader = [httpResponse MIMEType];
    //        if (contentTypeHeader == nil) {
    //            [self stopReceiveWithStatus:@"No Content-Type!"];
    //        } else if ( ! [contentTypeHeader isEqual:@"image/jpeg"]
    //                   && ! [contentTypeHeader isEqual:@"image/png"]
    //                   && ! [contentTypeHeader isEqual:@"image/gif"] ) {
    //            [self stopReceiveWithStatus:[NSString stringWithFormat:@"Unsupported Content-Type (%@)", contentTypeHeader]];
    //        } else {
    //            self.statusLabel.text = @"Response OK.";
    //        }
    //    }
    
}

//- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite

//- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse

//- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.operationCompletionBlock(nil, error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(self.filePath)
        [__fileStream close];
    if(__data && __data.length > 0)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.operationCompletionBlock(__data, nil);
        }];
    }
    //#pragma unused(theConnection)
    //    assert(theConnection == self.connection);
    //
    //    [self stopReceiveWithStatus:nil];
}

- (void)_stopReceiveWithStatus:(NSString *)statusString
// Shuts down the connection and displays the result (statusString == nil)
// or the error status (otherwise).
{
    //    if (self.earlyTimeoutTimer != nil)
    //    {
    //        [self.earlyTimeoutTimer invalidate];
    //        self.earlyTimeoutTimer = nil;
    //    }
    //    if (self.currentChallenge != nil)
    //    {
    //        [self.currentChallenge stop];
    //        self.currentChallenge = nil;
    //    }
    //    if (self.connection != nil)
    //    {
    //        [self.connection cancel];
    //        self.connection = nil;
    //    }
    //    if (self.fileStream != nil)
    //    {
    //        [self.fileStream close];
    //        self.fileStream = nil;
    //    }
    //    [self _receiveDidStopWithStatus:statusString];
    //    self.filePath = nil;
}

- (void)_receiveDidStopWithStatus:(NSString *)statusString
{
    //    if (statusString == nil) {
    //        assert(self.filePath != nil);
    //
    //        self.imageView.image = [UIImage imageWithContentsOfFile:self.filePath];
    //        statusString = @"Get succeeded";
    //    }
    //    [self _updateStatus:statusString];
    //    self.getOrCancelButton.title = @"Get";
    //    [self.activityIndicator stopAnimating];
    //    [[AppDelegate sharedAppDelegate] didStopNetworking];
}

@end

@implementation NSString (URLConnection)

-(NSURLConnection*)postToServerWithParams:(NSDictionary*)params completionHandle:(void (^)(NSData *data, NSError *error)) handle
{
    NSURL *url = [NSURL URLWithString:[self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    
    NSMutableData *body = [NSMutableData data];
    
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString *key in [params keyEnumerator])
    {
        if (!([[params valueForKey:key] isKindOfClass:[NSString class]]))
		{
			continue;
		}
		
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [[params objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	}
    
    [body appendData:[[pairs componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    IoriConnectionDelegate *connDelegate = [[IoriConnectionDelegate alloc] init];
    connDelegate.operationCompletionBlock = handle;
    NSURLConnection *theConnection = [[IoriURLConnection alloc] initWithRequest:request delegate:connDelegate];
    
    return theConnection;

}

-(NSString*)createFolder:(NSString*)dir
{
    if(dir == nil) dir = @"cacheDir";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *strDocumentPath = [NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES ) objectAtIndex:0];
    NSString *strDirFullPath = [strDocumentPath stringByAppendingPathComponent:dir];
    if(![fileManager fileExistsAtPath:strDirFullPath])
    {
        [fileManager createDirectoryAtPath:strDirFullPath withIntermediateDirectories:YES attributes:nil error:nil];
        //[self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:strDirFullPath]];
    }
    return strDirFullPath;
}

-(NSURLConnection*)getDataAndCacheToDir:(NSString*)dirPath competionHandle:(void (^)(NSData* data, NSError* error))handle  progressHandle:(void (^)(float progress))pHandle
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    if (netStatus == NotReachable)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                       {
                           NSFileManager *fileManager = [NSFileManager defaultManager];
                           NSString *strDocumentPath = [NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES ) objectAtIndex:0];
                           NSString *strImageDir = nil;
                           if(dirPath == nil)
                               strImageDir = [strDocumentPath stringByAppendingPathComponent:@"cacheDir"];
                           else
                               strImageDir = [strDocumentPath stringByAppendingPathComponent:dirPath];
                           NSString *strFileName = [self lastPathComponent];
                           NSString *strFilePath = [strImageDir stringByAppendingPathComponent:strFileName];
                           NSData *fileData; NSError *err;
                           if( [fileManager fileExistsAtPath:strFilePath])
                           {
                               fileData = [NSData dataWithContentsOfFile:strFilePath];
                           }
                           else
                           {
                               err = [NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:@
                                      {
                                      NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot connect to the internet. Service may not be avaiable.", @" internet is not avaiable.")
                                      }];
                               
                           }
                           [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                               handle(fileData, err);
                           }];
                       });
        return nil;
    }
    //NSURLConnection *theConnection;
    
    IoriConnectionDelegate *connDelegate = [[IoriConnectionDelegate alloc] init];
    connDelegate.operationCompletionBlock = handle;
    connDelegate.operationProgressBlock = pHandle;
    if(dirPath == nil)
        connDelegate.filePath = [[self createFolder:@"cacheDir"] stringByAppendingPathComponent:[self lastPathComponent]];
    else
        connDelegate.filePath = [[self createFolder:dirPath] stringByAppendingPathComponent:[self lastPathComponent]];
    
    NSURL *url = [NSURL URLWithString:[self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60];
    NSURLConnection *theConnection = [[IoriURLConnection alloc] initWithRequest:request delegate:connDelegate];
    
    return theConnection;
}

//下载文件到指定目录（缓存不会再更新），自动创建指定目录
-(void)getCacheDataDir:(NSString*)fromDirectory completionHandler:(void (^)(NSData*, NSError*)) handle
{
    if(fromDirectory == nil) fromDirectory = @"cacheDir";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *strDocumentPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES ) objectAtIndex:0];
    NSString *strImageDir = [strDocumentPath stringByAppendingPathComponent:fromDirectory];
    if(![fileManager fileExistsAtPath:strImageDir])
    {
        [fileManager createDirectoryAtPath:strImageDir withIntermediateDirectories:YES attributes:nil error:nil];
        //[self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:strImageDir]];
    }
    
    NSString *strFileName = [self lastPathComponent];
    
    if([fileManager fileExistsAtPath:[strImageDir stringByAppendingPathComponent:strFileName]])
    {
        handle([NSData dataWithContentsOfFile:[strImageDir stringByAppendingPathComponent:strFileName]], nil);
    }
    else
    {
        [self getURLData:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                            {
                                [data writeToFile:[strImageDir stringByAppendingPathComponent:strFileName] atomically:YES];
                            });
             
             handle(data, error);
         }];
    }
    
}

//下载文件到指定目录，自动创建指定目录,如果存在则返回真在参数上，不存在会下载
-(void)getCacheFileInDir:(NSString*)fromDirectory isExist:(BOOL*)bExist completionHandler:(void (^)(NSData*, NSString* filePath, NSError*)) handle
{
    if(fromDirectory == nil) fromDirectory = @"cacheDir";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *strDocumentPath = [NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES ) objectAtIndex:0];
    NSString *strImageDir = [strDocumentPath stringByAppendingPathComponent:fromDirectory];
    if(![fileManager fileExistsAtPath:strImageDir])
    {
        [fileManager createDirectoryAtPath:strImageDir withIntermediateDirectories:YES attributes:nil error:nil];
        //[self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:strImageDir]];
    }
    
    NSString *strFileName = [self lastPathComponent];
    NSString *strFilePath = [strImageDir stringByAppendingPathComponent:strFileName];
    
    if([fileManager fileExistsAtPath:strFilePath])
    {
        *bExist = YES;
        if(handle)
            handle([NSData dataWithContentsOfFile:strFilePath], strFilePath, nil);
    }
    else
    {
        [self getURLData:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                            {
                                [data writeToFile:strFilePath atomically:YES];
                            });
             if(handle)
                 handle(data, strFilePath, error);
         }];
    }
}

//直接通过网络下载数据
-(void)getURLData :(void (^)(NSURLResponse* response, NSData* data, NSError* error)) completionHandler
{
    NSURL *url = [NSURL URLWithString:[self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(completionHandler)
             completionHandler(response, data, error);
     }];
}

//如果网络不可用会在缓存目录cachedir中找到同名文件，否则通过网络下载文件到cachedir中
-(void)getURLDataIfNoInternet:(void (^)(NSURLResponse *response, NSData *data, NSError *error))completionHandler
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    if (netStatus == NotReachable)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                       {
                           NSFileManager *fileManager = [NSFileManager defaultManager];
                           NSString *strDocumentPath = [NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES ) objectAtIndex:0];
                           NSString *strImageDir = [strDocumentPath stringByAppendingPathComponent:@"cacheDir"];
                           NSString *strFileName = [self lastPathComponent];
                           NSString *strFilePath = [strImageDir stringByAppendingPathComponent:strFileName];
                           NSData *fileData; NSError *err;
                           if( [fileManager fileExistsAtPath:strFilePath])
                           {
                               fileData = [NSData dataWithContentsOfFile:strFilePath];
                           }
                           else
                           {
                               err = [NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:@
                                      {
                                      NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot connect to the internet. Service may not be avaiable.", @" internet is not avaiable.")
                                      }];
                               
                           }
                           [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                               completionHandler(nil, fileData, err);
                           }];
                       });
    }
    else
    {
        [self getURLData:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                            {
                                if(data == nil) return;
                                NSFileManager *fileManager = [NSFileManager defaultManager];
                                NSString *strDocumentPath = [NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES ) objectAtIndex:0];
                                NSString *strImageDir = [strDocumentPath stringByAppendingPathComponent:@"cacheDir"];
                                if(![fileManager fileExistsAtPath:strImageDir])
                                {
                                    [fileManager createDirectoryAtPath:strImageDir withIntermediateDirectories:YES attributes:nil error:nil];
                                    //[self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:strImageDir]];
                                }
                                NSString *strFileName = [self lastPathComponent];
                                NSString *strFilePath = [strImageDir stringByAppendingPathComponent:strFileName];
                                [data writeToFile:strFilePath atomically:YES];
                            });
             completionHandler(response, data, error);
         }];
    }
}

//使用post方式上传数据到服务器
-(void)postToServer:(NSString*)strURL bodyPairs:(NSDictionary*)params completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*)) handle
{
    NSURL *url = [NSURL URLWithString:[strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    
    NSMutableData *body = [NSMutableData data];
    
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString *key in [params keyEnumerator])
    {
        if (!([[params valueForKey:key] isKindOfClass:[NSString class]]))
		{
			continue;
		}
		
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [[params objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	}
    
    [body appendData:[[pairs componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
#if DEBUG
         NSLog(@"data:%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
#endif
         handle(response, data, error);
     }];
    
}

//同步保存文件到指定的目录中
-(BOOL)saveFileSyncToDirWithData:(NSString*)dirName fileData:(NSData*)data fileFullFilePath:(NSString **)strFullFilePath error:(NSError **)err;
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *strDocumentPath = [NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES ) objectAtIndex:0];
    NSString *strPath = [strDocumentPath stringByAppendingPathComponent:dirName];
    if(![fileManager fileExistsAtPath:strPath])
    {
        [fileManager createDirectoryAtPath:strPath withIntermediateDirectories:YES attributes:nil error:nil];
        //[self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:strPath]];
    }
    NSString *strFileName = [self lastPathComponent];
    NSString *strFilePath = [strPath stringByAppendingPathComponent:strFileName];
    *strFullFilePath = strFilePath;
    BOOL bSucccess  = [data writeToFile:strFilePath options:NSDataWritingAtomic error:err];
    return bSucccess;
}

//异步保存文件到指定目录中
-(void)saveFileASyncToDirWithData:(NSString*)dirName fileData:(NSData*)data completionHandle:(void (^)(NSString* filePath, BOOL bWriteSuccess, NSError *error)) handle
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSError *err = nil;
                       NSString *strFullPath = nil;
                       BOOL bSuccess = [self saveFileSyncToDirWithData:dirName fileData:data fileFullFilePath:&strFullPath error:&err];
                       handle(strFullPath, bSuccess, err);
                   });
}

-(BOOL)isURLConnectionOK:(NSError __strong *)err
{
    NSURLResponse *response=nil;
    NSData *data = nil;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    NSError *__autoreleasing temperr = err;
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&temperr];
    if(temperr) err = [temperr copy]; //no effect.
    if(data == nil)
    {
        return NO;
    }
    return YES;
}

//判断当前URL是否畅通
-(BOOL)isReachableURLWithError:(NSError**)err
{
    NSURLResponse *response=nil;
    NSData *data = nil;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:err];
    
    if(data == nil)
    {
        return NO;
    }
    return YES;
}

-(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    //assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success)
    {
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

@end
