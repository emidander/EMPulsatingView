//
//  EMPulsatingUIView.h
//  EMPulsatingView
//
//  Created by Erik Midander on 16/04/15.
//  Copyright (c) 2015 Erik Midander. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    EMPulsatingViewStyleSolid = 1,
    EMPulsatingViewStyleGradient = 2
} EMPulsatingViewStyle;

@interface EMPulsatingUIView : UIView

@property (nonatomic) EMPulsatingViewStyle style;
@property (nonatomic) UIColor *colorFrom;
@property (nonatomic) UIColor *colorTo;
@property (nonatomic) UIColor *color;
@property (nonatomic) UIColor *lineColor;
@property (nonatomic) int circleCount;
@property (nonatomic) NSTimeInterval speed;

- (void)startAnimation;
- (void)stopAnimation;
@end
