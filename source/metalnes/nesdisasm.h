
#pragma once

#include <stdint.h>
#include <string>

namespace metalnes {

int nes_disasm(std::string &str, const uint8_t *mem, uint16_t pc);

}

