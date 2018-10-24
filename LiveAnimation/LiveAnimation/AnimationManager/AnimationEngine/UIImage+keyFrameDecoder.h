//
//  UIImage+keyFrameDecoder.h
//  test
//
//  Created by 罗潇 on 16/6/24.
//  Copyright © 2016年 罗潇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (keyFrameDecoder)
- (nullable CGImageRef)cc_decodedCGImageRefCopy;
@end
