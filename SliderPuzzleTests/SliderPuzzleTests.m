//
//  SliderPuzzleTests.m
//  SliderPuzzleTests
//
// Unit tests for SPTile
//
//  Created by HENRY CHAN on 9/01/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SPZTile.h"

@interface SliderPuzzleTests : XCTestCase

@end

@implementation SliderPuzzleTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSPTileHasXIntersect
{
    SPZTile *tile1 = [[SPZTile alloc] init];
    tile1.xPos = 0;
    tile1.yPos = 0;
    
    SPZTile *tile2 = [[SPZTile alloc] init];
    tile2.xPos = 0;
    tile2.yPos = 2;

    XCTAssertTrue([tile1 hasXPosIntersect:tile2], @"Should have X intersect.");
    XCTAssertTrue([tile1 hasIntersect:tile2], @"Should have intersect.");
}

- (void)testSPTileHasYIntersect
{
    SPZTile *tile1 = [[SPZTile alloc] init];
    tile1.xPos = 0;
    tile1.yPos = 1;
    
    SPZTile *tile2 = [[SPZTile alloc] init];
    tile2.xPos = 2;
    tile2.yPos = 1;
    
    XCTAssertTrue([tile1 hasYPosIntersect:tile2], @"Should have Y intersect.");
    XCTAssertTrue([tile1 hasIntersect:tile2], @"Should have intersect.");
}

@end
