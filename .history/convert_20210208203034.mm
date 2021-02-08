//
//  convert.mm
//
//  Created by ZDH on 2021/02/08.
//

#import "UIImage+TransferImageData.h"

//Image format
typedef NS_ENUM(NSUInteger , TransferImageDataFromat) {
    TransferImageDataFromat_ARGB = 0, //ARGB format image
    TransferImageDataFromat_RGBA = 1, //RGBA format image
    TransferImageDataFromat_GRAY = 2, //Gray format image
};

@implementation UIImage (TransferImageData)

#pragma  Mark UIImage image and byte data conversion

- (unsigned char *)transferToARGBData {
    return [self transferToDataWithFormat:TransferImageDataFromat_ARGB isNeedAlpha:YES];
}

- (unsigned char *)transferToRGBAData {
    return [self transferToDataWithFormat:TransferImageDataFromat_RGBA isNeedAlpha:YES];
}

- (unsigned char *)transferToGrayData {
    return [self transferToDataWithFormat:TransferImageDataFromat_GRAY isNeedAlpha:YES];
}

/// Get the byte data of the image
/// @param format image pixel format
/// @param isNeedAlpha Whether to retain the transparency channel, if not, the transparency channel will all be set to 255 (completely opaque)
- (unsigned char *)transferToDataWithFormat:(TransferImageDataFromat)format isNeedAlpha:(BOOL)isNeedAlpha {
    size_t width = CGImageGetWidth(self.CGImage);
    size_t height = CGImageGetHeight(self.CGImage);
    if(width == 0 || height == 0)
        return nullptr;
    
    unsigned char* imageData = nullptr;
    int bytesPerRow;
    CGImageAlphaInfo alphaInfo;
    switch (format) {
        case TransferImageDataFromat_ARGB:
            imageData = new unsigned char[width * height * 4];
            bytesPerRow = (int)width * 4;
            alphaInfo = kCGImageAlphaPremultipliedFirst;
            break;
        case TransferImageDataFromat_RGBA:
            imageData = new unsigned char[width * height * 4];
            bytesPerRow = (int)width * 4;
            alphaInfo = kCGImageAlphaPremultipliedLast;
            break;
        case TransferImageDataFromat_GRAY:
            imageData = new unsigned char[width * height];
            bytesPerRow = (int)width;
            alphaInfo = kCGImageAlphaNone;
            break;
        default:
            break;
    }
    
    CGColorSpaceRef cref = CGColorSpaceCreateDeviceGray();
    CGContextRef gc = CGBitmapContextCreate(imageData, width, height, 8, bytesPerRow, cref, alphaInfo);
    CGColorSpaceRelease(cref);
    UIGraphicsPushContext(gc);
    
    if (!isNeedAlpha && format != TransferImageDataFromat_GRAY) {
        CGContextSetRGBFillColor(gc, 1.0, 1.0, 1.0, 1.0);
        CGContextFillRect(gc, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height));
    }
    
    CGRect rect = {{0, 0}, {(CGFloat)width, (CGFloat)height}};
    CGContextDrawImage(gc, rect, self.CGImage);
    UIGraphicsPopContext();
    CGContextRelease(gc);
    
    return imageData;
}

+ (UIImage *)transferToImageWithARGBData:(unsigned char *)data withSize:(CGSize)size {
    return [self transferToImageWithARGBData:data withWidth:size.width withHeight:size.height];
}

+ (UIImage *)transferToImageWithARGBData:(unsigned char *)data withWidth:(int)width withHeight:(int)height {
    return [self transferToImageWithData:data withWidth:width withHeight:height withFormat:TransferImageDataFromat_ARGB];
}

+ (UIImage *)transferToImageWithRGBAData:(unsigned char *)data withSize:(CGSize) size {
    return [self transferToImageWithRGBAData:data withWidth:size.width withHeight:size.height];
}

+ (UIImage *)transferToImageWithRGBAData:(unsigned char *)data withWidth:(int)width withHeight:(int)height {
    return [self transferToImageWithData:data withWidth:width withHeight:height withFormat:TransferImageDataFromat_RGBA];
}

+ (UIImage *)transferToImageWithGrayData:(unsigned char *)data withSize:(CGSize)size {
    return [self transferToImageWithGrayData:data withWidth:size.width withHeight:size.height];
}

+ (UIImage *)transferToImageWithGrayData:(unsigned char *)data withWidth:(int)width withHeight:(int)height {
    return [self transferToImageWithData:data withWidth:width withHeight:height withFormat:TransferImageDataFromat_GRAY];
}

+ (UIImage *)transferToImageWithData:(unsigned char *)data withWidth:(int)width withHeight:(int)height withFormat:(TransferImageDataFromat)format {
    int bytesPerRow;
    CGImageAlphaInfo alphaInfo;
    CGColorSpaceRef colorSpace;
    switch (format) {
        case TransferImageDataFromat_ARGB:
            bytesPerRow = (int)width * 4;
            alphaInfo = kCGImageAlphaPremultipliedFirst;
            colorSpace = CGColorSpaceCreateDeviceRGB();
            break;
        case TransferImageDataFromat_RGBA:
            bytesPerRow = (int)width * 4;
            alphaInfo = kCGImageAlphaPremultipliedLast;
            colorSpace = CGColorSpaceCreateDeviceRGB();
            break;
        case TransferImageDataFromat_GRAY:
            bytesPerRow = (int)width;
            alphaInfo = kCGImageAlphaNone;
            colorSpace = CGColorSpaceCreateDeviceGray();
            break;
        default:
            break;
    }
    
    CGContextRef context = CGBitmapContextCreate(data, width, height, 8, bytesPerRow, colorSpace, alphaInfo);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL) {
        return nil;
    }
    
    CGImageRef cgImageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *grayImage = [[UIImage alloc] initWithCGImage:cgImageRef];
    CGImageRelease(cgImageRef);
    return grayImage;
}

@end

