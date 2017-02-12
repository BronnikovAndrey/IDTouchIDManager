//
//  IDTouchIDManager.m
//  SMSFinance
//
//  Created by Андрей on 11.01.17.
//  Copyright © 2017 ImproveGroup. All rights reserved.
//

#import "IDTouchIDManager.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface IDTouchIDManager ()

@property (nonatomic, strong) LAContext *authenticationContext;
@property (nonatomic, strong) UIViewController *sharedView;

@property (nonatomic, strong) NSError *lastError;

@end

@implementation IDTouchIDManager

#pragma mark - Initializators
- (instancetype)init {
    self = [super init];
    if (self) {
        self.authenticationContext = [[LAContext alloc] init];
    }
    return self;
}

- (instancetype)initWithDelegate: (id<IDTouchIDManagerProtocol>) delegate {
    self = [super init];
    if (self) {
        self.authenticationContext = [[LAContext alloc] init];
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - Interface
- (void)tryToPass {
    
    if (self.isTouchIDAvailable && self.isTouchIDAllowed) {
        
        NSString *localizedReason = nil;
        if ([self.delegate respondsToSelector:@selector(textForAlertDescriptionWithTouchIDManager:)]) {
            localizedReason = [self.delegate performSelector:@selector(textForAlertDescriptionWithTouchIDManager:) withObject:self];
        }
        
        [self.authenticationContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                   localizedReason:localizedReason
                                             reply:^(BOOL success, NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^
                            {
                                if (success) {
                                    if ([self.delegate respondsToSelector:@selector(didPassSuccessfullyWithTouchIDManager:)]) {
                                        [self.delegate performSelector:@selector(didPassSuccessfullyWithTouchIDManager:) withObject:self];
                                    }
                                } else {
                                    [self sendFailWithError:error];
                                }
                            });
         }];
    }
    else {
        NSString *errorText = @"TouchID unavailable for inknown reason";
        NSError *error = [NSError errorWithDomain:SFErrorDomain
                                             code:kTIDMErrorUnknown
                                         userInfo:@{errorText : NSLocalizedDescriptionKey}];
        [self sendFailWithError:error];
    }
}

- (BOOL)isTouchIDAvailable {
    NSError *error = nil;
    BOOL canEvaluatePolicyBiometrics = [self.authenticationContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    if (canEvaluatePolicyBiometrics) {
        return YES;
    }
    else {
        [self sendFailWithError:error];
        return NO;
    }
}

- (BOOL)isTouchIDAllowed {
    BOOL isTouchIDAllowed = YES;
    if ([self.delegate respondsToSelector:@selector(willTryToPassWithTouchIDManager:)]) {
        isTouchIDAllowed = [self.delegate willTryToPassWithTouchIDManager:self];
    }
    if (!isTouchIDAllowed) {
        NSString *errorText = [NSString stringWithFormat:@"You have blocked touchID with %@", NSStringFromSelector(@selector(willTryToPassWithTouchIDManager:))];
        NSError *error = [NSError errorWithDomain:SFErrorDomain
                                             code:kTIDMErrorBlockedWithStartPassing
                                         userInfo:@{errorText : NSLocalizedDescriptionKey}];
        [self sendFailWithError:error];
    }
    return isTouchIDAllowed;
}


#pragma mark - Helpers
- (void)sendFailWithError: (NSError *)error {
    if (![self errorDidSend: error]) {
        if ([self.delegate respondsToSelector:@selector(touchIDManager:didFailPassWithError:)]) {
            [self.delegate performSelector:@selector(touchIDManager:didFailPassWithError:) withObject:self withObject:error];
        }
        self.lastError = nil;
    }
}

- (BOOL)errorDidSend: (NSError *)error {
    if (self.lastError.code == error.code) {
        return YES;
    }
    self.lastError = error;
    return NO;
}

@end
