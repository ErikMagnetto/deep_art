#import "DeepArtPlugin.h"
#import <deep_art/deep_art-Swift.h>

@implementation DeepArtPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDeepArtPlugin registerWithRegistrar:registrar];
}
@end
