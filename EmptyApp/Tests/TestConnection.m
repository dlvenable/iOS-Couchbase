//
//  TestConnection.m
//  Empty App
//
//  Created by Jens Alfke on 11/11/11.
//  Copyright (c) 2011 CouchBase, Inc. All rights reserved.
//

#import "TestConnection.h"
#import <Couchbase/CouchbaseMobile.h>


extern CouchbaseMobile* sCouchbase;  // Defined in EmptyAppDelegate.m


@implementation TestConnection


- (id) initWithMethod: (NSString*)method
                 path: (NSString*)relativePath
                 body: (NSString*)body
{
    self = [super init];
    if (self) {
        NSURL* url = [NSURL URLWithString: relativePath relativeToURL: sCouchbase.serverURL];
        _request = [[NSMutableURLRequest alloc] initWithURL: url];
        _request.HTTPMethod = method;
        _request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
        if (body) {
            _request.HTTPBody = [body dataUsingEncoding: NSUTF8StringEncoding];
            [_request addValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
        }
        _responseBody = [[NSMutableData alloc] init];
    }
    return self;
}

+ (TestConnection*) connectionWithMethod: (NSString*)method
                                    path: (NSString*)relativePath
                                    body: (NSString*)body
{
    return [[[self alloc] initWithMethod: method path: relativePath body: body] autorelease];
}


- (void)dealloc {
    [_request release];
    [_response release];
    [_error release];
    [_responseBody release];
    [super dealloc];
}


@synthesize response=_response, responseBody=_responseBody, error=_error;

- (NSURL*) URL {
    return _request.URL;
}

- (NSString*) responseString {
    return [[[NSString alloc] initWithData: _responseBody encoding: NSUTF8StringEncoding]
                autorelease];
}


- (BOOL) run
{
    NSAssert(!_response && !_error, @"Can't call -run twice");
    _loading = YES;
    NSURLConnection* connection = [NSURLConnection connectionWithRequest: _request delegate: self];
    [connection start];
    while (_loading) {
        if (![[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode
                                      beforeDate: [NSDate distantFuture]])
            break;
    }
    return _error == nil && _response && _response.statusCode < 300;
}


- (void)connection:(NSURLConnection *)connection
        didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if (challenge.previousFailureCount == 0) {
        NSURLCredential* credential = sCouchbase.adminCredential;
        if (credential) {
            [challenge.sender useCredential: credential forAuthenticationChallenge: challenge];
            return;
        }
    }
    // give up
    [challenge.sender cancelAuthenticationChallenge: challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _response = (NSHTTPURLResponse*) [response retain];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseBody appendData: data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _error = [error retain];
    _loading = NO;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    _loading = NO;
}


@end
