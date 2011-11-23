//
//  dmtx.c
//  rvot-app3
//
//  Created by Jordi Saludes on 18/11/11.
//  Copyright (c) 2011 UPC. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include "dmtx.h" 

CGImageRef dmtxwrite(const char* code){
    char[] command = "/opt/local/bin/dmtxwrite /tmp/matrixXXXX.png";
    char* pngPath;
    for(pngPath = command; *pngPath != ' '; pngPath++);

    mkstemp(command, 4);
    printf(command);
    FILE* p = popen(command, "r")
    [code cha
     
    fwrite(code, strlen(code), 1, p);
    pclose(p);
     CGDataProviderRef pngProvides = CGDataProviderCreateWithFilename(++pngPath);
     return CGImageCreateWithPNGDataProvider (pngProvider, NULL, 0, kCGRenderingIntentDefault);
     // unlink png TODO
}

// int dmtread(NSString* code);
