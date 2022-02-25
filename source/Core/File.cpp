
#include <stdio.h>
#include <sys/stat.h>
#include <string>
#include "Core/File.h"
#include "Core/Path.h"

#ifdef WIN32
#include <direct.h>

// This is the only file that should be including windows.h
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#endif

#ifdef __APPLE__
#include "CoreFoundation/CoreFoundation.h"

#include <sys/types.h>
#include <dirent.h>
#endif


#ifdef __linux__
#include <sys/types.h>
#include <dirent.h>
#endif


namespace Core {

	bool File::Exists(const char *path)
	{
		struct stat s;
		return stat(path, &s) != 0;
	}
    
    
    bool File::WriteAllBytes(std::string path, const uint8_t *data, size_t length)
    {
        std::string fullpath = path;

        FILE *file = fopen(fullpath.c_str(), "wb");
        if (!file) return false;
        
        bool result = fwrite( data, 1, length, file) == length;
        fclose(file);
        return result;
    }

    bool File::WriteAllBytes(std::string path, std::vector<uint8_t> &data)
    {
        return WriteAllBytes(path, data.data(), data.size());
    }


    bool File::WriteAllText(std::string path, const char *text, size_t length)
    {
        FILE *file = fopen(path.c_str(), "wt");
        if (!file) return false;
        
        
        size_t result = fwrite( text, sizeof(text[0]), length, file);
        fclose(file);
        return result == length;
    }

    bool File::WriteAllText(std::string path, const std::string_view &text)
    {
        return WriteAllText(path, text.data(), text.size());
    }

    bool File::ReadAllBytes(std::string path, std::vector<uint8_t> &data)
    {
        FILE *file = fopen(path.c_str(), "rb");
        if (!file) return false;
        
        fseek(file, 0, SEEK_END);
        long length = ftell(file);
        fseek(file, 0, SEEK_SET);
        
        data.resize(length);
        
        size_t result = fread(data.data(), 1, data.size(), file);
        fclose(file);
        return result == data.size();
    }
    
    bool File::ReadAllText(std::string path, std::string &text)
    {
        FILE *file = fopen(path.c_str(), "rt");
        if (!file) return false;
        
        fseek(file, 0, SEEK_END);
        long length = ftell(file);
        fseek(file, 0, SEEK_SET);
        
        text.resize(length);
        
        size_t result = fread( (char *)text.data(), 1, text.size(), file);
        fclose(file);
        return result == text.size();
        
    }


    bool Directory::Exists(std::string path)
    {
        struct stat s;
        return stat(path.c_str(), &s) != 0;
    }

    bool Directory::Create(std::string path)
    {
    #if WIN32
        return _mkdir(path.c_str(), 0755) == 0;
    #else
        return mkdir(path.c_str(), 0755) == 0;
    #endif

    }

    void Directory::GetDirectoryFiles(std::string dir, std::vector<std::string> &files, bool recurse)
    {
        #ifdef WIN32
        WIN32_FIND_DATA fd;
        memset(&fd, 0, sizeof(fd));

        std::string mask = dir + "\\*.*";

        HANDLE hFind = FindFirstFile(mask.c_str(), &fd);
        if (hFind == INVALID_HANDLE_VALUE)
        {
            return;
        }

        do
        {
            if (fd.cFileName[0] == '.')
                continue;
            
            std::string path = Path::Combine(dir, fd.cFileName);
            
            if ((fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) != 0)
            {
                if (recurse)
                {
                    GetDirectoryFiles(path.c_str(), files, recurse);
                }
                continue;
            }
            
            files.push_back(path);
        } while (FindNextFile(hFind, &fd));

        FindClose(hFind);
        #elif __APPLE__ || __linux__
        DIR *dp = opendir(dir.c_str());
        if (!dp)
            return;

        for (;;)
        {
            struct dirent *ep = readdir (dp);
            if (!ep) break;
            if (ep->d_name[0] == '.') continue; // skip '.' anything
            
            std::string path =  Path::Combine(dir, ep->d_name);
            
            if ((ep->d_type & DT_DIR) !=0 ) {
                if (recurse) {
                    GetDirectoryFiles(path, files, recurse);
                }
            }
            
            if ((ep->d_type & DT_REG) !=0 ) {
                files.push_back(path);
            }
        }

        closedir (dp);
        #endif
    }



}
