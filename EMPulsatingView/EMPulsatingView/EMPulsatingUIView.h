//
//  EMPulsatingUIView.h
//  EMPulsatingView
//
//  Created by Erik Midander on 16/04/15.
//  Copyright (c) 2015 Erik Midander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMPulsatingUIView : UIView

@property (nonatomic) UIColor *colorFrom;
@property (nonatomic) UIColor *colorTo;
@property (nonatomic) int circleCount;
@property (nonatomic) NSTimeInterval speed;

- (void)startAnimation;
@end
