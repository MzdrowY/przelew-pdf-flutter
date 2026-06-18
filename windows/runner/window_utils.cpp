#include "window_utils.h"

#include <dwmapi.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#ifndef DWMWA_USE_IMMERSIVE_DARK_MODE
#define DWMWA_USE_IMMERSIVE_DARK_MODE 20
#endif

void RegisterWindowUtils(flutter::FlutterEngine* engine, HWND window_handle) {
  if (!engine || !window_handle) {
    return;
  }

  static HWND g_window_handle = window_handle;

  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      engine->messenger(), "window_utils",
      &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler([](const auto& call, auto result) {
    if (call.method_name() == "setTitleBarDarkMode") {
      const auto* args = std::get_if<flutter::EncodableMap>(call.arguments());
      bool is_dark = false;
      if (args) {
        auto it = args->find(flutter::EncodableValue("isDark"));
        if (it != args->end() && std::holds_alternative<bool>(it->second)) {
          is_dark = std::get<bool>(it->second);
        }
      }

      if (g_window_handle) {
        BOOL value = is_dark ? TRUE : FALSE;
        DwmSetWindowAttribute(g_window_handle, DWMWA_USE_IMMERSIVE_DARK_MODE,
                              &value, sizeof(value));
      }
      result->Success();
    } else {
      result->NotImplemented();
    }
  });
}
