
#pragma once

#include <stdint.h>
#include <string>
#include <vector>
#include <string_view>   
#include "BinaryReader.h"

namespace Core {

	class File
	{
	public:
		static bool			Exists(const char *path);
        
        static bool ReadAllText(std::string path, std::string &text);
        static bool WriteAllText(std::string path, const std::string_view &text);
        static bool WriteAllText(std::string path, const char *text, size_t length);

        static bool ReadAllBytes(std::string path, std::vector<uint8_t> &data);
        static bool WriteAllBytes(std::string path, std::vector<uint8_t> &data);
        static bool WriteAllBytes(std::string path, const uint8_t *data, size_t length);

	};


    class Directory
    {
    public:
        static bool Exists(std::string path);
        static bool Create(std::string path);
        static void GetDirectoryFiles(std::string dir, std::vector<std::string> &files, bool recurse);

    };



}
