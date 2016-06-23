#ifdef _WIN32
#include "FlashRuntimeExtensions.h"
#include <windows.h>
#include <conio.h>
#else
#include <Adobe AIR/Adobe AIR.h>
#include <stdlib.h>
#include <stdio.h>
#endif
#include <string>
#include <vector>
#include <boost/lexical_cast.hpp>
FREObject getFREObjectProperty(FREObject objAS, const uint8_t * propertyName);
FREObject getFREObjectFromString(std::string arg);
FREObject getFREObjectFromString(const char* arg);
FREObject getFREObjectFromString(const wchar_t* arg);
FREObject getFREObjectFromInt32(int32_t arg);
FREObject getFREObjectFromUint32(uint32_t arg);
FREObject getFREObjectFromDouble(double arg);
FREObject getFREObjectFromBool(bool arg);
FREObject getFREObjectFromBool(std::string arg);
uint32_t getUInt32FromFREObject(FREObject uintAS);
int32_t getInt32FromFREObject(FREObject intAS);
bool getBoolFromFREObject(FREObject val);
double getDoubleFromFREObject(FREObject arg);
uint32_t getFREObjectArrayLength(FREObject arrayAS);
std::string getStringFromFREObject(FREObject arg);
std::vector<std::string> getStringVectorFromFREObject(FREObject arg, const uint8_t * propertyName);
FREObject getReturnTrue();