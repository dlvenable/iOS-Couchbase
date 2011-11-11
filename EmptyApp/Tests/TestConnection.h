//
//  TestConnection.h
//  Empty App
//
//  Created by Jens Alfke on 11/11/11.
//  Copyright (c) 2011 CouchBase, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/** A simple class that sends synchronous HTTP requests using NSURLConnection. */
@interface TestConnection : NSObject <NSURLConnectionDataDelegate>
{
    NSMutableURLRequest* _request;
    NSHTTPURLResponse* _response;
    NSMutableData* _responseBody;
    NSError* _error;
    BOOL _loading;
}

+ (TestConnection*) connectionWithMethod: (NSString*)method
                                    path: (NSString*)relativePath
                                    body: (NSString*)body;

@property (readonly) NSURL* URL;

- (BOOL) run;

@property (readonly) NSHTTPURLResponse* response;
@property (readonly) NSData* responseBody;
@property (readonly) NSString* responseString;
@property (readonly) NSError* error;

@end
