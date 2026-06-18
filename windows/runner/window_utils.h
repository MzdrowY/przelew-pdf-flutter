#ifndef WINDOW_UTILS_H_
#define WINDOW_UTILS_H_

#include <windows.h>

#include <flutter/flutter_view_controller.h>

// Registers a method channel that allows Dart code to control native
// window properties (e.g. title bar dark mode).
void RegisterWindowUtils(flutter::FlutterEngine* engine, HWND window_handle);

#endif  // WINDOW_UTILS_H_
