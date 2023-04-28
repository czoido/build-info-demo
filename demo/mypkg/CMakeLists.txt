cmake_minimum_required(VERSION 3.15)
project(mypkg CXX)

find_package(liba CONFIG REQUIRED)



add_library(mypkg src/mypkg.cpp)
target_include_directories(mypkg PUBLIC include)

target_link_libraries(mypkg PRIVATE liba::liba)


set_target_properties(mypkg PROPERTIES PUBLIC_HEADER "include/mypkg.h")
install(TARGETS mypkg)
