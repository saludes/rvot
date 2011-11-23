//
//  main.m
//  mmtext
//
//  Created by Jordi Saludes on 20/11/11.
//  Copyright (c) 2011 UPC. All rights reserved.
//

/* #import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
    return NSApplicationMain(argc, (const char **)argv);
}
*/

#import <Cocoa/Cocoa.h>
#import "SHDataMatrixReader.h"
#import "SHDataMatrixWriter.h"

int main(int argc, char * argv[]) {
    if (argc < 2) {
        NSLog(@"Usage: test path_to_image");
        return 0;
    }
    
    NSAutoreleasePool * ARP = [[NSAutoreleasePool alloc] init];
    
    if (argc > 2 && argv[2][0] == '-') { // read from arg 1.
        
        
        NSImage * image = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:argv[1]]];
        SHDataMatrixReader * reader = [SHDataMatrixReader sharedDataMatrixReader];
        NSString * decodedMessage = [reader decodeBarcodeFromImage:image];
        
        NSLog(@"Decoded : %@", decodedMessage);
        [image release];

    } else { // Write arg 1 to arg 2 path
        
        NSString *code = [NSString stringWithUTF8String:argv[1]];
        NSLog(@"Code is: %@", code);
        
        SHDataMatrixWriter *writer = [SHDataMatrixWriter sharedDataMatrixWriter];
        NSImage *image = [writer encodeBarcodeToImage:code];        
        NSData *imageData = [image TIFFRepresentation];
        NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
        NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
        imageData = [imageRep representationUsingType:NSPNGFileType properties:imageProps];
        [imageData writeToFile:[NSString stringWithCString:argv[2] encoding:NSASCIIStringEncoding] atomically:NO];        
        [image release];

    }
}
