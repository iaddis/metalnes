
#pragma once

#include <stdint.h>
#include <math.h>

struct Size2D
{
	int width;
	int height;

	Size2D() :width(), height() {}
	Size2D(int width, int height) :width(width), height(height) {}
};


struct Vector2
{
	float x, y;
    
    float Length()  const
    {
        return sqrtf( (x*x) + (y*y) );
    }
    
    float LengthSquared() const
    {
        return (x*x) + (y*y);
    }
    
    Vector2 Normalized() const
    {
        float l = Length();
        if (l > 0.0f) {
            float inv_len = 1.0f / l;
            return Vector2 {x * inv_len, y * inv_len};
        } else {
            return *this;
        }
    }
    

    inline const Vector2 &operator*=(float s)
    {
        x *= s;
        y *= s;
        return *this;
    }
};

inline Vector2 operator+(const Vector2 &a, const Vector2 & b)
{
    return Vector2{a.x + b.x, a.y + b.y};
}

inline Vector2 operator-(const Vector2 & a, const Vector2 & b)
{
    return Vector2{a.x - b.x, a.y - b.y};
}

inline Vector2 operator*(const Vector2 & a, const Vector2 & b)
{
    return Vector2{a.x * b.x, a.y * b.y};
}


inline Vector2 operator*(const Vector2 &a, float s)
{
    return Vector2{a.x * s, a.y * s};
}


static inline float Dot(const Vector2 &p0, const Vector2 &p1)
{
    return (p0.x * p1.x) +  (p0.y * p1.y);
}



struct Vector3
{
	float x, y, z;
};

struct Vector4
{
	float x, y, z, w;
};



int NextPow2(int x);
