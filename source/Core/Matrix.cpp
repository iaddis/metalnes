
#include <math.h>
#include "Math.h"


int NextPow2(int x)
{
    if (x <= 0) return 0;
    int i = 1;
    while (i < x) {
        i <<= 1;
    }
    return i;
}

Matrix44 Matrix44::Identity()
{
    return Matrix44
    {
        1,0,0,0,
        0,1,0,0,
        0,0,1,0,
        0,0,0,1
    };
}

Matrix44 Matrix44::Scale(float x, float y, float z, float w)
{
    return Matrix44
    {
        x,0,0,0,
        0,y,0,0,
        0,0,z,0,
        0,0,0,w
    };

}
Matrix44 Matrix44::Translate(float x, float y, float z)
{
    return Matrix44
    {
        1,0,0,0,
        0,1,0,0,
        0,0,1,0,
        x,y,z,1
    };

}



Matrix44 Matrix44::Transpose()
{
    return Matrix44
    {
        m[0],m[4],m[8],m[12],
        m[1],m[5],m[9],m[13],
        m[2],m[6],m[10],m[14],
        m[3],m[7],m[11],m[15]
    };
}


Vector4 Matrix44::multiply(const Matrix44 &m, const Vector4 &v)
{
    Vector4 r =  {
      v.x * m.m[0] + v.y * m.m[4] + v.z * m.m[8] + v.w * m.m[12],
      v.x * m.m[1] + v.y * m.m[5] + v.z * m.m[9] + v.w * m.m[13],
      v.x * m.m[2] + v.y * m.m[6] + v.z * m.m[10] + v.w * m.m[14],
      v.x * m.m[3] + v.y * m.m[7] + v.z * m.m[11] + v.w * m.m[15]
    };
    return r;
}

Matrix44 Matrix44::multiply(const Matrix44 &a, const Matrix44 &b)
{
    Matrix44 o;
    
    o.m[0] = a.m[0] * b.m[0] + a.m[1] * b.m[4] + a.m[2] * b.m[8] + a.m[3] * b.m[12];
    o.m[1] = a.m[0] * b.m[1] + a.m[1] * b.m[5] + a.m[2] * b.m[9] + a.m[3] * b.m[13];
    o.m[2] = a.m[0] * b.m[2] + a.m[1] * b.m[6] + a.m[2] * b.m[10] + a.m[3] * b.m[14];
    o.m[3] = a.m[0] * b.m[3] + a.m[1] * b.m[7] + a.m[2] * b.m[11] + a.m[3] * b.m[15];

    o.m[4] = a.m[4] * b.m[0] + a.m[5] * b.m[4] + a.m[6] * b.m[8] + a.m[7] * b.m[12];
    o.m[5] = a.m[4] * b.m[1] + a.m[5] * b.m[5] + a.m[6] * b.m[9] + a.m[7] * b.m[13];
    o.m[6] = a.m[4] * b.m[2] + a.m[5] * b.m[6] + a.m[6] * b.m[10] + a.m[7] * b.m[14];
    o.m[7] = a.m[4] * b.m[3] + a.m[5] * b.m[7] + a.m[6] * b.m[11] + a.m[7] * b.m[15];

    o.m[8] = a.m[8] * b.m[0] + a.m[9] * b.m[4] + a.m[10] * b.m[8] + a.m[11] * b.m[12];
    o.m[9] = a.m[8] * b.m[1] + a.m[9] * b.m[5] + a.m[10] * b.m[9] + a.m[11] * b.m[13];
    o.m[10] = a.m[8] * b.m[2] + a.m[9] * b.m[6] + a.m[10] * b.m[10] + a.m[11] * b.m[14];
    o.m[11] = a.m[8] * b.m[3] + a.m[9] * b.m[7] + a.m[10] * b.m[11] + a.m[11] * b.m[15];

    o.m[12] = a.m[12] * b.m[0] + a.m[13] * b.m[4] + a.m[14] * b.m[8] + a.m[15] * b.m[12];
    o.m[13] = a.m[12] * b.m[1] + a.m[13] * b.m[5] + a.m[14] * b.m[9] + a.m[15] * b.m[13];
    o.m[14] = a.m[12] * b.m[2] + a.m[13] * b.m[6] + a.m[14] * b.m[10] + a.m[15] * b.m[14];
    o.m[15] = a.m[12] * b.m[3] + a.m[13] * b.m[7] + a.m[14] * b.m[11] + a.m[15] * b.m[15];
    
    return o;
}


Vector4 Matrix44::Multiply(const Vector4 &v)
{
    return multiply(*this, v);
}


static bool InvertMatrix(const float m[16], float invOut[16])
{
    float inv[16], det;
    int i;

    inv[0] = m[5]  * m[10] * m[15] -
             m[5]  * m[11] * m[14] -
             m[9]  * m[6]  * m[15] +
             m[9]  * m[7]  * m[14] +
             m[13] * m[6]  * m[11] -
             m[13] * m[7]  * m[10];

    inv[4] = -m[4]  * m[10] * m[15] +
              m[4]  * m[11] * m[14] +
              m[8]  * m[6]  * m[15] -
              m[8]  * m[7]  * m[14] -
              m[12] * m[6]  * m[11] +
              m[12] * m[7]  * m[10];

    inv[8] = m[4]  * m[9] * m[15] -
             m[4]  * m[11] * m[13] -
             m[8]  * m[5] * m[15] +
             m[8]  * m[7] * m[13] +
             m[12] * m[5] * m[11] -
             m[12] * m[7] * m[9];

    inv[12] = -m[4]  * m[9] * m[14] +
               m[4]  * m[10] * m[13] +
               m[8]  * m[5] * m[14] -
               m[8]  * m[6] * m[13] -
               m[12] * m[5] * m[10] +
               m[12] * m[6] * m[9];

    inv[1] = -m[1]  * m[10] * m[15] +
              m[1]  * m[11] * m[14] +
              m[9]  * m[2] * m[15] -
              m[9]  * m[3] * m[14] -
              m[13] * m[2] * m[11] +
              m[13] * m[3] * m[10];

    inv[5] = m[0]  * m[10] * m[15] -
             m[0]  * m[11] * m[14] -
             m[8]  * m[2] * m[15] +
             m[8]  * m[3] * m[14] +
             m[12] * m[2] * m[11] -
             m[12] * m[3] * m[10];

    inv[9] = -m[0]  * m[9] * m[15] +
              m[0]  * m[11] * m[13] +
              m[8]  * m[1] * m[15] -
              m[8]  * m[3] * m[13] -
              m[12] * m[1] * m[11] +
              m[12] * m[3] * m[9];

    inv[13] = m[0]  * m[9] * m[14] -
              m[0]  * m[10] * m[13] -
              m[8]  * m[1] * m[14] +
              m[8]  * m[2] * m[13] +
              m[12] * m[1] * m[10] -
              m[12] * m[2] * m[9];

    inv[2] = m[1]  * m[6] * m[15] -
             m[1]  * m[7] * m[14] -
             m[5]  * m[2] * m[15] +
             m[5]  * m[3] * m[14] +
             m[13] * m[2] * m[7] -
             m[13] * m[3] * m[6];

    inv[6] = -m[0]  * m[6] * m[15] +
              m[0]  * m[7] * m[14] +
              m[4]  * m[2] * m[15] -
              m[4]  * m[3] * m[14] -
              m[12] * m[2] * m[7] +
              m[12] * m[3] * m[6];

    inv[10] = m[0]  * m[5] * m[15] -
              m[0]  * m[7] * m[13] -
              m[4]  * m[1] * m[15] +
              m[4]  * m[3] * m[13] +
              m[12] * m[1] * m[7] -
              m[12] * m[3] * m[5];

    inv[14] = -m[0]  * m[5] * m[14] +
               m[0]  * m[6] * m[13] +
               m[4]  * m[1] * m[14] -
               m[4]  * m[2] * m[13] -
               m[12] * m[1] * m[6] +
               m[12] * m[2] * m[5];

    inv[3] = -m[1] * m[6] * m[11] +
              m[1] * m[7] * m[10] +
              m[5] * m[2] * m[11] -
              m[5] * m[3] * m[10] -
              m[9] * m[2] * m[7] +
              m[9] * m[3] * m[6];

    inv[7] = m[0] * m[6] * m[11] -
             m[0] * m[7] * m[10] -
             m[4] * m[2] * m[11] +
             m[4] * m[3] * m[10] +
             m[8] * m[2] * m[7] -
             m[8] * m[3] * m[6];

    inv[11] = -m[0] * m[5] * m[11] +
               m[0] * m[7] * m[9] +
               m[4] * m[1] * m[11] -
               m[4] * m[3] * m[9] -
               m[8] * m[1] * m[7] +
               m[8] * m[3] * m[5];

    inv[15] = m[0] * m[5] * m[10] -
              m[0] * m[6] * m[9] -
              m[4] * m[1] * m[10] +
              m[4] * m[2] * m[9] +
              m[8] * m[1] * m[6] -
              m[8] * m[2] * m[5];

    det = m[0] * inv[0] + m[1] * inv[4] + m[2] * inv[8] + m[3] * inv[12];

    if (det == 0)
        return false;

    det = 1.0 / det;

    for (i = 0; i < 16; i++)
        invOut[i] = inv[i] * det;

    return true;
}


Matrix44 Matrix44::Invert()
{
    Matrix44 result;
    InvertMatrix(this->m, result.m);
    return result;
}



Matrix44 Matrix44::Ortho(float left, float right, float bottom, float top, float nearZ, float farZ)
{
    float       deltaX = right - left;
    float       deltaY = top - bottom;
    float       deltaZ = farZ - nearZ;
    
    Matrix44 ortho =
    {
        2.0f / deltaX,0,0,0,
        0,2.0f / deltaY,0,0,
        0,0,-2.0f / deltaZ,0,
        -(right + left) / deltaX,-(top + bottom) / deltaY,-(nearZ + farZ) / deltaZ,1
    };
    return ortho;
}

Matrix44 Matrix44::OrthoLH(float l, float r, float b, float t, float zn, float zf)
{
    return Matrix44 {
        2.0f / (r - l),
        0.0f,
        0.0f,
        0.0f,
        
        0.0f,
        2.0f / (t - b),
        0.0f,
        0.0f,
        
        0.0f,
        0.0f,
//        2.0f / (zf - zn),  // -1,1 depth range
        1.0f / (zf - zn),  // 0,1 depth range
        0.0f,
        
        (l+r)/(l-r),
        (t+b)/(b-t) ,
//        (zn + zf) / (zn - zf) ,  // -1,1 depth range
        (zn) / (zn - zf) ,  // 0,1 depth range
        1.0f
    };
}



Matrix44 Matrix44::PerspectiveFovAspectLH(float fovY, float aspect, float nearZ, float farZ)
{
    float yscale = 1.0f / tanf(fovY * 0.5f); // 1 / tan == cot
    float xscale = yscale / aspect;
    float q = farZ / (farZ - nearZ);
    
    Matrix44 m = {
        xscale, 0.0f, 0.0f, 0.0f ,
        0.0f, yscale, 0.0f, 0.0f ,
        0.0f, 0.0f, q, 1.0f ,
        0.0f, 0.0f, q * -nearZ, 0.0f
    };
    return m;
}

Matrix44 Matrix44::PerspectiveOffCenterRH(float l, float r, float b, float t, float zn, float zf)
{
#if 0
    Matrix44 m = {
        2*zn/(r-l),  0,            0,                0,
        0,           2*zn*(t-b),   0,                0,
        (l+r)/(r-l), (t+b)/(t-b),  zf/(zn-zf),      -1,
        0,           0,            zn*zf/(zn-zf),    0
    };
#else
    Matrix44 m = {
        2*zn/(r-l),  0,            0,                0,
        0,           2*zn*(t-b),   0,                0,
        (l+r)/(r-l), (t+b)/(t-b),  1.0f/(zn-zf),      -1,
        0,           0,            zn/(zn-zf),    0
    };

#endif
    return m;
}






Matrix44 Matrix44::PerspectiveOffCenterLH(float l, float r, float b, float t, float zn, float zf)
{
#if 0
    Matrix44 m = {
        2*zn/(r-l),   0         ,   0          ,    0,
        0         ,   2*zn/(t-b),   0          ,    0,
        (l+r)/(l-r),  (t+b)/(b-t),  zf/(zf-zn) ,    1,
        0          ,  0          ,  zn*zf/(zn-zf),  0
    };
#else
    Matrix44 m = {
        2*zn/(r-l),   0         ,   0          ,    0,
        0         ,   2*zn/(t-b),   0          ,    0,
        (l+r)/(l-r),  (t+b)/(b-t),  1.0f/(zf-zn) ,    1,
        0          ,  0          ,  zn/(zn-zf),  0
    };
#endif
    return m;
}


