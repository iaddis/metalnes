
#pragma once

#include <stdint.h>
#include <string>

bool AudioSaveToFile(std::string path, double sample_rate, const float *sample_data, size_t sample_count);

