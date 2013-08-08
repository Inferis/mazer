//
//  Chamber.h
//  Mazer
//
//  Created by Tom Adriaenssen on 05/08/13.
//  Copyright (c) 2013 Tom Adriaenssen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MazeAlgorithm.h"

#define WALL(sx, sy, ex, ey) ([NSString stringWithFormat:@"%d:%d-%d:%d", (sx), (sy), (ex), (ey)])
#define PART(wall, index) ([(wall) componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]][(index)])
#define START(wall) PART(wall, 0)
#define END(wall) PART(wall, 1)
#define REVERSEWALL(wall) ([NSString stringWithFormat:@"%@-%@", PART(wall,1), PART(wall,0)])
#define SPLIT(part, x, y) ({ NSArray* p = [(part) componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]]; x = [p[0] intValue]; y = [p[1] intValue]; })

@interface Maze : NSObject

@property (nonatomic, assign, readonly) uint width;
@property (nonatomic, assign, readonly) uint height;
@property (nonatomic, strong) id<MazeAlgorithm> algorithm;

- (id)initWithWidth:(uint)width height:(uint)height algorithm:(id<MazeAlgorithm>)algorithm generate:(BOOL)generate;

- (UIImage*)draw:(CGSize)size;
- (UIImage*)draw:(CGSize)size lineWidth:(CGFloat)lineWidth lineColor:(UIColor*)color;

- (void)generateMazeHoleFactor:(CGFloat)holeFactor callback:(void(^)(void))callback completion:(void(^)(void))completion;

@end
