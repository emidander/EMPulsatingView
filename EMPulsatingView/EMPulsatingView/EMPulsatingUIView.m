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
    CGFloat _colorComponents[3];
    CGFloat _lineColorComponents[3];
    CGFloat _colorComponentsFrom[3];
    CGFloat _colorComponentsTo[3];
    float _startSize;
    float _endSize;
    float _halfSize;
    
    int _firstIndex;
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
    BOOL overflow = NO;
    for (int index = 0; index < _circleCount; index++) {
        int circleIndex = (_firstIndex + index) % _circleCount;
        float scale = _circles[circleIndex];
        if (scale > 0 && scale <= 1.0) {
            float size = _startSize + (_endSize - _startSize) * scale;
            
            CGRect rect = CGRectMakeWithCenter(_halfSize, _halfSize, size, size);
            if (_style == EMPulsatingViewStyleSolid) {
                CGContextSetFillColor(context, (CGFloat []){_colorComponents[0], _colorComponents[1], _colorComponents[2], 1.0 - scale});
                [[UIBezierPath bezierPathWithOvalInRect:rect] fill];
            } else if (_style == EMPulsatingViewStyleGradient) {
                CGFloat colors [] = {
                    _colorComponentsFrom[0], _colorComponentsFrom[1], _colorComponentsFrom[2], 1.0 - scale,
                    _colorComponentsTo[0], _colorComponentsTo[1], _colorComponentsTo[2], 1.0 - scale
                };
                
                CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
                CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
                CGColorSpaceRelease(baseSpace);
                
                CGContextAddEllipseInRect(context, rect);
                CGContextClip(context);
                
                CGContextDrawRadialGradient(context, gradient, CGPointMake(_halfSize, _halfSize), 0, CGPointMake(_halfSize, _halfSize), size, kCGGradientDrawsAfterEndLocation);
                CGGradientRelease(gradient);
            }
            
            if (_lineColor) {
                CGContextSetStrokeColor(context, (CGFloat []){_lineColorComponents[0], _lineColorComponents[1], _lineColorComponents[2], 1.0 - scale});
                [[UIBezierPath bezierPathWithOvalInRect:CGRectMakeWithCenter(_halfSize, _halfSize, size, size)] stroke];
            }

        }
        
        scale += (delta / (float)_circleCount) / _speed;
        if (scale > 1.0) {
            scale -= 1.0;
            overflow = YES;
        }
        _circles[circleIndex] = scale;
    }
    if (overflow) {
        _firstIndex++;
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
    self.style = EMPulsatingViewStyleSolid;
    self.circleCount = 5;
    self.speed = 1.0;
    self.lineColor = Nil;
    self.color = [UIColor redColor];
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

- (void)setColor:(UIColor *)color {
    _color = color;
    if (CGColorGetNumberOfComponents(_color.CGColor)) {
        const CGFloat *colorComponents = CGColorGetComponents(_color.CGColor);
        _colorComponents[0] = colorComponents[0];
        _colorComponents[1] = colorComponents[1];
        _colorComponents[2] = colorComponents[2];
    }
}

- (void)setLineColor:(UIColor *)color {
    _lineColor = color;
    if (CGColorGetNumberOfComponents(_lineColor.CGColor)) {
        const CGFloat *colorComponents = CGColorGetComponents(_lineColor.CGColor);
        _lineColorComponents[0] = colorComponents[0];
        _lineColorComponents[1] = colorComponents[1];
        _lineColorComponents[2] = colorComponents[2];
    }
}

- (void)startAnimation {
    
    _startSize = 0.0;
    float smallestDimension = MIN(self.frame.size.width, self.frame.size.height);
    _halfSize = smallestDimension / 2.0;
    _endSize = smallestDimension;

    [self createCircles];
    _firstIndex = 0;
    
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
