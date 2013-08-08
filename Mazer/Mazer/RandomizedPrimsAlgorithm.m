//
//  RandomizedPrimsAlgorithm.m
//  Mazer
//
//  Created by Tom Adriaenssen on 07/08/13.
//  Copyright (c) 2013 Tom Adriaenssen. All rights reserved.
//

#import "RandomizedPrimsAlgorithm.h"
#import "Maze.h"

@implementation RandomizedPrimsAlgorithm

- (void)executeWithWidth:(uint)width height:(uint)height startingRow:(uint)inRow removeWall:(void(^)(uint fx, uint fy, uint tx, uint ty))removeWall callback:(void(^)(void))callback {
    NSMutableDictionary* cells = [NSMutableDictionary dictionaryWithCapacity:width * height];
    NSMutableDictionary* walls = [NSMutableDictionary dictionary];
    
    cells[@(inRow * width)] = @YES;
    [self addWalls:walls forCell:0 :inRow width:width height:height];
    
    while (walls.count) {
        int index = arc4random() % walls.allKeys.count;
        NSString* wallIndex = walls.allKeys[index];
        [walls removeObjectForKey:wallIndex];
        
        uint x, y;
        SPLIT(END(wallIndex), x, y);
        
        if (cells[@(y * width + x)])
            continue;

        uint fx, fy;
        SPLIT(START(wallIndex), fx, fy);

        removeWall(fx, fy, x, y);
        
        cells[@(y * width + x)] = @YES;
        [self addWalls:walls forCell:x :y width:width height:height];
        
        callback();
    }
}

- (void)addWalls:(NSMutableDictionary*)walls forCell:(int)x :(int)y width:(int)width height:(int)height {
    if (x > 0) {
        walls[WALL(x, y, x-1, y)] = @YES;
    }
    
    if (x < width - 1) {
        walls[WALL(x, y, x+1, y)] = @YES;
    }
    
    if (y > 0) {
        walls[WALL(x, y, x, y-1)] = @YES;
    }
    
    if (y < height - 1) {
        walls[WALL(x, y, x, y+1)] = @YES;
    }
}

@end
