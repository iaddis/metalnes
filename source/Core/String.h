

#pragma once

#include <string>
#include <vector>
#include <stdarg.h>
#include <stdint.h>

namespace Core
{
    using StringVector = std::vector<std::string>;

    namespace String
    {
        bool Parse(const std::string &str, int &value);
        bool Parse(const std::string &str, int64_t &value);
        bool ParseHex(const std::string &str, int &value);

        StringVector Split(const std::string &str, char delim, bool removeEmptyEntries = false, bool trim = false);
        std::string  Join(const Core::StringVector &list, const std::string &delim);
        bool         Contains(const Core::StringVector &list, const std::string &other);
        void         Merge(Core::StringVector &dest, const std::string &other);
        void         Merge(Core::StringVector &dest, const Core::StringVector &src);


        // converts wide C string to UTF8 std::string
        std::string  Convert(const wchar_t *wstr);
        // converts UTF8 C string to std::wstring
        std::wstring Convert(const char *str);
        // converts wide std::wstring to a UTF8 std::string
        std::string  Convert(const std::wstring &str);
        // converts UTF8 std::string to a wide std::wstring
        std::wstring Convert(const std::string &str);

        // formats a string and returns it
        std::string  Format(const char *format, ...);
        std::string  FormatV(const char *format, va_list args);
        
        std::string  Trim(const std::string &str);
        std::string  TrimLeft(const std::string &str);
        std::string  TrimRight(const std::string &str);

        std::string  ToLower(const std::string &str);
        std::string  ToUpper(const std::string &str);
        
        int          CompareNoCase(const std::string &a, const std::string &b);
        bool         StartsWith(const std::string &str, const std::string &prefix);
        
      
        std::string  Escape(const std::string &in);
        std::string  Escape(const std::string &in, const char *reserved);
        std::string  Unescape(const std::string &in);

    }
}

