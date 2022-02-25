
#include "Core/String.h"

#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>

#include <algorithm>
#include <assert.h>

//----------------------------------

namespace Core {
namespace String {

	bool Parse(const std::string &str, int &value)
	{
		char *end = NULL;
		value = (int)strtol(str.c_str(), &end, 10);
		return end != str.c_str();
	}

	bool Parse(const std::string &str, int64_t &value)
	{
		char *end = NULL;
#ifdef WIN32
		value = _strtoi64(str.c_str(), &end, 10);
#else
		value = strtoll(str.c_str(), &end, 10);
#endif
		return end != str.c_str();
	}

	bool ParseHex(const std::string &str, int &value)
	{
		char *end = NULL;
		value = (int)strtol(str.c_str(), &end, 16);
		return end != str.c_str();
	}

	/*static*/
	StringVector Split(const std::string &str, char delim, bool removeEmptyEntries, bool trim)
	{
		StringVector list;

		int start = 0;
		int i;
		for (i = 0; i < (int)str.size(); i++)
		{
			if (str[i] == delim)
			{
				// end of item
				std::string item = str.substr(start, i - start);
				if (trim)
				{
					item = Trim(item);
				}

				if (!removeEmptyEntries || !item.empty())
				{
					list.push_back(item);
				}
				// skip delimiter
				start = i + 1;
			}
		}

		//if (i != start)
		{
			// last item
			std::string item = str.substr(start, i - start);
			if (trim)
			{
				item = Trim(item);
			}
			if (!removeEmptyEntries || !item.empty())
			{
				list.push_back(item);
			}
		}

		return list;

	}

	std::string Join(const Core::StringVector &list, const std::string &delim)
	{
		std::string str;
		for (size_t i = 0; i < list.size(); i++)
		{
			str += list[i];
			if (i < (list.size() - 1))
			{
				str += delim;
			}
		}
		return str;
	}



	bool Contains(const Core::StringVector &list, const std::string &src)
	{
		for (size_t j = 0; j < list.size(); j++)
		{
			if (src == list[j])
			{
				return true;
			}
		}
		return false;
	}



	void Merge(Core::StringVector &dest, const std::string &src)
	{
		if (!Contains(dest, src))
		{
			dest.push_back(src);
		}
	}


	void Merge(Core::StringVector &dest, const Core::StringVector &src)
	{
		for (size_t i = 0; i < src.size(); i++)
		{
			Merge(dest, src[i]);
		}
	}


	// converts wide C string to UTF8 std::string
	/*static*/
	std::string  Convert(const wchar_t *wstr)
	{
		// get length of string
		size_t len = wcstombs(NULL, wstr, 0);

		char *buffer = new char[len + 1];
		size_t converted = wcstombs(buffer, wstr, len);
		buffer[len] = 0;

		assert(converted <= len);

		std::string str(buffer);
		delete[] buffer;
		return str;
	}

	// convert UTF8 C string to a wide std::wstring
	/*static*/
	std::wstring  Convert(const char *str)
	{
		// get length of string
		size_t len = mbstowcs(NULL, str, 0);

		wchar_t *buffer = new wchar_t[len + 1];
		size_t converted = mbstowcs(buffer, str, len);
		buffer[len] = 0;

		assert(converted <= len);

		std::wstring wstr(buffer);
		delete[] buffer;
		return wstr;
	}

	/*static*/
	std::wstring Convert(const std::string &str)
	{
		return Convert(str.c_str());
	}

	/*static*/
	std::string Convert(const std::wstring &str)
	{
		return Convert(str.c_str());
	}

	/*static*/
	std::string  FormatV(const char *format, va_list args)
	{
		char buffer[4096];
		char *out = buffer;
		int capacity = sizeof(buffer);

		// print to internal buffer
		va_list argscopy;
		va_copy(argscopy, args);
		int result = vsnprintf(out, capacity, format, argscopy);
		va_end(argscopy);

		// loop until printf succeededs
		while ((result < 0) || (result >= capacity))
		{
			// resize buffer
			if (result < 0)
			{
				// unknown size, so resize buffer
				capacity *= 4;
			}
			else
			{
				// use provided size
				capacity = result + 1;
			}

			// free old buffer
			if (out != buffer)
			{
				delete[] out;
			}

			// allocate buffer
			out = new char[capacity];

			// printf again
			va_copy(argscopy, args);
			result = vsnprintf(out, capacity, format, argscopy);
			va_end(argscopy);
		}

		std::string str(out);
		if (out != buffer)
		{
			delete[] out;
		}

		return str;
	}

	/*static*/
	std::string  Format(const char *format, ...)
	{
		va_list args;
		va_start(args, format);
		std::string str(FormatV(format, args));
		va_end(args);
		return str;
	}

	/*static*/
	std::string  Trim(const std::string &str)
	{
		return TrimLeft(TrimRight(str));

	}

	/*static*/
	std::string  TrimLeft(const std::string &str)
	{
		size_t pos = str.find_first_not_of(" \t\r\n");
		if (std::string::npos != pos)
		{
			return str.substr(pos);
		}
		else
		{
			return std::string();
		}
	}

	/*static*/
	std::string  TrimRight(const std::string &str)
	{
		size_t pos = str.find_last_not_of(" \t\r\n");
		if (pos != std::string::npos)
		{
			return str.substr(0, pos + 1);
		}
		else
		{
			return std::string();
		}
	}

	std::string  ToLower(const std::string &str)
	{
		std::string result(str);
		std::transform(result.begin(), result.end(), result.begin(), tolower);
		return result;
	}


	std::string  ToUpper(const std::string &str)
	{
		std::string result(str);
		std::transform(result.begin(), result.end(), result.begin(), toupper);
		return result;
	}


	int  CompareNoCase(const std::string &a, const std::string &b)
	{
#ifdef WIN32
		return _stricmp(a.c_str(), b.c_str());
#else
		return strcasecmp(a.c_str(), b.c_str());
#endif

	}

	bool StartsWith(const std::string &str, const std::string &prefix)
	{
		if (prefix.size() > str.size())
		{
			return false;
		}

		return str.compare(0, prefix.size(), prefix) == 0;
	}


	static bool IsReservedChar(char c, const char *reserved)
	{
		if (!isprint(c))
		{
			return true;
		}

		for (int j = 0; reserved[j] != 0; j++)
		{
			if (c == reserved[j])
			{
				return true;
			}
		}
		return false;
	}

	static char ToHexDigit(char val)
	{
		val &= 0xF;
		if (val < 10)
		{
			return '0' + val;
		}
		else
		{
			return 'A' + val - 10;
		}
	}

	std::string Escape(const std::string &in)
	{
		return Escape(in, "/ %#&+,:;=?@");
	}

	std::string Escape(const std::string &in, const char *reserved)
	{
		std::string out;

		int length = (int)in.size();
		out.reserve(length);
		for (int i = 0; i < length; i++)
		{
			char c = in[i];
			if (IsReservedChar(c, reserved))
			{
				out += '%';
				out += ToHexDigit((c >> 4) & 0xF);
				out += ToHexDigit((c >> 0) & 0xF);
			}
			else
			{
				out += in[i];
			}
		}

		return out;
	}

	std::string Unescape(const std::string &in)
	{
		std::string out;
		size_t length = in.size();
		out.reserve(length);
		for (size_t i = 0; i < length; i++)
		{
			if (in[i] == '+')
			{
				out += ' ';
			}
			else if (in[i] == '%')
			{
				std::string temp;
				temp.push_back(in[i + 1]);
				temp.push_back(in[i + 2]);

				int val = 0;
				if (Core::String::ParseHex(temp, val))
				{
					out += (char)val;
					i += 2;
				}
				else
				{
					// could not parse escape code
					out += in[i];
				}
			}
			else
			{
				out += in[i];
			}
		}
		return out;
	}

}
}











