//
//  SPTileMotionHandler.h
//  SliderPuzzle
//
//  Created by HENRY CHAN on 22/06/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreMotion;

@interface SPZTileMotionHandler : NSObject

@property(nonatomic, strong) CMMotionManager *motionManager;

@end
