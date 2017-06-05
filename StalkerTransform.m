inputDir = 'J:\Data\EFP\Stalker\1611YPG\YPGBT2_ImageRepository_3D\';

d = dir(inputDir);
d = d(3:end);

for i=length(d):-1:1
    if(~d(i).isdir)
        d(i) = [];
    end;
end;

for curRun = 1:length(d)
    a3d = dir([inputDir d(curRun).name '\*_0.a3d']);
    csv = dir([inputDir d(curRun).name '\*_0.csv']);
    
    for curFrame = 1:length(a3d)
        tic;
        [data, h] = ReadStalker([inputDir d(curRun).name '\' a3d(curFrame).name]);
        
        s = size(data);
        
        
        dx = h.t_inc*1e-12*h.mat_velocity/2;
        dy = -h.x_inc;
        dz = h.y_inc;

        s = size(data);
        s2 = floor([s(1), s(2)*dz/.01, (s(3)*dx/.01)]);

        s2 = floor(s2/5);

        data2 = zeros(s2);
        
        for i=1:s2(1)
           data2(i,:,:) = permute(imresize(squeeze(data(i*5,:,:)),  [s2(2) s2(3)]), [3 1 2]);
        end
        

        sumIm = squeeze(sum(data2,1));
        [R, xp] = radon(sumIm, 60.1:.1:120);
        ma = max(R,[],1);
        [ma, ind] = max(ma);
        ang = 30 - ind/10;

        [easting, northing] = LoadStalkerUTM([inputDir d(curRun).name '\'  csv(curFrame).name]);
        
        if(easting(1) == 0 && northing(1) == 0)
            break;
        end

        vec1 = [northing(2)-northing(1), easting(1) - easting(2), 0, 1];
        vec1(1:3) = vec1(1:3)/norm(vec1(1:3));
        vec2 = [easting(2) - easting(1), northing(2)-northing(1), 0,1];
        vec2(1:3) = vec2(1:3)/norm(vec2(1:3));
        vec3 = [0, 0, 1, 1];


        A = [1 0 0 1; 0 1 0 1; 0 0 1 1; 0 0 0 1];
        b = [vec1; vec2; vec3; 0 0 0 1];
        T2 = A\b;

        vec1_2 = vec1/T2;
        vec2_2 = vec2/T2;
        vec3_2 = vec3/T2;

        T = CreateTransfMatrix(0, 0, 0, pi*ang/180, 0, 0);

        vec1_3 = vec1_2*T;
        vec2_3 = vec2_2*T;
        vec3_3 = vec3_2*T;

        vec1_4 = vec1_3*T2;
        vec2_4 = vec2_3*T2;
        vec3_4 = vec3_3*T2;


        A = [1 0 0 1; 0 1 0 1; 0 0 1 1; 0 0 0 1];
        b = [vec1_4; vec2_4; vec3_4; 0 0 0 1];
        T3 = A\b;

        s = size(data);
        if(s(2) > 186)
            slantedOrigin = [easting(1), northing(1), 0, 1]+vec1_4-2.825*vec3_4;
        else
            slantedOrigin = [easting(1), northing(1), 0, 1]+vec1_4-2.325*vec3_4;
        end
        slantedOrigin(4) = 1;

        T = CreateTransfMatrix(slantedOrigin(1), slantedOrigin(2), slantedOrigin(3), 0, 0, 0);

        vec1_5 = vec1_4*T;
        vec2_5 = vec2_4*T;
        vec3_5 = vec3_4*T;
        vec4_5 = [0 0 0 1]*T;

        TSlanted = [1 0 0 1; 0 1 0 1; 0 0 1 1; 0 0 0 1]\[vec1_5; vec2_5; vec3_5; vec4_5];

        dx = h.t_inc*1e-12*h.mat_velocity/2;
        dy = -h.x_inc;
        dz = h.y_inc;

        vec1Vox = [1/dx+1, 1, 1, 1];
        vec2Vox = [1, 1/dy+1, 1, 1];
        vec3Vox = [1, 1, 1/dz+1, 1];

        A = [vec1Vox; vec2Vox; vec3Vox; 1 1 1 1];
        b = [vec1_5; vec2_5; vec3_5; slantedOrigin];
        TVox2World = A\b;

        if(s(2) > 186)%This is for old data was not zero padded
            flatOrigin = slantedOrigin+.5*vec3_4-[0 0 1 0];
        else
            flatOrigin = slantedOrigin-[0 0 1 0];
        end
        flatOrigin(4) = 1;

        T = CreateTransfMatrix(flatOrigin(1), flatOrigin(2), flatOrigin(3), 0, 0, 0);

        vec1_6 = cross(vec2_4(1:3), [0 0 1]);
        vec1_6 = vec1_6/norm(vec1_6);
        vec1_6(4) = 1;
        vec2_6 = vec2_4;
        vec3_6 = [0 0 1 1];

        vec1_7 = vec1_6*T;
        vec2_7 = vec2_6*T;
        vec3_7 = vec3_6*T;


        dx2 = .01;
        dy2 = .01;
        dz2 = .01;

        vec1VoxFlat = [1/dx2+1, 1, 1, 1];
        vec2VoxFlat = [1, 1/dy2+1, 1, 1];
        vec3VoxFlat = [1, 1, 1/dz2+1, 1];

        A = [vec1VoxFlat; vec2VoxFlat; vec3VoxFlat; 1 1 1 1];
        b = [vec1_7; vec2_7; vec3_7; flatOrigin];
        TVoxFlat2World = A\b;


        figure(2);
        clf;
        curVec0 = [1 1 1 1]*TVox2World;
        curVec1 = [1/dx 0 0 1]*TVox2World;
        curVec2 = [0 1/dy 0 1]*TVox2World;
        curVec3 = [0 0 1/dz 1]*TVox2World;
        plot3(curVec0(1), curVec0(2), curVec0(3), '.k', curVec1(1), curVec1(2), curVec1(3), '.b', curVec2(1), curVec2(2), curVec2(3), '.g', curVec3(1), curVec3(2), curVec3(3), '.r'); axis equal;

        curVec20 = [1 1 1 1]*TVoxFlat2World;
        curVec21 = [1/dx2 0 0 1]*TVoxFlat2World;
        curVec22 = [0 1/dy2 0 1]*TVoxFlat2World;
        curVec23 = [0 0 1/dz2 1]*TVoxFlat2World;
        plot3(curVec20(1), curVec20(2), curVec20(3), '*k', curVec21(1), curVec21(2), curVec21(3), '*b', curVec22(1), curVec22(2), curVec22(3), '*g', curVec23(1), curVec23(2), curVec23(3), '*r'); axis equal;

        plot3(curVec0(1), curVec0(2), curVec0(3), '.k', curVec1(1), curVec1(2), curVec1(3), '.b', curVec2(1), curVec2(2), curVec2(3), '.g', curVec3(1), curVec3(2), curVec3(3), '.r', curVec20(1), curVec20(2), curVec20(3), '*k', curVec21(1), curVec21(2), curVec21(3), '*b', curVec22(1), curVec22(2), curVec22(3), '*g', curVec23(1), curVec23(2), curVec23(3), '*r'); axis equal;

        StalkerRotateData;
        
        save([inputDir d(curRun).name '\' a3d(curFrame).name(1:end-3) 'mat'], 'data', 'eastingGrid', 'northingGrid', '-v7.3');
        toc;
    end
end