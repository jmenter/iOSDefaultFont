# iOSDefaultFont
A category on UIApplication for easy setting of the default font for your app.

Just call, for example in your applicationDidFinishLaunching method something like this: (Please don't use Zapfino as your app's font.)

  application.defaultFontName = @"Zapfino";

 It uses a simple method to determine what fonts (if any) to use for normal and bold weights, and uses a variety of techniques for establishing that default font throughout the app. Including:

- Using font and text attributes of the appearance proxy for common user interface elements directly
- Using performSelector for deprecated methods that are still hella useful and NSClassFromString for undocumenteds
- Using method swizzling for those really hard to reach areas

<img src="https://raw.githubusercontent.com/jmenter/iOSDefaultFont/master/example.png" width="750">
