

#pragma once

#include <stdint.h>
#include <memory>
#include <vector>
#include <string>
#include <array>

namespace metalnes {


using nesrom_ptr = std::shared_ptr<struct nesrom>;

struct nesrom
{

    std::string path;
    std::string name;

    uint8_t tag[4];
    uint8_t prgCount16K;
    uint8_t chrCount8K;
    uint8_t flags;
    uint8_t flags2;
    uint8_t pad[8];

    std::vector<uint8_t> chr_rom;
    std::vector<uint8_t> prg_rom;

    static nesrom_ptr LoadFromFile(std::string path);
};




} // namespace
