
/* MIT License
 
 Copyright (c) 2017 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE. */

#import "UIApplication+Appearance.h"
#import <objc/runtime.h>

static NSString *defaultFontString;
static const CGFloat kDefaultPointSize = 17.f;

@implementation UIFont (Appearance)

- (NSDictionary <NSString *, id>*)attribute;
{
    return @{ NSFontAttributeName : self };
}

@end

@implementation UIApplication (Appearance)

- (void)setDefaultFontName:(NSString *)name;
{
    [self setDefaultFontName:name size:kDefaultPointSize];
}

- (void)setDefaultFontName:(NSString *)name size:(CGFloat)pointSize;
{
    if (pointSize == 0.f) pointSize = kDefaultPointSize;
    NSString *normalName = [name componentsSeparatedByString:@"-"].firstObject ?: name;
    
    UIFont *normalFont =
    [UIFont fontWithName:[normalName stringByAppendingString:@"-Regular"] size:pointSize] ?:
    [UIFont fontWithName:normalName size:pointSize] ?:
    [UIFont fontWithName:[normalName stringByAppendingString:@"-Roman"] size:pointSize] ?:
    [UIFont fontWithName:[normalName stringByAppendingString:@"-Book"] size:pointSize] ?:
    [UIFont fontWithName:[normalName stringByAppendingString:@"-Medium"] size:pointSize];
    
    if (!normalFont) return;
    
    defaultFontString = normalFont.fontName;
    
    UIFont *bolderFont =
    [UIFont fontWithName:[normalName stringByAppendingString:@"-SemiBold"] size:pointSize] ?:
    [UIFont fontWithName:[normalName stringByAppendingString:@"-DemiBold"] size:pointSize] ?:
    [UIFont fontWithName:[normalName stringByAppendingString:@"-Medium"] size:pointSize] ?:
    [UIFont fontWithName:[normalName stringByAppendingString:@"-Bold"] size:pointSize] ?:
    [UIFont fontWithName:[normalName stringByAppendingString:@"-Heavy"] size:pointSize] ?: normalFont;
    
    UIFont *defaultFontLarge = normalFont;
    UIFont *defaultFontLargeBolder = bolderFont;
    
    UIFont *defaultFont = [normalFont fontWithSize:pointSize - 2];
    UIFont *defaultFontMedium = [normalFont fontWithSize:pointSize - 3];
    UIFont *defaultFontSmall = [normalFont fontWithSize:pointSize - 4];
    UIFont *defaultFontTiny = [normalFont fontWithSize:pointSize - 7];
    
    // Only need to set font
    UILabel.appearance.font = defaultFontLarge;
    UITextField.appearance.font = defaultFontMedium;
    UITextView.appearance.font = defaultFontMedium;
    [UITableViewCell.appearance performSelector:@selector(setFont:) withObject:defaultFontLarge];
    [UIButton.appearance performSelector:@selector(setFont:) withObject:defaultFont];
    
    // These need titleTextAttributes
    UINavigationBar.appearance.titleTextAttributes = defaultFontLargeBolder.attribute;
    [UIBarButtonItem.appearance setTitleTextAttributes:defaultFontLarge.attribute forState:UIControlStateNormal];
    [UISegmentedControl.appearance setTitleTextAttributes:defaultFontSmall.attribute forState:UIControlStateNormal];
    [UITabBarItem.appearance setTitleTextAttributes:defaultFontTiny.attribute forState:UIControlStateNormal];
    
    // Special cases (yes, UITextField is in here too. This covers the while editing condition.)
    if (UIDevice.currentDevice.systemVersion.floatValue < 9) {
        [UILabel appearanceWhenContainedIn:UITextField.class, nil].font = defaultFontMedium;
        [UILabel appearanceWhenContainedIn:UIButton.class, nil].font = defaultFont;
        [UILabel appearanceWhenContainedIn:NSClassFromString(@"_UITableViewHeaderFooterContentView"), nil].font = defaultFontLargeBolder;
    } else {
        [UILabel appearanceWhenContainedInInstancesOfClasses:@[UITextField.class]].font = defaultFontMedium;
        [UILabel appearanceWhenContainedInInstancesOfClasses:@[UIButton.class]].font = defaultFont;
        [UILabel appearanceWhenContainedInInstancesOfClasses:@[NSClassFromString(@"_UITableViewHeaderFooterContentView")]].font = defaultFontLargeBolder;
    }
}

@end

// Swizzle UILabel setFont so we can style the non-UITableViewCellStyleDefault styles of cells.
@implementation UILabel (Appearance)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(setFont:);
        SEL swizzledSelector = @selector(swizzledSetFont:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        if (class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)swizzledSetFont:(UIFont *)font {
    if ([self isKindOfClass:NSClassFromString(@"UITableViewLabel")]) {
        [self swizzledSetFont:[UIFont fontWithName:defaultFontString size:font.pointSize]];
    } else {
        [self swizzledSetFont:font];
    }
}

@end

