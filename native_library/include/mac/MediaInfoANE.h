#ifndef __MediaInfoANE__MediaInfoANE__
#define __MediaInfoANE__MediaInfoANE__

#include <stdio.h>
#include <Adobe AIR/Adobe AIR.h>

#define EXPORT __attribute__((visibility("default")))
extern "C" {
    EXPORT
    void TRMIAExtInizer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer);
    
    EXPORT
    void TRMIAExtFinizer(void* extData);
}
#endif


