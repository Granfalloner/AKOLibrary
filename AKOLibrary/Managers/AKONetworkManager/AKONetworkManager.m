//
//  AKONetworkManager.m
//  AKOLibrary
//
//  Created by Adrian on 4/15/11.
//  Copyright (c) 2009, 2010, 2011, Adrian Kosmaczewski & akosma software
//  All rights reserved.
//  
//  Use in source and/or binary forms without modification is permitted following the
//  instructions in the LICENSE file.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
//  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
//  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
//  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
//  OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "AKONetworkManager.h"
#import "AKOLibrary_Managers_notifications.h"
#import "SynthesizeSingleton.h"
#import "AKOBaseRequest.h"
#import "Reachability.h"

@interface AKONetworkManager ()

@property (nonatomic, strong) id reachabilityObserver;
@property (nonatomic, strong) NSOperationQueue *networkQueue;
@property (nonatomic, retain) Reachability *reachability;
@property (nonatomic, assign) NSNotificationCenter *notificationCenter;

- (void)requestSuccess:(AKOBaseRequest *)request response:(id)responseObject;
- (void)requestFailure:(AKOBaseRequest *)request error:(NSError *)error;

@end


@implementation AKONetworkManager

SYNTHESIZE_SINGLETON_FOR_CLASS(AKONetworkManager)

@synthesize networkQueue = _networkQueue;
@synthesize notificationCenter = _notificationCenter;
@synthesize reachability = _reachability;
@synthesize connectivity = _connectivity;
@synthesize reachabilityObserver = _reachabilityObserver;

- (id)init
{
    self = [super init];
    if (self)
    {
        _notificationCenter = [NSNotificationCenter defaultCenter];
        _networkQueue = [[NSOperationQueue alloc] init];
        
        NSString *hostname = [self baseHostname];
        NSAssert(hostname, @"You have to implement baseHostname in your subclass!");
        _reachability = [[Reachability reachabilityWithHostName:hostname] retain];
        
        void(^block)(NSNotification *) = ^(NSNotification *notification){
            self.connectivity = (AKONetworkManagerConnectivity)[self.reachability currentReachabilityStatus];
            
            [self.notificationCenter postNotificationName:AKONetworkManagerConnectivityChangedNotification
                                                   object:self];
            
            
            switch (self.connectivity) 
            {
                case AKONetworkManagerConnectivityNone:
                    [self.networkQueue cancelAllOperations];
                    break;
                    
                case AKONetworkManagerConnectivityWifi:
                    self.networkQueue.maxConcurrentOperationCount = 8;
                    break;
                    
                case AKONetworkManagerConnectivityMobile:
                    self.networkQueue.maxConcurrentOperationCount = 4;
                    break;
                    
                default:
                    break;
            }
        };
        
        _reachabilityObserver = [[_notificationCenter addObserverForName:kReachabilityChangedNotification 
                                                                  object:_reachability 
                                                                   queue:nil
                                                              usingBlock:block] retain];
        
        _connectivity = (AKONetworkManagerConnectivity)[self.reachability currentReachabilityStatus];
        [_reachability startNotifier];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:_reachabilityObserver];
    [_reachability release];
    [_networkQueue release];
    [_reachabilityObserver release];
    [super dealloc];
}

#pragma mark - Methods to override

- (NSString *)baseHostname
{
    return nil;
}

#pragma mark - Public methods

- (void)sendRequest:(AKOBaseRequest *)request
{
    if (self.connectivity != AKONetworkManagerConnectivityNone)
    {
        void(^success)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation* operation, id responseObject) {
            [self requestSuccess:(AKOBaseRequest *)operation 
                        response:responseObject];
        };
        
        void(^error)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation* operation, NSError *error) {
            [self requestFailure:(AKOBaseRequest *)operation 
                           error:error];
        };

        [request setCompletionBlockWithSuccess:success
                                       failure:error];

        [self.networkQueue addOperation:request];
    }
}

- (void)notifyError:(NSError *)error forURL:(NSURL *)url
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:error, AKONetworkManagerErrorKey,
                              url, AKONetworkManagerURLKey, nil];
    NSNotification *notif = [NSNotification notificationWithName:AKONetworkManagerDidFailWithErrorNotification 
                                                          object:self 
                                                        userInfo:userInfo];
    [self.notificationCenter postNotification:notif];    
}

- (void)clearCache
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

#pragma mark - Request callback methods

- (void)requestSuccess:(AKOBaseRequest *)request response:(id)responseObject
{
    NSInteger code = [request.response statusCode];
    
    if (code == 200)
    {
        [request handleResponse];
    }
    else if (code >= 500)
    {
        NSError *error = [NSError errorWithDomain:@"Server error" code:code userInfo:nil];
        NSURL *url = [request.request URL];
        [self notifyError:error forURL:url];
    }
}

- (void)requestFailure:(AKOBaseRequest *)request error:(NSError *)error
{
    NSURL *url = [request.request URL];
    [self notifyError:error 
               forURL:url];
}

@end
