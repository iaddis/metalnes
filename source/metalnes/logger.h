

#pragma once

#include <string_view>

void log_printf(const char *format, ...);
void log_write(const std::string_view str);
void log_flush();

void SetCurrentThreadName(const char* threadName);
