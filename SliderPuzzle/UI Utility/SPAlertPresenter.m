//
//  SPAlertPresenter.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 4/05/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "SPAlertPresenter.h"
#import <SIAlertView/SIAlertView.h>

@implementation SPAlertPresenter

+ (instancetype)sharedInstance
{
    static SPAlertPresenter *singleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[SPAlertPresenter alloc] init];
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
