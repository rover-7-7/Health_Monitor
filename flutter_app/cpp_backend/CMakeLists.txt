cmake_minimum_required(VERSION 3.10)
project(HealthMonitoringBackend)

# Include the vcpkg toolchain file (adjust path as necessary)
set(CMAKE_TOOLCHAIN_FILE "D:/Desktop/Flutter/flutter_app/cpp_backend/vcpkg/scripts/buildsystems/vcpkg.cmake")

set(CMAKE_CXX_STANDARD 17)

# Include directories for Crow and nlohmann/json
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/crow/include)  # Adjust path as necessary

add_executable(HealthMonitoringBackend main.cpp)

# Link nlohmann_json library if using vcpkg
find_package(nlohmann_json CONFIG REQUIRED)
target_link_libraries(HealthMonitoringBackend PRIVATE nlohmann_json::nlohmann_json)
