//
//  MazeAlgorithm.h
//  Mazer
//
//  Created by Tom Adriaenssen on 07/08/13.
//  Copyright (c) 2013 Tom Adriaenssen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MazeAlgorithm <NSObject>

@required
- (void)executeWithWidth:(uint)width height:(uint)height startingRow:(uint)inRow removeWall:(void(^)(uint fx, uint fy, uint tx, uint ty))removeWall callback:(void(^)(void))callback;


@end

