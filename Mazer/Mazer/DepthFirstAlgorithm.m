//
//  RandomizedKruskalsAlgorithm.m
//  Mazer
//
//  Created by Tom Adriaenssen on 08/08/13.
//  Copyright (c) 2013 Tom Adriaenssen. All rights reserved.
//

#import "DepthFirstAlgorithm.h"

#define KEY(cx, cy) (@((uint)(cy * width + cx)))
#define XY(index, x, y) ({ int i = (index); y = i/width; x = i - y*width;})

@implementation DepthFirstAlgorithm {
    CGFloat _stretchFactor;
    uint _stretchLeft, _stretchDirection;
}

- (id)init {
    if ((self = [self initWithStretchFactor:0.1])) {
    }
    return self;
}

- (id)initWithStretchFactor:(CGFloat)stretchFactor {
    if ((self = [super init])) {
        _stretchFactor = MIN(MAX(0, stretchFactor), 1);
    }
    return self;
}

- (void)executeWithWidth:(uint)width height:(uint)height startingRow:(uint)inRow removeWall:(void (^)(uint, uint, uint, uint))removeWall callback:(void (^)(void))callback {
    NSMutableDictionary* unvisitedCells = [NSMutableDictionary dictionaryWithCapacity:width * height];
    NSMutableArray* stack = [NSMutableArray array];

    for (uint x=0; x < width; ++x) {
        for (uint y=0; y < height; ++y) {
            unvisitedCells[KEY(x, y)] = @YES;
        }
    }

    _stretchDirection = 0;
    _stretchLeft = 0;

    // start at inrow cell
    uint cx = 0, cy = inRow;
    [unvisitedCells removeObjectForKey:KEY(cx, cy)]; // mark it visited

    while (unvisitedCells.count > 0) {
        NSNumber* neighbour = [self unvisitedNeighbourAt:cx :cy width:width height:height cells:unvisitedCells];
        if (neighbour) {
            uint index = [neighbour unsignedIntegerValue];
            uint tx, ty;
            XY(index, tx, ty);
            // add current cell to stack
            [stack addObject:KEY(cx, cy)];
            // remove wall
            removeWall(cx, cy, tx, ty);
            // make it current cell
            cx = tx, cy = ty;
            // mark it visited
            [unvisitedCells removeObjectForKey:KEY(cx, cy)];
        }
        else if (stack.count > 0) {
            // pop cell from stack
            uint index = [[stack lastObject] unsignedIntegerValue];
            [stack removeLastObject];
            // make it current cell
            XY(index, cx, cy);
        }
        else {
            // pick random unvisited cell
            uint index = arc4random() % unvisitedCells.count;
            index = [unvisitedCells.allKeys[index] unsignedIntegerValue];
            // make it current cell
            XY(index, cx, cy);
            // mark it visited
            [unvisitedCells removeObjectForKey:KEY(cx, cy)];
        }
        callback();
    }
    
}

- (NSNumber*)unvisitedNeighbourAt:(uint)cx :(uint)cy width:(uint)width height:(uint)height cells:(NSMutableDictionary*)unvisitedCells {
    NSMutableArray* unvisited = [NSMutableArray array];
    
    int index = cy * width + cx - 1;
    if (cx > 0 && unvisitedCells[@(index)]) {
        if (_stretchLeft > 0 && _stretchDirection == 1) {
            _stretchLeft--;
            return @(index);
        }
        [unvisited addObject:@[@(index), @1]];
    }
    index = cy * width + cx + 1;
    if (cx < width-1 && unvisitedCells[@(index)]) {
        if (_stretchLeft > 0 && _stretchDirection == 2) {
            _stretchLeft--;
            return @(index);
        }
        [unvisited addObject:@[@(index), @2]];
    }
    index = (cy-1) * width + cx;
    if (cy > 0 && unvisitedCells[@(index)]) {
        if (_stretchLeft > 0 && _stretchDirection == 3) {
            _stretchLeft--;
            return @(index);
        }
        [unvisited addObject:@[@(index), @3]];
    }
    index = (cy+1) * width + cx;
    if (cy < height - 1 && unvisitedCells[@(index)]) {
        if (_stretchLeft > 0 && _stretchDirection == 4) {
            _stretchLeft--;
            return @(index);
        }
        [unvisited addObject:@[@(index), @4]];
    }
    
    // pick a new direction
    if (unvisited.count > 0) {
        NSArray* choice = unvisited[arc4random() % unvisited.count];
        _stretchLeft = ((width + height) / 4) * _stretchFactor * (1.1 - (arc4random() % 10)/10.0);
        _stretchDirection = [choice[1] integerValue];
        return choice[0];
    }
    
    return nil;
}
@end
