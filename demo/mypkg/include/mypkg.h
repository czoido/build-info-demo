#pragma once


#ifdef _WIN32
  #define MYPKG_EXPORT __declspec(dllexport)
#else
  #define MYPKG_EXPORT
#endif

MYPKG_EXPORT void mypkg();
