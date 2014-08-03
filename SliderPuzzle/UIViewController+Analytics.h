//
//  UIViewController+Analytics.h
//  SliderPuzzle
//
//  Created by HENRY CHAN on 3/08/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Analytics)

- (void)logWithCategory:(NSString*)category action:(NSString*)action label:(NSString*)label;

@end
