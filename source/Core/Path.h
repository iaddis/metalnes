/*
	Path string manipulation functions
*/

#pragma once

#include <string>
#include <vector>

namespace Core {
	class Path {
    public:
		static std::string GetExtension(const std::string &path);
        static std::string GetExtensionLower(const std::string &path);
        static std::string GetFileName(const std::string &path);
        static std::string GetDirectory(const std::string &path);
        static std::string GetLastComponent(const std::string &path);
        static std::string RemoveExtension(const std::string &path);
        static std::string ChangeExtension(const std::string &path, const std::string &ext);
        static std::string RemoveTrailingSlash(const std::string &path);
        static std::string AddTrailingSlash(const std::string &path);
        static std::string Combine(const std::string &basePath, const std::string &relPath);
    };
}
