//
//  IDTouchIDManager.h
//  SMSFinance
//
//  Created by Андрей on 11.01.17.
//  Copyright © 2017 ImproveGroup. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol IDTouchIDManagerProtocol;

static NSInteger const kTIDMErrorUnknown = -100;
static NSInteger const kTIDMErrorBlockedWithStartPassing = -101;


@interface IDTouchIDManager : NSObject


- (instancetype)initWithDelegate: (id<IDTouchIDManagerProtocol>) delegate;
@property (weak, nonatomic) id<IDTouchIDManagerProtocol> delegate;

- (void)tryToPass;
@property (assign, nonatomic, readonly) BOOL isTouchIDAvailable;

/* willTryToPassWithTouchIDManager: */
@property (assign, nonatomic, readonly) BOOL isTouchIDAllowed;

@end


@protocol IDTouchIDManagerProtocol <NSObject>


- (NSString *)textForAlertDescriptionWithTouchIDManager: (IDTouchIDManager *)touchIDManager;

- (BOOL)willTryToPassWithTouchIDManager: (IDTouchIDManager *)touchIDManager;
- (void)didPassSuccessfullyWithTouchIDManager: (IDTouchIDManager *)touchIDManager;
- (void)touchIDManager: (IDTouchIDManager *)touchIDManager didFailPassWithError: (NSError *)error;

@end
