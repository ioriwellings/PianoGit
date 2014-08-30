//
//  SoapUtil.h
//  HttpRequest
//
//  Created by zhengyw on 14-8-26.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface WebService : NSObject




+(ASIHTTPRequest *)getASISOAP11Request:(NSString*) WebURL
                        webServiceFile:(NSString*) wsFile
                          xmlNameSpace:(NSString*) xmlNS
                        webServiceName:(NSString*) wsName
                          wsParameters:(NSMutableArray*) wsParas;


+(NSString*)getSOAP11WebServiceResponse:(NSString*) WebURL
                         webServiceFile:(NSString*) wsFile
                           xmlNameSpace:(NSString*) xmlNS
                         webServiceName:(NSString*) wsName
                           wsParameters:(NSMutableArray*) wsParas;


+(NSString*)getSOAP11WebServiceResponseWithNTLM:(NSString*) WebURL
                                 webServiceFile:(NSString*) wsFile
                                   xmlNameSpace:(NSString*) xmlNS
                                 webServiceName:(NSString*) wsName
                                   wsParameters:(NSMutableArray*) wsParas
                                       userName:(NSString*) userName
                                       passWord:(NSString*) passWord;


+(NSString*)checkResponseError:(NSString*) theResponse;


@end
