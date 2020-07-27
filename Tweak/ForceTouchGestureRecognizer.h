#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface ForceTouchGestureRecognizer : UIGestureRecognizer
@property (nonatomic) CGFloat forceSensitivity;
@property (nonatomic, readonly) CGFloat force;
@end