//
//  AWSCognitoUserPoolsSignInProvider.m
//
// Copyright 2016 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to
// copy, distribute and modify it.
//

#import "AWSCognitoUserPoolsSignInProvider.h"
#import "AWSIdentityManager.h"
#import <AWSCognitoIdentityProvider/AWSCognitoIdentityProvider.h>

NSString *const AWSCognitoUserPoolsSignInProviderKey = @"CognitoUserPools";
static NSString *const AWSCognitoUserPoolsSignInProviderUserNameKey = @"CognitoUserPools.userName";
static NSString *const AWSCognitoUserPoolsSignInProviderImageURLKey = @"CognitoUserPools.imageURL";


typedef void (^AWSIdentityManagerCompletionBlock)(id result, NSError *error);

@interface AWSIdentityManager()

- (void)completeLogin;

@end

@interface AWSCognitoUserPoolsSignInProvider()

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) UIViewController *signInViewController;
@property (atomic, copy) AWSIdentityManagerCompletionBlock completionHandler;
@property (strong, nonatomic) id<AWSCognitoUserPoolsSignInHandler> interactiveAuthenticationDelegate;

@end

@implementation AWSCognitoUserPoolsSignInProvider

static NSString *idpName;

+ (void)setupUserPoolWithId:(NSString *)cognitoIdentityUserPoolId
cognitoIdentityUserPoolAppClientId:(NSString *)cognitoIdentityUserPoolAppClientId
cognitoIdentityUserPoolAppClientSecret:(NSString *)cognitoIdentityUserPoolAppClientSecret
                        region:(AWSRegionType)region{
    AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:region credentialsProvider:nil];
    AWSCognitoIdentityUserPoolConfiguration *configuration = [[AWSCognitoIdentityUserPoolConfiguration alloc]
                                                              initWithClientId:cognitoIdentityUserPoolAppClientId
                                                              clientSecret:cognitoIdentityUserPoolAppClientSecret
                                                              poolId:cognitoIdentityUserPoolId];
    [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:configuration forKey:AWSCognitoUserPoolsSignInProviderKey];
    
    idpName = [[NSString alloc] initWithFormat:@"cognito-idp.%@.amazonaws.com/%@", [cognitoIdentityUserPoolId componentsSeparatedByString:@"_"][0], cognitoIdentityUserPoolId ];
    
}

+ (instancetype)sharedInstance {
    if (![AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:AWSCognitoUserPoolsSignInProviderKey]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"User Pool not registered. The method `setupUserPoolWithId:cognitoIdentityUserPoolAppClientId:cognitoIdentityUserPoolAppClientSecret:region` has to be called once before accessing the shared instance."
                                     userInfo:nil];
        return nil;
    }
    static AWSCognitoUserPoolsSignInProvider *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[AWSCognitoUserPoolsSignInProvider alloc] init];
    });
    
    return _sharedInstance;
}

- (AWSCognitoIdentityUserPool *)getUserPool {
    return [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:AWSCognitoUserPoolsSignInProviderKey];
}

- (void)setViewControllerForUserPoolsSignIn:(UIViewController *)signInViewController {
    self.signInViewController = signInViewController;
}


#pragma mark - AWSIdentityProvider

- (NSString *)identityProviderName {
    return idpName;
}

- (AWSTask<NSString *> *)token {
    AWSCognitoIdentityUserPool *pool = [self getUserPool];
    return [[[pool currentUser] getSession] continueWithSuccessBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserSession *> * _Nonnull task) {
        return [AWSTask taskWithResult:task.result.idToken.tokenString];
    }];
}

- (BOOL)isLoggedIn {
    AWSCognitoIdentityUserPool *pool = [self getUserPool];
    return [pool.currentUser isSignedIn];
}

- (NSString *)userName {
    return [[NSUserDefaults standardUserDefaults] objectForKey:AWSCognitoUserPoolsSignInProviderUserNameKey];
}

- (void)setUserName:(NSString *)userName {
    [[NSUserDefaults standardUserDefaults] setObject:userName
                                              forKey:AWSCognitoUserPoolsSignInProviderUserNameKey];
}

- (NSURL *)imageURL {
    return [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:AWSCognitoUserPoolsSignInProviderImageURLKey]];
}

- (void)setImageURL:(NSURL *)imageURL {
    [[NSUserDefaults standardUserDefaults] setObject:imageURL.absoluteString
                                              forKey:AWSCognitoUserPoolsSignInProviderImageURLKey];
}

- (void)reloadSession {
    if ([self isLoggedIn]) {
        [self completeLogin];
    }
}

- (void)completeLogin {
    [self setUserName:[[[self getUserPool] currentUser] username]]; // set user name as name
    [[AWSIdentityManager defaultIdentityManager] completeLogin];
    
}

- (void)setInteractiveAuthDelegate:(id)interactiveAuthDelegate {
    self.interactiveAuthenticationDelegate = interactiveAuthDelegate;
    [self getUserPool].delegate = interactiveAuthDelegate;
}

- (void)login:(AWSIdentityManagerCompletionBlock) completionHandler {
    self.completionHandler = completionHandler;
    AWSCognitoIdentityUserPool *pool = [self getUserPool];
    [[pool.getUser getSession] continueWithSuccessBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserSession *> * _Nonnull task) {
        [self completeLogin];
        return nil;
    }];
    [self.interactiveAuthenticationDelegate handleUserPoolSignInFlowStart];
}

- (void)logout {
    AWSCognitoIdentityUserPool *pool = [self getUserPool];
    [pool.currentUser signOut];
}

- (BOOL)interceptApplication:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (BOOL)interceptApplication:(UIApplication *)application
                     openURL:(NSURL *)url
           sourceApplication:(NSString *)sourceApplication
                  annotation:(id)annotation {

    return YES;
}

@end
