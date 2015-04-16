//
//  EMPulsatingUIView.m
//  EMPulsatingView
//
//  Created by Erik Midander on 16/04/15.
//  Copyright (c) 2015 Erik Midander. All rights reserved.
//

#import "EMPulsatingUIView.h"

CG_INLINE CGRect
CGRectMakeWithCenter(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
{
    CGRect rect;
    rect.origin.x = x - width / 2.0; rect.origin.y = y - height / 2.0;
    rect.size.width = width; rect.size.height = height;
    return rect;
}

@interface EMPulsatingUIView ()
@property (nonatomic) CADisplayLink *displayLink;
@end

@implementation EMPulsatingUIView {
    int _circleCount;
    float *_circles;
    float startSize;
    float endSize;
    float halfSize;
}

- (void)drawRect:(CGRect)rect {
    static NSTimeInterval lastDrawTime = 0;
    if (lastDrawTime == 0) {
        lastDrawTime = _displayLink.timestamp;
        return;
    }
    NSTimeInterval delta = _displayLink.timestamp - lastDrawTime;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    static int firstIndex = 0;
    BOOL overflow = NO;
    for (int index = 0; index < _circleCount; index++) {
        int circleIndex = (firstIndex + index) % _circleCount;
        float scale = _circles[circleIndex];
        if (scale > 0 && scale <= 1.0) {
            float size = startSize + (endSize - startSize) * scale;
            
            // Solid color
            //CGContextSetFillColor(context, (CGFloat []){1.0, 0.0, 0.0, 1.0 - scale});
            //[[UIBezierPath bezierPathWithOvalInRect:CGRectMakeWithCenter(halfSize, halfSize, size, size)] fill];
            
            CGFloat colors [] = {
                1.0, 0.5, 0.5, 1.0 - scale,
                1.0, 0.0, 0.0, 1.0 - scale
            };
            
            CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
            CGColorSpaceRelease(baseSpace);
            
            CGContextAddEllipseInRect(context, CGRectMakeWithCenter(halfSize, halfSize, size, size));
            CGContextClip(context);
            
            CGContextDrawRadialGradient(context, gradient, CGPointMake(halfSize, halfSize), 0, CGPointMake(halfSize, halfSize), size, kCGGradientDrawsAfterEndLocation);
            CGGradientRelease(gradient);
        }
        
        scale += delta / 5.0;
        if (scale > 1.0) {
            scale -= 1.0;
            overflow = YES;
        }
        _circles[circleIndex] = scale;
    }
    if (overflow) {
        firstIndex++;
    }
    lastDrawTime = _displayLink.timestamp;
}

- (void)destroyCircles {
    if (_circles) {
        free(_circles);
        _circles = NULL;
    }
}

- (void)createCircles {
    [self destroyCircles];
    _circles = calloc(_circleCount, sizeof(float));
    float scale = 0.0;
    for (int i = 0; i < _circleCount; i++) {
        _circles[i] = scale;
        scale -= (1.0 / (float)_circleCount);
    }
}

- (void)startAnimationWithCircles:(int)circleCount speed:(NSTimeInterval)speed {
    
    startSize = 0.0;
    float smallestDimension = MIN(self.frame.size.width, self.frame.size.height);
    halfSize = smallestDimension / 2.0;
    endSize = smallestDimension;

    _circleCount = circleCount;
    [self createCircles];
    
    [_displayLink invalidate];
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onFrame)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stopAnimation {
    [_displayLink invalidate];
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onFrame)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)onFrame {
    [self setNeedsDisplay];
}

- (void)dealloc {
    [self destroyCircles];
}

@end
