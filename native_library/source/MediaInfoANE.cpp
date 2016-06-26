#ifdef _WIN32
#include "win/MediaInfoANE.h"
#else
#define __ASSERT_MACROS_DEFINE_VERSIONS_WITHOUT_UNDERSCORES 0
#define BOOST_ASIO_SEPARATE_COMPILATION 0
#define _UNICODE 1
#include "mac/MediaInfoANE.h"
#endif

#include <wchar.h>
#include <cstring>
#include <stdint.h>
#include <iterator>
#include <sstream>
#include <vector>

#ifdef _WIN32
#include <windows.h>
#include <conio.h>
#else
#include <stdlib.h>
#include <stdio.h>
#endif

#include <iostream>
#include <utility>
#include <string>

#include <math.h>
#include <map>
#include <boost/numeric/conversion/cast.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/thread.hpp>

#ifdef _WIN32
#include "FlashRuntimeExtensions.h"
bool isSupportedInOS = true;
#else
#include <Adobe AIR/Adobe AIR.h>
bool isSupportedInOS = true;
#endif

#include "ANEhelper.h"
#include "MediaInfo/MediaInfo.h"

using namespace MediaInfoLib;

unsigned int numAvailableThreads = boost::thread::hardware_concurrency();
boost::thread threads[1];

boost::thread createThread(void(*otherFunction)(int p), int p) {
	boost::thread t(*otherFunction, p);
	return boost::move(t);
}

std::string wcharToString(const wchar_t* arg) {
	using namespace std;
	std::wstring ws(arg);
	std::string str(ws.begin(), ws.end());
	return str;
}

uint32_t wcharToUint32(const wchar_t* arg) {
	using namespace std;
	std::wstring ws(arg);
	std::string str(ws.begin(), ws.end());
	uint32_t ret;
	istringstream convert(str);
	if (!(convert >> ret))
		ret = 0;
	return ret;
}

double wcharToDouble(const wchar_t* arg) {
	using namespace std;
	std::wstring ws(arg);
	std::string str(ws.begin(), ws.end());
	double ret;
	istringstream convert(str);
	if (!(convert >> ret))
		ret = 0.0;
	return (double)ret;
}

extern "C" {
	FREContext dllContext;
	unsigned int logLevel = 1;

	void trace(std::string msg) {
		if (logLevel > 0)
			FREDispatchStatusEventAsync(dllContext, (uint8_t*)msg.c_str(), (const uint8_t*) "TRACE");
	}
	
	extern void logError(std::string msg) {
		FREDispatchStatusEventAsync(dllContext, (uint8_t*)msg.c_str(), (const uint8_t*) "ERROR");
	}
	extern void logInfo(std::string msg) {
		if (logLevel > 0)
			FREDispatchStatusEventAsync(dllContext, (uint8_t*)msg.c_str(), (const uint8_t*) "INFO");
	}
	void printFREResult(FREResult errorCode, char * errMessage) {
		//sort this print based on the enum
		trace(std::string(errMessage));
		switch (errorCode) {
		case FRE_OK:
			trace("FRE_OK");
			break;
		case FRE_NO_SUCH_NAME:
			trace("FRE_NO_SUCH_NAME");
			break;
		case FRE_INVALID_OBJECT:
			trace("FRE_INVALID_OBJECT");
			break;
		case FRE_TYPE_MISMATCH:
			trace("FRE_TYPE_MISMATCH");
			break;
		case FRE_ACTIONSCRIPT_ERROR:
			trace("FRE_ACTIONSCRIPT_ERROR");
			break;
		case FRE_INVALID_ARGUMENT:
			trace("FRE_INVALID_ARGUMENT");
			break;
		case FRE_READ_ONLY:
			trace("FRE_READ_ONLY");
			break;
		case FRE_WRONG_THREAD:
			trace("FRE_WRONG_THREAD");
			break;
		case FRE_ILLEGAL_STATE:
			trace("FRE_ILLEGAL_STATE");
			break;
		case FRE_INSUFFICIENT_MEMORY:
			trace("FRE_INSUFFICIENT_MEMORY");
			break;
		}
	}

	typedef struct {
		uint32_t id;
		std::string format;
		std::string formatName;
		std::string profile;
		std::string cabac;
		uint32_t refFrames;
		std::string codecId;
		std::string codecName;
		uint32_t duration;
		uint32_t bitrate;
		uint32_t maxBitrate;
		std::string bitrateMode;
		uint32_t width;
		uint32_t height;
		double aspectRatio;
		std::string aspectRatioAsString;
		std::string framerateMode;
		double framerate;
		double bits;
		std::string colorSpace;
		std::string chroma;
		uint32_t bitDepth;
		std::string scanType;
		double size;
		std::string encoder;
		std::string encoderSettings;
		std::string language;
		std::string languageFull;
	}VideoStream;

	typedef struct {
		uint32_t id;
		uint32_t alternateGroup;
		uint32_t bitrate;
		uint32_t maxBitrate;
		std::string bitrateMode;
		std::string channelLayout;
		std::string compressionMode;
		uint32_t channels;
		std::string codecId;
		std::string codecName;
		uint32_t duration;
		std::string format;
		std::string formatName;
		std::string isDefault;
		std::string isForced;
		std::string language;
		std::string languageFull;
		std::string profile;
		uint32_t sampleRate;
		double size;
	}AudioStream;

	typedef struct {
		uint32_t id;
		std::string format;
		std::string codecId;
		std::string codecName;
		std::string language;
		std::string languageFull;
		std::string isDefault;
		std::string isForced;
	}TextStream;

	typedef struct {
		std::string name;
		std::string format;
		std::string profile;
		std::string codecId;
		std::string encoder;
		double fileSize;
		uint32_t duration;
		uint32_t bitrate;
		std::string bitrateMode;
		std::vector<VideoStream> videoStreams;
		std::vector<AudioStream> audioStreams;
		std::vector<TextStream> textStreams;
	}FileInfo;
	FileInfo fileContext;

	typedef struct {
		wchar_t *fileName;
		wchar_t *item;
		std::string type;
	}InfoContext;
	InfoContext infoContext;

	FREObject getLibVersion(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		MediaInfo MI;
		return getFREObjectFromString(MI.Option(__T("Info_Version"), __T("0.7.0.0;MediaInfoANE;0.7.0.0")).c_str());
	}

	void threadFileInfoItem(int p) {
		boost::mutex mutex;
		using boost::this_thread::get_id;
		using namespace std;
		mutex.lock();

		enum stream_t type;
		if (infoContext.type == "General")
			type = Stream_General;
		else if (infoContext.type == "Video")
			type = Stream_Video;
		else if (infoContext.type == "Audio")
			type = Stream_Audio;
		else if (infoContext.type == "Text")
			type = Stream_Text;
		else if (infoContext.type == "Other")
			type = Stream_Other;
		else if (infoContext.type == "Image")
			type = Stream_Image;
		else if (infoContext.type == "Menu")
			type = Stream_Menu;
		else if (infoContext.type == "Max")
			type = Stream_Max;
		else
			type = Stream_General;

		MediaInfo MI;
		MI.Open(infoContext.fileName);
		String sItem = infoContext.item;
		string ret = wcharToString(MI.Get(type, 0, sItem, Info_Text, Info_Name).c_str());

		MI.Close();
		FREDispatchStatusEventAsync(dllContext, (uint8_t*)ret.c_str(), (const uint8_t*) "ON_FILE_INFO_ITEM");

		mutex.unlock();
	}

	void threadFileInfo(int p) {
		boost::mutex mutex;
		using boost::this_thread::get_id;
		using namespace std;
		mutex.lock();

		MediaInfo MI;
		MI.Open(infoContext.fileName);
		fileContext.name = wcharToString(MI.Get(Stream_General, 0, __T("CompleteName"), Info_Text, Info_Name).c_str());
        
		fileContext.format = wcharToString(MI.Get(Stream_General, 0, __T("Format"), Info_Text, Info_Name).c_str());
		fileContext.profile = wcharToString(MI.Get(Stream_General, 0, __T("Format_Profile"), Info_Text, Info_Name).c_str());
		fileContext.codecId = wcharToString(MI.Get(Stream_General, 0, __T("CodecID"), Info_Text, Info_Name).c_str());
		fileContext.encoder = wcharToString(MI.Get(Stream_General, 0, __T("Encoded_Application"), Info_Text, Info_Name).c_str());
		fileContext.fileSize = wcharToDouble(MI.Get(Stream_General, 0, __T("FileSize"), Info_Text, Info_Name).c_str());
		fileContext.duration = (uint32_t)round(wcharToUint32(MI.Get(Stream_General, 0, __T("Duration"), Info_Text, Info_Name).c_str()) / 1000);
		fileContext.bitrate = wcharToUint32(MI.Get(Stream_General, 0, __T("OverallBitRate"), Info_Text, Info_Name).c_str());
		fileContext.bitrateMode = wcharToString(MI.Get(Stream_General, 0, __T("OverallBitRate_Mode/String"), Info_Text, Info_Name).c_str());

		fileContext.videoStreams.clear();
		uint32_t numVideoStreams = boost::numeric_cast<uint32_t>(MI.Count_Get(Stream_Video, -1));
		unsigned int i;
		for (i = 0; i < numVideoStreams; ++i) {
			VideoStream videoStream;
			videoStream.id = wcharToUint32(MI.Get(Stream_Video, i, __T("ID"), Info_Text, Info_Name).c_str());
			videoStream.aspectRatio = wcharToDouble(MI.Get(Stream_Video, i, __T("DisplayAspectRatio"), Info_Text, Info_Name).c_str());
			videoStream.aspectRatioAsString = wcharToString(MI.Get(Stream_Video, i, __T("DisplayAspectRatio/String"), Info_Text, Info_Name).c_str());
			videoStream.bitDepth = wcharToUint32(MI.Get(Stream_Video, i, __T("BitDepth"), Info_Text, Info_Name).c_str());
			videoStream.bitrate = wcharToUint32(MI.Get(Stream_Video, i, __T("BitRate"), Info_Text, Info_Name).c_str());
			videoStream.bitrateMode = wcharToString(MI.Get(Stream_Video, i, __T("BitRate_Mode/String"), Info_Text, Info_Name).c_str());
			videoStream.maxBitrate = wcharToUint32(MI.Get(Stream_Video, i, __T("BitRate_Maximum"), Info_Text, Info_Name).c_str());
			videoStream.bits = wcharToDouble(MI.Get(Stream_Video, i, __T("Bits-(Pixel*Frame)"), Info_Text, Info_Name).c_str());
			videoStream.cabac = wcharToString(MI.Get(Stream_Video, i, __T("Codec_Settings_CABAC"), Info_Text, Info_Name).c_str());
			videoStream.chroma = wcharToString(MI.Get(Stream_Video, i, __T("ChromaSubsampling"), Info_Text, Info_Name).c_str());
			videoStream.codecId = wcharToString(MI.Get(Stream_Video, i, __T("CodecID"), Info_Text, Info_Name).c_str());
			videoStream.codecName = wcharToString(MI.Get(Stream_Video, i, __T("Codec/Info"), Info_Text, Info_Name).c_str());
			videoStream.colorSpace = wcharToString(MI.Get(Stream_Video, i, __T("ColorSpace"), Info_Text, Info_Name).c_str());
			videoStream.duration = (uint32_t)round(wcharToUint32(MI.Get(Stream_Video, i, __T("Duration"), Info_Text, Info_Name).c_str()) / 1000);
			videoStream.encoder = wcharToString(MI.Get(Stream_Video, i, __T("Encoded_Library"), Info_Text, Info_Name).c_str());
			videoStream.encoderSettings = wcharToString(MI.Get(Stream_Video, i, __T("Encoded_Library_Settings"), Info_Text, Info_Name).c_str());
			videoStream.format = wcharToString(MI.Get(Stream_Video, i, __T("Format"), Info_Text, Info_Name).c_str());
			videoStream.formatName = wcharToString(MI.Get(Stream_Video, i, __T("Format/Info"), Info_Text, Info_Name).c_str());
			videoStream.framerate = wcharToDouble(MI.Get(Stream_Video, i, __T("FrameRate"), Info_Text, Info_Name).c_str());
			videoStream.framerateMode = wcharToString(MI.Get(Stream_Video, i, __T("FrameRate_Mode/String"), Info_Text, Info_Name).c_str());
			videoStream.height = wcharToUint32(MI.Get(Stream_Video, i, __T("Height"), Info_Text, Info_Name).c_str());
			videoStream.language = wcharToString(MI.Get(Stream_Video, i, __T("Language"), Info_Text, Info_Name).c_str());
			videoStream.languageFull = wcharToString(MI.Get(Stream_Video, i, __T("Language/String"), Info_Text, Info_Name).c_str());
			videoStream.profile = wcharToString(MI.Get(Stream_Video, i, __T("Format_Profile"), Info_Text, Info_Name).c_str());
			videoStream.refFrames = wcharToUint32(MI.Get(Stream_Video, i, __T("Format_Settings_RefFrames"), Info_Text, Info_Name).c_str());
			videoStream.scanType = wcharToString(MI.Get(Stream_Video, i, __T("ScanType"), Info_Text, Info_Name).c_str());
			videoStream.size = wcharToDouble(MI.Get(Stream_Video, i, __T("StreamSize"), Info_Text, Info_Name).c_str());
			videoStream.width = wcharToUint32(MI.Get(Stream_Video, i, __T("Width"), Info_Text, Info_Name).c_str());
			fileContext.videoStreams.push_back(videoStream);
		}
		uint32_t numAudioStreams = boost::numeric_cast<uint32_t>(MI.Count_Get(Stream_Audio, -1));

		for (i = 0; i < numAudioStreams; ++i) {
			AudioStream audioStream;
			audioStream.id = wcharToUint32(MI.Get(Stream_Audio, i, __T("ID"), Info_Text, Info_Name).c_str());
			audioStream.alternateGroup = wcharToUint32(MI.Get(Stream_Audio, i, __T("AlternateGroup"), Info_Text, Info_Name).c_str());
			audioStream.bitrate = wcharToUint32(MI.Get(Stream_Audio, i, __T("BitRate"), Info_Text, Info_Name).c_str());;
			audioStream.bitrateMode = wcharToString(MI.Get(Stream_Audio, i, __T("BitRate_Mode/String"), Info_Text, Info_Name).c_str());
			audioStream.maxBitrate = wcharToUint32(MI.Get(Stream_Audio, i, __T("BitRate_Maximum"), Info_Text, Info_Name).c_str());
			audioStream.channelLayout = wcharToString(MI.Get(Stream_Audio, i, __T("ChannelLayout"), Info_Text, Info_Name).c_str());
			audioStream.channels = wcharToUint32(MI.Get(Stream_Audio, i, __T("Channel(s)"), Info_Text, Info_Name).c_str());
			audioStream.codecId = wcharToString(MI.Get(Stream_Audio, i, __T("CodecID"), Info_Text, Info_Name).c_str());
			audioStream.codecName = wcharToString(MI.Get(Stream_Audio, i, __T("Codec/Info"), Info_Text, Info_Name).c_str());
			audioStream.compressionMode = wcharToString(MI.Get(Stream_Audio, i, __T("Compression_Mode"), Info_Text, Info_Name).c_str());
			audioStream.duration = (uint32_t)round(wcharToUint32(MI.Get(Stream_Audio, i, __T("Duration"), Info_Text, Info_Name).c_str()) / 1000);
			audioStream.format = wcharToString(MI.Get(Stream_Audio, i, __T("Format"), Info_Text, Info_Name).c_str());
			audioStream.formatName = wcharToString(MI.Get(Stream_Audio, i, __T("Format/Info"), Info_Text, Info_Name).c_str());
			audioStream.isDefault = wcharToString(MI.Get(Stream_Audio, i, __T("Default"), Info_Text, Info_Name).c_str());
			audioStream.isForced = wcharToString(MI.Get(Stream_Audio, i, __T("Forced"), Info_Text, Info_Name).c_str());
			audioStream.language = wcharToString(MI.Get(Stream_Audio, i, __T("Language"), Info_Text, Info_Name).c_str());
			audioStream.languageFull = wcharToString(MI.Get(Stream_Audio, i, __T("Language/String"), Info_Text, Info_Name).c_str());
			audioStream.profile = wcharToString(MI.Get(Stream_Audio, i, __T("Format_Profile"), Info_Text, Info_Name).c_str());
			audioStream.sampleRate = wcharToUint32(MI.Get(Stream_Audio, i, __T("SamplingRate"), Info_Text, Info_Name).c_str());
			audioStream.size = wcharToDouble(MI.Get(Stream_Audio, i, __T("StreamSize"), Info_Text, Info_Name).c_str());
			fileContext.audioStreams.push_back(audioStream);
		}

		uint32_t numTextStreams = boost::numeric_cast<uint32_t>(MI.Count_Get(Stream_Text, -1));
		for (i = 0; i < numTextStreams; ++i) {
			TextStream textStream;
			textStream.codecId = wcharToString(MI.Get(Stream_Text, i, __T("CodecID"), Info_Text, Info_Name).c_str());
			textStream.codecName = wcharToString(MI.Get(Stream_Text, i, __T("Codec/Info"), Info_Text, Info_Name).c_str());
			textStream.format = wcharToString(MI.Get(Stream_Text, i, __T("Format"), Info_Text, Info_Name).c_str());
			textStream.id = wcharToUint32(MI.Get(Stream_Text, i, __T("ID"), Info_Text, Info_Name).c_str());
			textStream.isDefault = wcharToString(MI.Get(Stream_Text, i, __T("Default"), Info_Text, Info_Name).c_str());
			textStream.isForced = wcharToString(MI.Get(Stream_Text, i, __T("Forced"), Info_Text, Info_Name).c_str());
			textStream.language = wcharToString(MI.Get(Stream_Text, i, __T("Language"), Info_Text, Info_Name).c_str());
			textStream.languageFull = wcharToString(MI.Get(Stream_Text, i, __T("Language/String"), Info_Text, Info_Name).c_str());
			fileContext.textStreams.push_back(textStream);
		}
		MI.Close();
		std::string returnVal = "";
		FREDispatchStatusEventAsync(dllContext, (uint8_t*)returnVal.c_str(), (const uint8_t*) "ON_FILE_INFO");
		
		mutex.unlock();
	}

	FREObject getInfo(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		FREObject ret = NULL;
		FRENewObject((const uint8_t*)"com.tuarua.MediaInfo", 0, NULL, &ret, NULL);
		if(!fileContext.name.empty())
			FRESetObjectProperty(ret, (const uint8_t*)"name", getFREObjectFromString(fileContext.name), NULL);
		if (!fileContext.format.empty())
			FRESetObjectProperty(ret, (const uint8_t*)"format", getFREObjectFromString(fileContext.format), NULL);
		if (!fileContext.profile.empty())
			FRESetObjectProperty(ret, (const uint8_t*)"profile", getFREObjectFromString(fileContext.profile), NULL);
		if (!fileContext.codecId.empty())
			FRESetObjectProperty(ret, (const uint8_t*)"codecId", getFREObjectFromString(fileContext.codecId), NULL);
		if (!fileContext.encoder.empty())
			FRESetObjectProperty(ret, (const uint8_t*)"encoder", getFREObjectFromString(fileContext.encoder), NULL);
		if(fileContext.fileSize > 0)
			FRESetObjectProperty(ret, (const uint8_t*)"fileSize", getFREObjectFromDouble(fileContext.fileSize), NULL);
		if (fileContext.duration > 0)
			FRESetObjectProperty(ret, (const uint8_t*)"duration", getFREObjectFromUint32(fileContext.duration), NULL);
		if (fileContext.bitrate > 0)
			FRESetObjectProperty(ret, (const uint8_t*)"bitrate", getFREObjectFromUint32(fileContext.bitrate), NULL);
		if (!fileContext.bitrateMode.empty())
			FRESetObjectProperty(ret, (const uint8_t*)"bitrateMode", getFREObjectFromString(fileContext.bitrateMode), NULL);

		int cnt = 0;
		FREObject vecVideoStreams = NULL;
		FRENewObject((const uint8_t*)"Vector.<com.tuarua.mediainfo.VideoStream>", 0, NULL, &vecVideoStreams, NULL);
		for (std::vector<VideoStream>::const_iterator i = fileContext.videoStreams.begin(); i != fileContext.videoStreams.end(); ++i) {
			FREObject objStream = NULL;
			FRENewObject((const uint8_t*)"com.tuarua.mediainfo.VideoStream", 0, NULL, &objStream, NULL);

			FRESetObjectProperty(objStream, (const uint8_t*)"id", getFREObjectFromUint32(i->id), NULL);
			FRESetObjectProperty(objStream, (const uint8_t*)"aspectRatio", getFREObjectFromDouble(i->aspectRatio), NULL);
			FRESetObjectProperty(objStream, (const uint8_t*)"aspectRatioAsString", getFREObjectFromString(i->aspectRatioAsString), NULL);
			FRESetObjectProperty(objStream, (const uint8_t*)"bitDepth", getFREObjectFromUint32(i->bitDepth), NULL);
			FRESetObjectProperty(objStream, (const uint8_t*)"bitrate", getFREObjectFromUint32(i->bitrate), NULL);
			FRESetObjectProperty(objStream, (const uint8_t*)"maxBitrate", getFREObjectFromUint32(i->maxBitrate), NULL);
			if (!i->bitrateMode.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"bitrateMode", getFREObjectFromString(i->bitrateMode), NULL);
			FRESetObjectProperty(objStream, (const uint8_t*)"bits", getFREObjectFromDouble(i->bits), NULL);
			FRESetObjectProperty(objStream, (const uint8_t*)"cabac", getFREObjectFromBool(i->cabac), NULL);
			if (!i->chroma.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"chroma", getFREObjectFromString(i->chroma), NULL);
			if (!i->codecId.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"codecId", getFREObjectFromString(i->codecId), NULL);
			if (!i->codecName.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"codecName", getFREObjectFromString(i->codecName), NULL);
			if (!i->colorSpace.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"colorSpace", getFREObjectFromString(i->colorSpace), NULL);
			FRESetObjectProperty(objStream, (const uint8_t*)"duration", getFREObjectFromUint32(i->duration), NULL);
			if (!i->encoder.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"encoder", getFREObjectFromString(i->encoder), NULL);
			if (!i->encoderSettings.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"encoderSettings", getFREObjectFromString(i->encoderSettings), NULL);
			if (!i->format.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"format", getFREObjectFromString(i->format), NULL);
			if (!i->formatName.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"formatName", getFREObjectFromString(i->formatName), NULL);
			FRESetObjectProperty(objStream, (const uint8_t*)"framerate", getFREObjectFromDouble(i->framerate), NULL);
			if (!i->framerateMode.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"framerateMode", getFREObjectFromString(i->framerateMode), NULL);	
			FRESetObjectProperty(objStream, (const uint8_t*)"height", getFREObjectFromUint32(i->height), NULL);
			if (!i->profile.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"profile", getFREObjectFromString(i->profile), NULL);
			FRESetObjectProperty(objStream, (const uint8_t*)"refFrames", getFREObjectFromUint32(i->refFrames), NULL);
			if (!i->scanType.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"scanType", getFREObjectFromString(i->scanType), NULL);
			FRESetObjectProperty(objStream, (const uint8_t*)"size", getFREObjectFromDouble(i->size), NULL);
			FRESetObjectProperty(objStream, (const uint8_t*)"width", getFREObjectFromUint32(i->width), NULL);

			FRESetArrayElementAt(vecVideoStreams, cnt, objStream);
			cnt++;

		}
		FRESetObjectProperty(ret, (const uint8_t*)"videoStreams", vecVideoStreams, NULL);

		FREObject vecAudioStreams = NULL;
		FRENewObject((const uint8_t*)"Vector.<com.tuarua.mediainfo.AudioStream>", 0, NULL, &vecAudioStreams, NULL);
		cnt = 0;
		for (std::vector<AudioStream>::const_iterator i = fileContext.audioStreams.begin(); i != fileContext.audioStreams.end(); ++i) {
			FREObject objStream = NULL;
			FRENewObject((const uint8_t*)"com.tuarua.mediainfo.AudioStream", 0, NULL, &objStream, NULL);
			FRESetObjectProperty(objStream, (const uint8_t*)"id", getFREObjectFromUint32(i->id), NULL);
				FRESetObjectProperty(objStream, (const uint8_t*)"alternateGroup", getFREObjectFromUint32(i->alternateGroup), NULL);
			FRESetObjectProperty(objStream, (const uint8_t*)"bitrate", getFREObjectFromUint32(i->bitrate), NULL);
			FRESetObjectProperty(objStream, (const uint8_t*)"maxBitrate", getFREObjectFromUint32(i->maxBitrate), NULL);
			if (!i->bitrateMode.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"bitrateMode", getFREObjectFromString(i->bitrateMode), NULL);
			if (!i->channelLayout.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"channelLayout", getFREObjectFromString(i->channelLayout), NULL);
			FRESetObjectProperty(objStream, (const uint8_t*)"channels", getFREObjectFromUint32(i->channels), NULL);
			if (!i->codecId.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"codecId", getFREObjectFromString(i->codecId), NULL);
			if (!i->codecName.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"codecName", getFREObjectFromString(i->codecName), NULL);
			if (!i->compressionMode.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"compressionMode", getFREObjectFromString(i->compressionMode), NULL);
			FRESetObjectProperty(objStream, (const uint8_t*)"duration", getFREObjectFromUint32(i->duration), NULL);
			if (!i->format.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"format", getFREObjectFromString(i->format), NULL);
			if (!i->formatName.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"formatName", getFREObjectFromString(i->formatName), NULL);
			FRESetObjectProperty(objStream, (const uint8_t*)"isDefault", getFREObjectFromBool(i->isDefault), NULL);
			FRESetObjectProperty(objStream, (const uint8_t*)"isForced", getFREObjectFromBool(i->isForced), NULL);
			if (!i->language.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"language", getFREObjectFromString(i->language), NULL);
			if (!i->languageFull.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"languageFull", getFREObjectFromString(i->languageFull), NULL);
			if (!i->profile.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"profile", getFREObjectFromString(i->profile), NULL);
			FRESetObjectProperty(objStream, (const uint8_t*)"sampleRate", getFREObjectFromUint32(i->sampleRate), NULL);
			FRESetObjectProperty(objStream, (const uint8_t*)"size", getFREObjectFromDouble(i->size), NULL);

			FRESetArrayElementAt(vecAudioStreams, cnt, objStream);
			cnt++;
		}
		FRESetObjectProperty(ret, (const uint8_t*)"audioStreams", vecAudioStreams, NULL);


		FREObject vecTextStreams = NULL;
		FRENewObject((const uint8_t*)"Vector.<com.tuarua.mediainfo.TextStream>", 0, NULL, &vecTextStreams, NULL);
		cnt = 0;
		for (std::vector<TextStream>::const_iterator i = fileContext.textStreams.begin(); i != fileContext.textStreams.end(); ++i) {
			FREObject objStream = NULL;
			FRENewObject((const uint8_t*)"com.tuarua.mediainfo.TextStream", 0, NULL, &objStream, NULL);
			FRESetObjectProperty(objStream, (const uint8_t*)"id", getFREObjectFromUint32(i->id), NULL);
			if (!i->codecId.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"codecId", getFREObjectFromString(i->codecId), NULL);
			if (!i->codecName.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"codecName", getFREObjectFromString(i->codecName), NULL);
			if (!i->language.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"language", getFREObjectFromString(i->language), NULL);
			if (!i->languageFull.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"languageFull", getFREObjectFromString(i->languageFull), NULL);
			FRESetObjectProperty(objStream, (const uint8_t*)"isDefault", getFREObjectFromBool(i->isDefault), NULL);
			FRESetObjectProperty(objStream, (const uint8_t*)"isForced", getFREObjectFromBool(i->isForced), NULL);
			if (!i->format.empty())
				FRESetObjectProperty(objStream, (const uint8_t*)"format", getFREObjectFromString(i->format), NULL);

			FRESetArrayElementAt(vecTextStreams, cnt, objStream);
			cnt++;
		}

		FRESetObjectProperty(ret, (const uint8_t*)"textStreams", vecTextStreams, NULL);

		return ret;
	}

	char *toCString(std::string str) {
		char *cStr = new char[str.length() + 1];
		std::strcpy(cStr, str.c_str());
		return cStr;
	}
/*
	FREObject getInfoItem(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace std;
		string itemStr = getStringFromFREObject(argv[2]);
		string fileNameStr = getStringFromFREObject(argv[0]);

		char * itemCStr = toCString(itemStr);
		char * fileNameCStr = toCString(fileNameStr);

		const char * itemChar = (const char *)itemCStr;
		const char * fileNameChar = (const char *)fileNameCStr;

		size_t sizeFileName = strlen(fileNameChar) + 1;
		size_t sizeItem = strlen(itemChar) + 1;
		wchar_t *fileName = new wchar_t[sizeFileName];
		wchar_t *item = new wchar_t[sizeItem];

#ifdef _WIN32
		size_t numFilenameChars = 0;
		size_t numItemChars = 0;
		mbstowcs_s(&numFilenameChars, fileName, sizeFileName, fileNameChar, _TRUNCATE);
		mbstowcs_s(&numItemChars, item, sizeItem, itemChar, _TRUNCATE);
#else
		mbstowcs(fileName, fileNameChar, sizeFileName);
		mbstowcs(item, itemChar, sizeItem);
#endif
		infoContext.fileName = fileName;

		string typeStr = getStringFromFREObject(argv[1]);
		
		enum stream_t type;
		if (typeStr == "General")
			type = Stream_General;
		else if (typeStr == "Video")
			type = Stream_Video;
		else if (typeStr == "Audio")
			type = Stream_Audio;
		else if (typeStr == "Text")
			type = Stream_Text;
		else if (typeStr == "Other")
			type = Stream_Other;
		else if (typeStr == "Image")
			type = Stream_Image;
		else if (typeStr == "Menu")
			type = Stream_Menu;
		else if (typeStr == "Max")
			type = Stream_Max;
		else
			type = Stream_General;

		MediaInfo MI;
		MI.Open(infoContext.fileName);
		String sItem = item;
		string ret = wcharToString(MI.Get(type, 0, sItem, Info_Text, Info_Name).c_str());

		MI.Close();
		return getFREObjectFromString(ret);
	}
	*/
	FREObject triggerGetInfoItem(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace std;
		string itemStr = getStringFromFREObject(argv[2]);
		string fileNameStr = getStringFromFREObject(argv[0]);

		char * itemCStr = toCString(itemStr);
		char * fileNameCStr = toCString(fileNameStr);

		const char * itemChar = (const char *)itemCStr;
		const char * fileNameChar = (const char *)fileNameCStr;

		size_t sizeFileName = strlen(fileNameChar) + 1;
		size_t sizeItem = strlen(itemChar) + 1;
		wchar_t *fileName = new wchar_t[sizeFileName];
		wchar_t *item = new wchar_t[sizeItem];

#ifdef _WIN32
		size_t numFilenameChars = 0;
		size_t numItemChars = 0;
		mbstowcs_s(&numFilenameChars, fileName, sizeFileName, fileNameChar, _TRUNCATE);
		mbstowcs_s(&numItemChars, item, sizeItem, itemChar, _TRUNCATE);
#else
		mbstowcs(fileName, fileNameChar, sizeFileName);
		mbstowcs(item, itemChar, sizeItem);
#endif
		infoContext.fileName = fileName;
		infoContext.item = item;
		infoContext.type = getStringFromFREObject(argv[1]);

		threads[0] = boost::move(createThread(&threadFileInfoItem, 1));

		return getFREObjectFromBool(true);

	}
	FREObject triggerGetInfo(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		const char *orig = getStringFromFREObject(argv[0]).c_str();
		size_t newsize = strlen(orig) + 1;
		wchar_t *fileName = new wchar_t[newsize];
		
#ifdef _WIN32
        size_t convertedChars = 0;
        mbstowcs_s(&convertedChars, fileName, newsize, orig, _TRUNCATE);
#else
        mbstowcs(fileName , orig, newsize);
#endif
        
        using namespace std;
		infoContext.fileName = fileName;
		threads[0] = boost::move(createThread(&threadFileInfo, 1));
		return getFREObjectFromBool(true);
	}
	FREObject isSupported(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		return getFREObjectFromBool(isSupportedInOS);
	}
	
	void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet) {
		static FRENamedFunction extensionFunctions[] = {
			{ (const uint8_t*) "isSupported",NULL, &isSupported}
			,{(const uint8_t*) "triggerGetInfo",NULL, &triggerGetInfo}
			,{(const uint8_t*) "getInfo",NULL, &getInfo}
			,{(const uint8_t*) "triggerGetInfoItem",NULL, &triggerGetInfoItem}
			,{(const uint8_t*) "getVersion",NULL, &getLibVersion}
		};

		*numFunctionsToSet = sizeof(extensionFunctions) / sizeof(FRENamedFunction);
		*functionsToSet = extensionFunctions;
		dllContext = ctx;
	}


	void contextFinalizer(FREContext ctx) {
		return;
	}

	void TRMIAExtInizer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer) {
		*ctxInitializer = &contextInitializer;
		*ctxFinalizer = &contextFinalizer;
	}

	void TRMIAExtFinizer(void* extData) {
		FREContext nullCTX;
		nullCTX = 0;
		contextFinalizer(nullCTX);
		return;
	}

}