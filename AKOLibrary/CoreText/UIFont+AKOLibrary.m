//
//  UIFont+AKOLibrary.m
//  AKOLibrary
//
//  Created by Adrian on 4/15/11.
//  Copyright (c) 2009, 2010, 2011, Adrian Kosmaczewski & akosma software
//  All rights reserved.
//  
//  Use in source and/or binary forms without modification is permitted following the
//  instructions in the LICENSE file.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
//  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
//  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
//  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
//  OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "UIFont+AKOLibrary.h"


@implementation UIFont(AKOLibrary)

- (CTFontRef)ako_createCTFont
{
    CTFontRef font = CTFontCreateWithName((CFStringRef)self.fontName, self.pointSize, NULL);
    return font;
}

+ (CTFontRef)ako_createBundledFontNamed:(NSString *)name size:(CGFloat)size
{
    // Adapted from http://stackoverflow.com/questions/2703085/how-can-you-load-a-font-ttf-from-a-file-using-core-text
    
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"ttf"];
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, false);
    CGDataProviderRef dataProvider = CGDataProviderCreateWithURL(url);
    CGFontRef theCGFont = CGFontCreateWithDataProvider(dataProvider);
    CTFontRef result = CTFontCreateWithGraphicsFont(theCGFont, size, NULL, NULL);
    CFRelease(theCGFont);
    CFRelease(dataProvider);
    CFRelease(url);
    
    return result;    
}

@end
