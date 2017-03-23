//
//  AWSSignInManager.h
//  AWSMobileHubHelper
//
// Copyright 2016 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to
// copy, distribute and modify it.
//

#import <Foundation/Foundation.h>
#import "AWSSignInProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWSSignInManager : NSObject

/**
 * Indicates whether the user is signed-in or not.
 * @return true if user is signed-in
 */
@property (nonatomic, readonly, getter=isLoggedIn) BOOL loggedIn;

// Fetches the shared instance of `AWSSignInManager`.
+(instancetype)sharedInstance;

/**
 Registers the shared instance of sign in provider implementing `AWSSignInProvider`.
 
 @param  signInProvider    The shared instance of sign in provider implementing `AWSSignInProvider` protocol.
 **/
-(void)registerAWSSignInProvider:(id<AWSSignInProvider>)signInProvider NS_SWIFT_NAME(register(signInProvider:));

/**
 * Signs the user out of whatever third party identity provider they used to sign in.
 * @param completionHandler used to callback application with async operation results
 */
- (void)logoutWithCompletionHandler:(void (^)(id _Nullable result, AWSAuthState authState, NSError * _Nullable error))completionHandler;

/**
 * Signs the user in with an identity provider. Note that even if User Sign-in is not
 * enabled in the project, the user is still signed-in with the Guest type provider.
 * @param signInProviderKey the identifier key of sign in provider
 * @param completionHandler used to callback application with async operation results
 */
- (void)loginWithSignInProviderKey:(NSString *)signInProviderKey
                 completionHandler:(void (^)(id _Nullable result, AWSAuthState authState, NSError * _Nullable error))completionHandler NS_SWIFT_NAME(login(signInProviderKey:completionHandler:));

/**
 * Attempts to resume session with the previous sign-in provider.
 * @param completionHandler used to callback application with async operation results
 */
- (void)resumeSessionWithCompletionHandler:(void (^)(id _Nullable result, AWSAuthState authState, NSError * _Nullable error))completionHandler;

/**
 * Passes parameters used to launch the application to the current identity provider. For some
 * third party providers, this completes the User Sign-in call flow, which used a browser to
 * get information from the user, directly. The current sign-in provider will be set to nil if
 * the sign-in provider is not registered using `registerAWSSignInProvider:forKey` method  of
 * `AWSSignInProviderFactory` class.
 * @param application application
 * @param launchOptions options used to launch the application
 * @return true if this call handled the operation
 */
- (BOOL)interceptApplication:(UIApplication *)application
didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions;

/**
 * Passes parameters used to launch the application to the current identity provider. For some
 * third party providers, this completes the User Sign-in call flow, which used a browser to
 * get information from the user, directly.
 * @param application application
 * @param url url used to open the application
 * @param sourceApplication source application
 * @param annotation annotation
 * @return true if this call handled the operation
 */
- (BOOL)interceptApplication:(UIApplication *)application
                     openURL:(NSURL *)url
           sourceApplication:(nullable NSString *)sourceApplication
                  annotation:(id)annotation;

@end

NS_ASSUME_NONNULL_END
