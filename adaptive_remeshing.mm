#import "adaptive_remeshing.h"
#import "pmp/algorithms/remeshing.h"

#import "TypeCheck.h"

void adaptive_remeshing(std::vector<simd::float3> &v, std::vector<simd::uint3> &f, NSString *params) {
        
    unsigned int iterations = 1;
    
    float min_length = 0.001;
    float max_length = 0.05;
    float max_error = 0.0005;
    
    if(params) {
        
        NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
        settings = [NSJSONSerialization JSONObjectWithData:[[[NSRegularExpression regularExpressionWithPattern:@"(/\\*[\\s\\S]*?\\*/|//.*)" options:1 error:nil] stringByReplacingMatchesInString:params options:0 range:NSMakeRange(0,params.length) withTemplate:@""] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        
        if(TypeCheck::isNumber(settings[@"iterations"])) iterations = [settings[@"iterations"] intValue];
        
        if(iterations<=0) iterations = 1;
        else if(iterations>=20) iterations = 20;
    }
    
    simd::float3 min = v[0];
    simd::float3 max = v[0];
    
    for(int n=0; n<v.size(); n++) {
        
        simd::float3 tmp = v[n];
        if(tmp.x<min.x) min.x = tmp.x;
        if(tmp.y<min.y) min.y = tmp.y;
        if(tmp.z<min.z) min.z = tmp.z;
        
        if(max.x<tmp.x) max.x = tmp.x;
        if(max.y<tmp.y) max.y = tmp.y;
        if(max.z<tmp.z) max.z = tmp.z;
    }
    
    float scaling = simd::distance(max,min);
    
    pmp::SurfaceMesh mesh;

    for(int n=0; n<v.size(); n++) {
        mesh.add_vertex(pmp::Point(
            v[n].x,
            v[n].y,
            v[n].z
        ));
    }

    for(int n=0; n<f.size(); n++) {
        
        std::vector<pmp::Vertex> vertices;
        
        unsigned int a = f[n].x;
        unsigned int b = f[n].y;
        unsigned int c = f[n].z;
        
        vertices.emplace_back(a);
        vertices.emplace_back(b);
        vertices.emplace_back(c);
        
        mesh.add_face(vertices);
    }

    pmp::adaptive_remeshing(
        mesh,
        min_length*scaling,
        max_length*scaling, 
        max_error*scaling,
        iterations, 
        false
    );
    
    v.clear();
    f.clear();
    
    auto points = mesh.get_vertex_property<pmp::Point>("v:point");
    for(auto vertex : mesh.vertices()) {
        const pmp::Point &p = points[vertex];
        v.push_back(simd::float3{p[0],p[1],p[2]});
    }
    
    for(auto face : mesh.faces()) {
        
        int cnt = 0;
        simd::uint3 indices;
        
        for(auto vertices : mesh.vertices(face)) {
            indices[cnt++] = (unsigned int)(vertices.idx());
            if(cnt==3) {
                f.push_back(indices);
                break;
            }
        }
    }
}