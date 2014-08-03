//
//  UIViewController+Analytics.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 3/08/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "UIViewController+Analytics.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@implementation UIViewController (Analytics)

- (void)logWithCategory:(NSString*)category action:(NSString*)action label:(NSString*)label
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category     // Event category (required)
                                                          action:action  // Event action (required)
                                                           label:label          // Event label
                                                           value:nil] build]];    // Event value
}

@end
