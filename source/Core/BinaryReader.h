
#pragma once

#include <stdint.h>
#include <vector>
#include <string>

namespace Core {

	class BinaryReader
	{
	public:
		virtual uint8_t ReadByte() = 0;
		virtual void ReadBytes(uint8_t *buffer, int count) = 0;
		virtual int  GetLength() = 0;

		inline BinaryReader() {}
		inline virtual ~BinaryReader() {}

		virtual uint16_t Read16LE()
		{
			uint16_t v;
			v = ReadByte();
			v |= ReadByte() << 8;
			return v;
		}

		virtual uint32_t Read32LE()
		{
			uint32_t v;
			v = ReadByte();
			v |= ReadByte() << 8;
			v |= ReadByte() << 16;
			v |= ReadByte() << 24;
			return v;
		}

		template <typename T>
		void ReadStruct(T &v)
		{
			ReadBytes((uint8_t *)&v, sizeof(v));
		}

		template <typename T>
		T ReadStruct()
		{
			T v;
			ReadBytes((uint8_t *)&v, sizeof(v));
			return v;
		}

		virtual const uint8_t *ReadAllocBytes(int count)
		{
			uint8_t *data = new uint8_t[count];
			ReadBytes(data, count);
			return data;
		}
	};


class VectorByteStream
{
    std::vector<uint8_t> &_data;
    
    std::vector<uint8_t>::const_iterator _data_pos;
    std::vector<uint8_t>::const_iterator _data_end;
    
public:
    VectorByteStream(std::vector<uint8_t> &data)
        :_data(data)
    {
        _data_pos = _data.cbegin();
        _data_end = _data.cend();
    }
    
    inline uint8_t ReadByte()
    {
        if (_data_pos == _data_end)
        {
            return 0;
        }
        
        return *_data_pos++;
    }
    
    inline size_t GetLength() const
    {
        return _data.size();
    }
    
};

template<typename TInput>
class BinReaderLE
{
    TInput &_input;
public:
    
    BinReaderLE(TInput &input)
        :_input(input)
    {
    }
    
    inline uint8_t ReadByte()
    {
        return _input.ReadByte();
    }
    
    void Read(uint8_t &v)
    {
        v = ReadByte();
    }

    void Read(uint16_t &v)
    {
        v = ReadByte();
        v |= ReadByte() << 8;
    }

    void Read(uint32_t &v)
    {
        v = ReadByte();
        v |= ReadByte() << 8;
        v |= ReadByte() << 16;
        v |= ReadByte() << 24;
    }

 
    
    template<typename T>
    void ReadArray(T *array, size_t count)
    {
        for (size_t i=0; i < count; i++)
        {
            Read(array[i]);
        }
    }
    
    template<typename T>
    void ReadVector(std::vector<T> &v, size_t count)
    {
        v.resize(count);
        for (size_t i=0; i < count; i++)
        {
            Read(v[i]);
        }
    }
};



template<typename TInput, typename TValue>
inline BinReaderLE<TInput> & operator <<(BinReaderLE<TInput> &br,  TValue &value)
{
    br.Read(value);
    return br;
}



} // namespace Core
