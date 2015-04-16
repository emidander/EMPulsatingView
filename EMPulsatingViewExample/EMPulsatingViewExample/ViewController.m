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

- (void)viewDidAppear:(BOOL)animated {
    [_pulsatingView startAnimationWithCircles:10 speed:1.0];
}

@end
