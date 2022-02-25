
#include "Core/Path.h"
#include "Core/String.h"
#include <algorithm>

#include "UnitTests.h"

namespace Core {
    
std::string Path::GetExtension(const std::string &path)
{
    size_t pos = path.find_last_of("./\\");
    if (pos != std::string::npos && path[pos] == '.')
    {
        return path.substr(pos);
    }
    else
    {
        return "";
    }
}

std::string Path::GetExtensionLower(const std::string &path)
{
    return Core::String::ToLower(Path::GetExtension(path));
}

std::string Path::GetFileName(const std::string &path)
{
    size_t pos = path.find_last_of("/\\");
    
    if (pos != std::string::npos)
    {
        return path.substr(pos + 1);
    }
    else
    {
        return path;
    }
}

std::string Path::GetDirectory(const std::string &path)
{
    size_t pos = path.find_last_of("/\\");
    
    if (pos != std::string::npos)
    {
        return path.substr(0, pos);
    }
    else
    {
        return std::string();
    }
}
    

std::string Path::GetLastComponent(const std::string &path)
{
    size_t pos = path.find_last_of("/\\");
    size_t end = path.size();
    if (pos == (end - 1))
    {
        // we have a trailing slash, skip it
        end = pos;
        pos = path.find_last_of("/\\", pos - 1);
    }
    
    if (pos != std::string::npos)
    {
        return path.substr(pos + 1, end - pos - 1);
    }
    else
    {
        return std::string();
    }
}

std::string Path::RemoveExtension(const std::string &path)
{
    size_t pos = path.find_last_of("./\\");
    if (pos != std::string::npos && path[pos] == '.')
    {
        return path.substr(0, pos);
    }
    else
    {
        return path;
    }
}

std::string Path::ChangeExtension(const std::string &path, const std::string &ext)
{
    return RemoveExtension(path) + ext;
}

    
std::string Path::RemoveTrailingSlash(const std::string &path)
{
    std::string result = path;
    if (result.size() > 0)
    {
        char last = result[result.size()-1];
        if (last == '/' || last == '\\')
        {
            // remove trailing slash
            result.resize(result.size()-1);
        }
    }
    return result;
}

std::string Path::AddTrailingSlash(const std::string &path)
{
    std::string result = path;
    if (result.size() > 0)
    {
        char last = result[result.size()-1];
        if (last != '/' && last != '\\')
        {
            // add trailing slash
            result.push_back('/');
        }
    } 
    else
    {
        // add trailing slash to empty path
        result.push_back('/');
    }
    return result;
}
    

std::string Path::Combine(const std::string &basePath, const std::string &relative)
{
    if (!relative.empty() && relative[0] == '/') {
        return relative;
    }
    
    if (basePath.empty())
    {
        return relative;
    }

    std::string path = AddTrailingSlash(basePath);
    path += relative;
    return path;
}
    

SCENARIO("Path Tests")
{
    std::string a = "/test/abc";
    
    std::string b = "def";
    
    REQUIRE( Path::Combine(a, b) == "/test/abc/def");

    REQUIRE( Path::Combine(b, a) == "/test/abc");

}

    


}
