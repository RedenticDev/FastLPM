#import "ForceTouchGestureRecognizer.h"

/* From https://github.com/yusuga/ForceTouchGestureRecognizer */
@interface ForceTouchGestureRecognizer ()
@property (nonatomic, readwrite) CGFloat force;
@end

@implementation ForceTouchGestureRecognizer

- (instancetype)init {
    if (self = [super init]) [self commonInit];
    return self;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    if (self = [super initWithTarget:target action:action]) [self commonInit];
    return self;
}

- (void)commonInit {
    self.forceSensitivity = 1.0;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.force = 0.0;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    UIView *view = touch.view;

    if (!CGRectContainsPoint(view.bounds, [touch locationInView:view])) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }

    if ([touch respondsToSelector:@selector(force)] && [touch respondsToSelector:@selector(maximumPossibleForce)] && touch.maximumPossibleForce > 0 && touch.force >= touch.maximumPossibleForce * self.forceSensitivity) {
        self.force = touch.force;
        self.state = UIGestureRecognizerStateRecognized;
        return;
    }
}

@end