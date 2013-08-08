//
//  Chamber.m
//  Mazer
//
//  Created by Tom Adriaenssen on 05/08/13.
//  Copyright (c) 2013 Tom Adriaenssen. All rights reserved.
//

#import "Maze.h"
#import "RandomizedPrimsAlgorithm.h"

@implementation Maze {
    NSMutableDictionary* _walls;
    uint _inRow, _outRow;
}

- (id)initWithWidth:(uint)width height:(uint)height algorithm:(id<MazeAlgorithm>)algorithm generate:(BOOL)generate {
    if ((self = [self init])) {
        _width = width;
        _height = height;
        self.algorithm = algorithm ?: [RandomizedPrimsAlgorithm new];
        if (generate)
            [self generateMazeHoleFactor:0 callback:nil completion:nil];
        else
            [self makeWalls];
    }
    return self;
}

- (void)generateMazeHoleFactor:(CGFloat)holeFactor callback:(void(^)(void))callback completion:(void(^)(void))completion {
    if (!callback) callback = ^{};
    if (!completion) completion = ^{};
    dispatch_async_bg(^{
        [self makeWalls];
        [self crawl:callback];
        int left = _walls.count * MIN(MAX(holeFactor, 0), 1);
        while (left-- > 0) {
            int index = arc4random() % _walls.count;
            [_walls removeObjectForKey:_walls.allKeys[index]];
        }
        completion();
    });
}

- (void)makeWalls {
    int totalWalls = _width*(_height-1) + _height*(_width - 1);
    _walls = [NSMutableDictionary dictionaryWithCapacity:totalWalls];
    
    for (int x=1; x<_width; ++x) {
        for (int y=0; y<_height; ++y) {
            _walls[WALL(x - 1, y, x, y)] = @YES;
        }
    }

    for (int x=0; x<_width; ++x) {
        for (int y=1; y<_height; ++y) {
            _walls[WALL(x, y-1, x, y)] = @YES;
        }
    }
    
    while (ABS(_inRow - _outRow) < (_height/2)) {
        _inRow = arc4random() % _width;
        _outRow = arc4random() % _height;
    }
}

- (void)crawl:(void(^)(void))callback {
    [self.algorithm executeWithWidth:_width height:_height startingRow:_inRow removeWall:^(uint fx, uint fy, uint tx, uint ty) {
        [_walls removeObjectForKey:WALL(fx, fy, tx, ty)];
        [_walls removeObjectForKey:WALL(tx, ty, fx, fy)];
    } callback:callback];
}



#pragma mark - Drawing

- (UIImage*)draw:(CGSize)size {
    return [self draw:size lineWidth:1 lineColor:[UIColor blackColor]];
}

- (UIImage*)draw:(CGSize)size lineWidth:(CGFloat)lineWidth lineColor:(UIColor*)color {
    if (size.width <= 0 || size.height <= 0)
        return nil;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // prepare context
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetStrokeColorWithColor(ctx, [color CGColor]);
    CGContextSetFillColorWithColor(ctx, [color CGColor]);
    
    // draw grid
    CGFloat dx = floorf(size.width / _width);
    CGFloat dy = floorf(size.height / _height);
    if (dx == (size.width / _width))
        dx -= 1;
    if (dy == (size.height / _height))
        dy -= 1;
    CGFloat ox = (size.width - _width*dx) / 2.0f;
    CGFloat oy = (size.height - _height*dy) / 2.0f;
    CGFloat hlw = lineWidth / 2.0f;
    
    for (int x=0; x<_width+1; ++x) {
        for (int y=0; y<_height+1; ++y) {
            //CGContextFillEllipseInRect(ctx, CGRectMake(ox + x*dx - hlw, oy + y*dy - hlw, lineWidth, lineWidth));

            if (YES || (y<_height && x<_width)) {
                // vertical wall
                if (((x == 0 || x == _width) && y < _height) || [_walls[WALL(x-1, y, x, y)] boolValue]) {
                    if ((x > 0 || y != _inRow) && (x < _width || y != _outRow))
                        CGContextStrokeRect(ctx, CGRectMake(ox + x*dx, ox + y*dy, 0, dy));
                }
                // horizontal wall
                if (((y == 0 || y == _height) && x < _width) || [_walls[WALL(x, y-1, x, y)] boolValue]) {
                    CGContextStrokeRect(ctx, CGRectMake(ox + x*dx, ox + y*dy, dx, 0));
                }
            }
        }
    }

    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

@end
