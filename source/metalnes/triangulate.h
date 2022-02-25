

#pragma once

#include <vector>
#include <stdint.h>
#include "wire_defs.h"

namespace metalnes {

void BuildTriangleList(const std::vector<point> &points, std::vector<int> &triangle_list);

}


