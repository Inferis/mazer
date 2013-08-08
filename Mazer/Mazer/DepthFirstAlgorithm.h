//
//  RandomizedKruskalsAlgorithm.h
//  Mazer
//
//  Created by Tom Adriaenssen on 08/08/13.
//  Copyright (c) 2013 Tom Adriaenssen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MazeAlgorithm.h"

@interface DepthFirstAlgorithm : NSObject <MazeAlgorithm>

- (id)init;
- (id)initWithStretchFactor:(CGFloat)stretchFactor;

@end
