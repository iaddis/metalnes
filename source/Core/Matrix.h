
#pragma once

#include <stdint.h>
#include "Math.h"

struct Matrix44
{
	float   m[16];
    
    float get(int x, int y) {return m[y*4+x];}
    void  set(int x, int y, float v) {m[y*4+x] = v;}
	
    static Matrix44 Identity();

    static Matrix44 Scale(float x, float y, float z, float w = 1.0f);
    static Matrix44 Translate(float x, float y, float z);

    Matrix44 Transpose();
    Matrix44 Invert();
    Vector4  Multiply(const Vector4 &v);

    static Vector4 multiply(const Matrix44 &m, const Vector4 &v);

    static Matrix44 multiply(const Matrix44 &a, const Matrix44 &b);

    
    static Matrix44 Ortho(float left, float right, float bottom, float top, float nearZ, float farZ);
    static Matrix44 OrthoLH(float left, float right, float bottom, float top, float near, float far);

    static Matrix44 PerspectiveFovAspectLH(float fov, float aspect, float nearZ, float farZ);
    static Matrix44 PerspectiveOffCenterLH(float l, float r, float b, float t, float zn, float zf);
    static Matrix44 PerspectiveOffCenterRH(float l, float r, float b, float t, float zn, float zf);
};



