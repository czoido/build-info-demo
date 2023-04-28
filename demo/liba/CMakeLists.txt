cmake_minimum_required(VERSION 3.15)
project(liba CXX)




add_library(liba src/liba.cpp)
target_include_directories(liba PUBLIC include)



set_target_properties(liba PROPERTIES PUBLIC_HEADER "include/liba.h")
install(TARGETS liba)
