//
//  SPAlertPresenter.h
//  SliderPuzzle
//
//  Created by HENRY CHAN on 4/05/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPAlertPresenter : NSObject

+ (instancetype)sharedInstance;

- (void)showAlertMessage:(NSString*)message;

@end
