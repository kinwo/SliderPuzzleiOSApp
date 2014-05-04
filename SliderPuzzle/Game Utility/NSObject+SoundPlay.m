//
//  NSObject+SoundPlay.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 3/05/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "NSObject+SoundPlay.h"
#import "SKTAudio.h"

@implementation NSObject (SoundPlay)

- (void)playButtonPressed
{
    [[SKTAudio sharedInstance] playSoundEffect:@"button_press.wav"];
}

@end
