//
//  ViewController.m
//  EMPulsatingViewExample
//
//  Created by Erik Midander on 16/04/15.
//  Copyright (c) 2015 Erik Midander. All rights reserved.
//

#import "ViewController.h"
#import <EMPulsatingView/EMPulsatingView.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet EMPulsatingUIView *pulsatingView;

@end

@implementation ViewController

- (IBAction)didTouchButtonSolid:(UIButton *)sender {
    [_pulsatingView stopAnimation];
    _pulsatingView.color = [UIColor greenColor];
    _pulsatingView.lineColor = Nil;
    _pulsatingView.style = EMPulsatingViewStyleSolid;
    [_pulsatingView startAnimation];
}

- (IBAction)didTouchButtonSolidWithLine:(UIButton *)sender {
    [_pulsatingView stopAnimation];
    _pulsatingView.color = [UIColor blueColor];
    _pulsatingView.lineColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.2 alpha:1.0];
    _pulsatingView.style = EMPulsatingViewStyleSolid;
    [_pulsatingView startAnimation];
}

- (IBAction)didTouchButtonGradient:(UIButton *)sender {
    [_pulsatingView stopAnimation];
    _pulsatingView.colorFrom = [UIColor colorWithRed:1.0 green:0.5 blue:0.5 alpha:1.0];
    _pulsatingView.colorTo = [UIColor redColor];
    _pulsatingView.lineColor = Nil;
    _pulsatingView.style = EMPulsatingViewStyleGradient;
    [_pulsatingView startAnimation];
}

- (void)viewDidAppear:(BOOL)animated {
    [self didTouchButtonSolid:Nil];
}

@end
