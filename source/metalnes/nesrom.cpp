
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <assert.h>
#include "nesrom.h"
#include "Core/Path.h"
#include "Core/File.h"
#include "Core/BinaryReader.h"

namespace metalnes {


nesrom_ptr nesrom::LoadFromFile(std::string path)
{
    using namespace Core;
    
    std::vector<uint8_t> binary;
    if (!Core::File::ReadAllBytes(path, binary))
    {
        return nullptr;
    }
    
    nesrom_ptr rom = std::make_shared<nesrom>();
    rom->path = path;
    rom->name = Core::Path::GetFileName(path);
    
    VectorByteStream stream {binary};
    BinReaderLE<VectorByteStream> br {stream};
    
    br.ReadArray(rom->tag, sizeof(rom->tag) );
    if (rom->tag[0] != 'N' || rom->tag[1] != 'E' || rom->tag[2] != 'S') {
        return nullptr;
    }
    br.Read(rom->prgCount16K);
    br.Read(rom->chrCount8K);
    br.Read(rom->flags);
    br.Read(rom->flags2);
    br.ReadArray(rom->pad, sizeof(rom->pad) );
    
    br.ReadVector(rom->prg_rom, rom->prgCount16K * 16 * 1024 );
    br.ReadVector(rom->chr_rom, rom->chrCount8K  *  8 * 1024 );

    return rom;
    
}


}
