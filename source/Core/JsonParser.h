// It's custom because why not. Need to capture comments and support trailing commas.

#pragma once

#include <stdint.h>
#include <string>
#include <functional>
#include <assert.h>

namespace Core {


enum class JsonToken
{
    NONE,
    OBJECT_BEGIN,
    OBJECT_END,
    ARRAY_BEGIN,
    ARRAY_END,
    COLON,
    SEMICOLON,
    EQUALS,
    COMMA,
    STRING,
    BOOLEAN,
    NUMBER,
    BOOLEAN_TRUE,
    BOOLEAN_FALSE,
    END_OF_FILE
};


class JsonTokenizer
{
public:
    
    JsonTokenizer(const std::string &str, const std::string &path)
        :_str(str), _path(path)
    {
        _ptr = _str.c_str();
        NextToken();
    }
    
    
    bool                HasError() const    {return _error;}
    bool                EndOfFile() const   { return _token == JsonToken::END_OF_FILE;}
    JsonToken           Token() const       {return _token;}
    const std::string & TokenValue() const  {return _token_value;}
    const std::string & Comments() const    {return _comments;}
    
    JsonToken NextToken()
    {
        _token = ScanNextToken();
        
        if (_verbose)
            printf("Token %d %s\n", (int)_token, _token_value.c_str());
        return _token;
    }
    
    bool Consume(JsonToken token)
    {
        if (_token != token) {
            SetError("Expected token");
            return false;
        }
        NextToken();
        return true;
    }
    
    bool Expect(JsonToken token)
    {
        if (_token != token) {
            SetError("Expected token");
            assert (0);
            return false;
        }
        return true;
    }

    
    bool ReadString(std::string &v)
    {
        if (!Expect(JsonToken::STRING)) {
            v.clear();
            return false;
            
        }
        v = TokenValue();
        NextToken();
        return true;
    }
    
    std::string ReadString() {
        std::string s;
        ReadString(s);
        return s;
    }

    bool ReadNumber(long &v) {
        if (!Expect(JsonToken::NUMBER)) {
            v = 0;
            return false;
        }
        
        v = strtol( TokenValue().c_str(), nullptr, 10);
        NextToken();
        return true;
    }
    
    bool ReadNumber(int &v) {
        if (!Expect(JsonToken::NUMBER)) {
            v = 0;
            return false;
        }
        
        v = (int)strtol( TokenValue().c_str(), nullptr, 10);
        NextToken();
        return true;
    }

    bool ReadNumber(float &v) {
        if (!Expect(JsonToken::NUMBER)) {
            v = 0;
            return false;
        }
        
        v = strtof( TokenValue().c_str(), nullptr);
        NextToken();
        return true;
    }
    
    bool ReadNumber(double &v) {
        if (!Expect(JsonToken::NUMBER)) {
            v = 0;
            return false;
        }
        
        v = strtod( TokenValue().c_str(), nullptr);
        NextToken();
        return true;
    }
    
//    int ReadNumber() {
//        int v;
//        ReadNumber(v);
//        return v;
//    }
    
    void SetError(const std::string &msg)
    {
        _error = true;
        
        // add path/line/column
        std::string pos = _path;
        pos += '(';
        pos += std::to_string(_line);
        pos += ',';
        pos += std::to_string(_column);
        pos += ')';
        _error_message = pos + ": " + msg;
    }
    
    const std::string &GetErrorMessage() const
    {
        return _error_message;
    }

protected:
    
    char Peek()
    {
        return *_ptr;
    }
    
    char ReadChar()
    {
        char c = *_ptr;
        if (!c) return 0;
        _ptr++;
        _column++;
        if (c == '\n')
        {
            _column = 1;
            _line++;
        }
        return c;
    }
    
    bool IsStringChar(char c)
    {
        return isalnum(c) || c == '_';
    }
    
    JsonToken ScanNextToken()
    {
        _token_value.clear();
        _comments.clear();
        
        for (;;)
        {
            char c = ReadChar();
            if (!c) {
                return JsonToken::END_OF_FILE;
            }
            
            if (isspace(c))
            {
                continue;
            }
            
            // handle "//" comments
            if (c == '/')
            {
                SkipComments();
                continue;
            }
            
            if (c == '"' || c == '\'')
            {
                while (Peek() != c)
                {
                    _token_value += ReadChar();
                }
                ReadChar();
                return JsonToken::STRING;
            }
            
            if (c == '-' || std::isdigit(c))
            {
                _token_value += c;
                
                while (std::isdigit(Peek()) || Peek() == '.')
                {
                    _token_value += ReadChar();
                }
                return JsonToken::NUMBER;
            }
            
            if (IsStringChar(c))
            {
                _token_value += c;
                while (IsStringChar(Peek()))
                {
                    _token_value += ReadChar();
                }
                if (c == 'f' && _token_value == "false") return JsonToken::BOOLEAN_TRUE;
                if (c == 't' && _token_value == "true")  return JsonToken::BOOLEAN_FALSE;

                return JsonToken::STRING;
            }
            
            switch (c)
            {
                case ',':
                    return JsonToken::COMMA;
                case ':':
                    return JsonToken::COLON;
                case ';':
                    return JsonToken::SEMICOLON;
                case '=':
                    return JsonToken::EQUALS;
                case '{':
                    return JsonToken::OBJECT_BEGIN;
                case '}':
                    return JsonToken::OBJECT_END;
                case '[':
                    return JsonToken::ARRAY_BEGIN;
                case ']':
                    return JsonToken::ARRAY_END;
                default:
                    assert(0);
                    return JsonToken::NONE;
            }
            
            
        }
    }
    
    void SkipComments()
    {
        char c = ReadChar();
        
        if (c == '/')
        {
            _comments += "//";
            for (;;)
            {
                char c = ReadChar();
                if (!c) break;
                _comments += c;
                if (c == '\n')
                    break;
            }
            return;
        }

        if (c == '*')
        {
            _comments += "/*";
            for (;;)
            {
                char c = ReadChar();
                if (!c) break;
                _comments += c;
                if (c == '*' && Peek() == '/')
                {
                    _comments += ReadChar();
                    break;
                }
            }
            return;
        }
        
        
        SetError("Couldnt parse comment");
        return;
    }
      
    
    
private:
    JsonToken   _token = JsonToken::NONE;
    const char *_ptr;
    std::string _str;
    
    std::string _path;
    int _line = 1;
    int _column = 1;

    bool _verbose = false;
    bool _error = false;
    std::string _error_message;
    
    
    std::string _comments;
    std::string _token_value;
};


enum class JsonValueType
{
    Invalid,
    Null,
    Object,
    Array,
    Boolean,
    Number,
    String
};

class JsonParser
{
    JsonTokenizer &tr;

public:
    
    JsonParser(JsonTokenizer &tokenizer)
     : tr(tokenizer)
    {
        
    }
    
    
    class ArrayReader;
    class ObjectReader;
    class ValueReader;

    
    class ValueReader
    {
    protected:
        bool _end = false;
        bool _inObject = false;
        JsonTokenizer &tr;

    public:
        
        ValueReader( JsonTokenizer &tokenizer)
            :tr(tokenizer)
        {
        }
        
        virtual ~ValueReader()
        {
        }
        
        bool HasError()
        {
            return tr.HasError();
        }
        
        void SetError(const std::string &msg)
        {
            tr.SetError(msg);
        }
        
        const std::string &GetErrorMessage() const
        {
            return tr.GetErrorMessage();
        }

        
        bool End()
        {
            return _end || tr.HasError();
        }
    
        JsonValueType GetType() const
        {
            switch (tr.Token())
            {
                case JsonToken::BOOLEAN_TRUE:
                case JsonToken::BOOLEAN_FALSE:
                    return JsonValueType::Boolean;
                case JsonToken::NUMBER:
                    return JsonValueType::Number;
                case JsonToken::STRING:
                    return JsonValueType::String;
                case JsonToken::ARRAY_BEGIN:
                    return JsonValueType::Array;
                case JsonToken::OBJECT_BEGIN:
                    return JsonValueType::Object;
                default:
                    return JsonValueType::Invalid;
            }
        }
        
        bool IsObject() const
        {
            return GetType() == JsonValueType::Object;
        }
        
        bool IsString() const
        {
            return GetType() == JsonValueType::String;
        }

        bool IsNumber() const
        {
            return GetType() == JsonValueType::Number;
        }

        bool IsArray() const
        {
            return GetType() == JsonValueType::Array;
        }

        bool IsBoolean() const
        {
            return GetType() == JsonValueType::Boolean;
        }

        void ReadString(std::string &s) {
            tr.ReadString(s);
            NextValue();
        }
        
        std::string ReadString() {
            std::string s;
            tr.ReadString(s);
            NextValue();
            return s;
        }

        void ReadNumber(double &v) {
            tr.ReadNumber(v);
            NextValue();
        }

        void ReadNumber(float &v) {
            tr.ReadNumber(v);
            NextValue();
        }
        

        void ReadNumber(int &v) {
            tr.ReadNumber(v);
            NextValue();
        }
        
        int ReadInteger() {
            int v;
            ReadNumber(v);
            return v;
        }
        
        bool ReadBoolean(bool b) {
            if (tr.Token() == JsonToken::BOOLEAN_TRUE)   {b = true; return true;}
            if (tr.Token() == JsonToken::BOOLEAN_FALSE)  {b = false; return true;}
            return false;
        }

        void ReadArray(std::function<void (ArrayReader &)> reader)
        {
            assert(!_inObject);
            
            {
                _inObject = true;
                ArrayReader ar(tr);
                reader(ar);
                _inObject = false;
            }
            NextValue();
        }
        void ReadObject(std::function<void (ObjectReader &)> reader)
        {
            assert(!_inObject);
            
            {
                _inObject = true;
                ObjectReader ar(tr);
                reader(ar);
                _inObject = false;
            }
            NextValue();
        }
        
        void SkipValue()
        {
            switch(GetType())
            {
                case JsonValueType::Array:
                {
                    ReadArray([](ArrayReader &ar) {
                        while (!ar.End()) ar.SkipValue();
                    });
                    break;
                }
                    
                case JsonValueType::Object:
                {
                    ReadObject([](ObjectReader &ar) {
                        while (!ar.End()) ar.SkipValue();
                    });
                    break;
                }
                default:
                    tr.NextToken();
                    NextValue();
                    break;
            }
        }
        
     


    protected:
        virtual void NextValue()
        {
        }
        
    };
    
    
    class ArrayReader : public  ValueReader
    {
    public:
        ArrayReader( JsonTokenizer &tokenizer)
            :ValueReader(tokenizer)
        {
            tr.Consume(JsonToken::ARRAY_BEGIN);
            _end = (tr.Token() == JsonToken::ARRAY_END);
        }
        
        
        virtual ~ArrayReader()
        {
            // skip all values
            while (!End())
            {
                SkipValue();
            }

            tr.Consume(JsonToken::ARRAY_END);
        }
      
    protected:
        virtual void NextValue() override
        {
            if (tr.Token() == JsonToken::ARRAY_END)
            {
                _end = true;
                return;
            }
            
            if (tr.Token() == JsonToken::COMMA)
            {
                tr.NextToken();

                // allow trailing comma
                if (tr.Token() == JsonToken::ARRAY_END)
                {
                    _end = true;
                }
            }
            else
            {
                tr.SetError("Expected comma");
            }
        }
     
    };
    
    class ObjectReader :  public ValueReader
    {
    private:
        std::string   _key;

    public:
        ObjectReader(JsonTokenizer &tokenizer)
            :ValueReader(tokenizer)
        {
            tr.Consume(JsonToken::OBJECT_BEGIN);
            
            ReadKey();
        }
        
        virtual ~ObjectReader()
        {
            // skip all values
            while (!End())
            {
                SkipValue();
            }

            tr.Consume(JsonToken::OBJECT_END);
        }
        
        
        const std::string &Key()
        {
            return _key;
        }
        

        void ReadKey()
        {
            if (tr.Token() == JsonToken::OBJECT_END)
            {
                _end = true;
                return;
            }

            if (tr.Token() != JsonToken::STRING)
            {
                tr.SetError("Expected object key");
                return;
            }
            
            tr.ReadString(_key);
            tr.Consume(JsonToken::COLON);
        }

    protected:
        virtual void NextValue() override
        {
            if (tr.Token() == JsonToken::OBJECT_END)
            {
                _end = true;
                return;
            }
            
            if (tr.Token() == JsonToken::COMMA)
            {
                tr.NextToken();
            }
            else
            {
                tr.SetError("Expected comma");
                return;
            }
            
            ReadKey();
        }

    };
   
};

} // namespace
