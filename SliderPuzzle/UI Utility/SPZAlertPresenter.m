//
//  SPAlertPresenter.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 4/05/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "SPZAlertPresenter.h"
#import <SIAlertView/SIAlertView.h>

@implementation SPZAlertPresenter

+ (instancetype)sharedInstance
{
    static SPZAlertPresenter *singleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[SPZAlertPresenter alloc] init];
    });
    return singleton;
}

- (void)showAlertMessage:(NSString*)message
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Squarez" andMessage:message];
    
    [alertView addButtonWithTitle:@"OK"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alert) {
                              // do nothing
                          }];
    
    alertView.transitionStyle = SIAlertViewTransitionStyleFade;
    
    [alertView show];

}

@end
