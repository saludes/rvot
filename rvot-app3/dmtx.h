//
//  dmtx.h
//  rvot-app3
//
//  Created by Jordi Saludes on 18/11/11.
//  Copyright (c) 2011 UPC. All rights reserved.
//

#ifndef rvot_app3_dmtx_h
#define rvot_app3_dmtx_h

#include <Cocoa/Cocoa.h>

CGImageRef dmtxwrite(const char* code);
int dmtread(char* code);

#endif
