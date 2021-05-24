//
//  UIImage+ChatExt.m
//  AFNetworking
//
//  Created by lixiaoming on 2021/5/22.
//

#import "UIImage+ChatExt.h"
#import "ChatExtApp.h"

@implementation UIImage (ChatExt)

+ (UIImage*) imageNamedFromBundle:(NSString*)imageName
{
    NSBundle* bundle = [NSBundle bundleForClass:[ChatExtApp class]];
    NSString* path = [NSString stringWithFormat:@"ChatExtApp.bundle/%@",imageName];
    NSString *file1 = [bundle pathForResource:path ofType:@"png"];
    UIImage *image1 = [UIImage imageWithContentsOfFile:file1];

    return image1;
}
@end
