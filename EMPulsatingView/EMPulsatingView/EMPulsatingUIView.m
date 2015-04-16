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
    float *_circles;
    CGFloat _colorComponentsFrom[3];
    CGFloat _colorComponentsTo[3];
    float startSize;
    float endSize;
    float halfSize;
}

- (instancetype)initWithFrame:(CGRect)frame {
    [self setDefaults];
    return [super initWithFrame:frame];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    [self setDefaults];
    return [super initWithCoder:aDecoder];
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
                _colorComponentsFrom[0], _colorComponentsFrom[1], _colorComponentsFrom[2], 1.0 - scale,
                _colorComponentsTo[0], _colorComponentsTo[1], _colorComponentsTo[2], 1.0 - scale
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

- (void)setDefaults {
    self.circleCount = 5;
    self.speed = 2.0;
    self.colorFrom = [UIColor colorWithRed:1.0 green:0.5 blue:0.5 alpha:1.0];
    self.colorTo = [UIColor redColor];
}

- (void)setColorFrom:(UIColor *)color {
    _colorFrom = color;
    if (CGColorGetNumberOfComponents(_colorFrom.CGColor)) {
        const CGFloat *colorComponents = CGColorGetComponents(_colorFrom.CGColor);
        _colorComponentsFrom[0] = colorComponents[0];
        _colorComponentsFrom[1] = colorComponents[1];
        _colorComponentsFrom[2] = colorComponents[2];
    }
}

- (void)setColorTo:(UIColor *)color {
    _colorTo = color;
    if (CGColorGetNumberOfComponents(_colorTo.CGColor)) {
        const CGFloat *colorComponents = CGColorGetComponents(_colorTo.CGColor);
        _colorComponentsTo[0] = colorComponents[0];
        _colorComponentsTo[1] = colorComponents[1];
        _colorComponentsTo[2] = colorComponents[2];
    }
}

- (void)startAnimation {
    
    startSize = 0.0;
    float smallestDimension = MIN(self.frame.size.width, self.frame.size.height);
    halfSize = smallestDimension / 2.0;
    endSize = smallestDimension;

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
