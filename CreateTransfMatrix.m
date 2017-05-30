function T = CreateTransfMatrix(x,y,z,roll, pitch, yaw)

    trans = [1 0 0 0;
             0 1 0 0;
             0 0 1 0;
             x y z 1];
    
    rot1 = [cos(roll) 0 -sin(roll) 0;
            0 1 0 0;
            sin(roll) 0 cos(roll) 0;
            0 0 0 1];
    rot2 = [1 0 0 0;
            0 cos(pitch) sin(pitch) 0;
            0 -sin(pitch) cos(pitch) 0;
            0 0 0 1];
    rot3 = [cos(yaw) sin(yaw) 0 0;
            -sin(yaw) cos(yaw) 0 0;
            0 0 1 0;
            0 0 0 1];
        
    T = rot3*rot2*rot1*trans;