
#include "triangulate.h"

extern "C" {
#include "../external/triangle/triangle.h"

void report(
struct triangulateio *io,
int markers,
int reporttriangles,
int reportneighbors,
int reportsegments,
int reportedges,
int reportnorms
            );

}
extern "C" int tricall_main();



namespace metalnes {



static void free_tridata(struct triangulateio &mid)
{
    delete[](mid.pointlist);
    delete[](mid.pointattributelist);
    delete[](mid.pointmarkerlist);
    delete[](mid.trianglelist);
    delete[](mid.triangleattributelist);
    delete[](mid.trianglearealist);
    delete[](mid.neighborlist);
    delete[](mid.segmentlist);
    delete[](mid.segmentmarkerlist);
    delete[](mid.edgelist);
    delete[](mid.edgemarkerlist);
}


struct segment
{
    int from;
    int to;
};

void BuildTriangleList(const std::vector<point> &points, std::vector<int> &triangle_list)
{
    std::vector<segment> segmentlist;
    segmentlist.reserve(points.size() + 1);
   
    int prev = (int)points.size()-1;
    for (int i=0; i < (int)points.size(); i++)
    {
        segment s {prev, i};
        if (points[s.from] == points[s.to])
            continue;
        
        segmentlist.push_back(s);
        prev = s.to;
    }
    
    
    struct triangulateio in = {0};
    in.numberofpoints = (int)points.size();
    in.pointlist = (float *)points.data();
    in.numberofsegments = (int)segmentlist.size();
    in.segmentlist =  (int *)segmentlist.data(); //new int[in.numberofsegments * 2];

    //            printf("Input point set:\n\n");
    //            report(&in, 1, 1,0,1,1,1);
    
    struct triangulateio mid = {0};
    triangulate("Qpzq0", &in, &mid, nullptr);
    
    triangle_list.assign(mid.trianglelist,  mid.trianglelist +  mid.numberoftriangles * 3 );
    
//    free_tridata(in);
    free_tridata(mid);
}



}
