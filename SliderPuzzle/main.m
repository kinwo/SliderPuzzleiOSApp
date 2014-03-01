//
//  main.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 9/01/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SPAppDelegate.h"
#import <PixateFreestyle/PixateFreestyle.h>

int main(int argc, char * argv[])
{
    @autoreleasepool {
        [PixateFreestyle initializePixateFreestyle];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([SPAppDelegate class]));
    }
}
