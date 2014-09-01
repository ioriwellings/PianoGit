
//
//  NSString+URLConnection.h
//  Moko
//
//  Created by Iori Yang on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLConnection)

-(NSURLConnection*)postToServerWithParams:(NSDictionary*)param completionHandle:(void (^)(NSData *data, NSError *error)) handle;

-(NSURLConnection*)getDataAndCacheToDir:(NSString*)dirPath competionHandle:(void (^)(NSData* data, NSError* error))handle  progressHandle:(void (^)(float progress))pHandle;
-(void)getCacheDataDir:(NSString*)fromDirectory completionHandler:(void (^)(NSData *data, NSError *error)) handle;
-(void)getCacheFileInDir:(NSString*)fromDirectory isExist:(BOOL*)bExist completionHandler:(void (^)(NSData *data, NSString* filePath, NSError *error)) handle;
-(void)getURLData:(void (^)(NSURLResponse *response, NSData *data, NSError *error)) completionHandler;
-(void)getURLDataIfNoInternet:(void (^)(NSURLResponse *response, NSData *data, NSError *err))completionHandler;
-(void)postToServer:(NSString*)strURL bodyPairs:(NSDictionary*)params completionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *error)) handle;
-(BOOL)saveFileSyncToDirWithData:(NSString*)dirName fileData:(NSData*)data fileFullFilePath:(NSString **)strFullFilePath error:(NSError **)err;
-(void)saveFileASyncToDirWithData:(NSString*)dirName fileData:(NSData*)data completionHandle:(void (^)(NSString* filePath, BOOL bWriteSuccess, NSError *error)) handle;

-(BOOL)isURLConnectionOK:(NSError __strong *)err;
-(BOOL)isReachableURLWithError:(NSError**)err;
@end
