#pragma once


#ifdef _WIN32
  #define LIBA_EXPORT __declspec(dllexport)
#else
  #define LIBA_EXPORT
#endif

LIBA_EXPORT void liba();
