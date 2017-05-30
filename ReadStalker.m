function [data, h] = ReadStalker(fileName)

%    dynrange = 45; % dynamic range (dB) used for image display

    % read the data header (first 512 bytes) into a structure h
    h = read_ahis_headerBob(fileName);
    num_pts  = h.num_pts;
    nx = h.num_x_pts;
    ny = h.num_y_pts;
    nz = h.num_t_pts;
    dx = h.x_inc; % note this is negative
    dy = h.y_inc;
    dz = h.t_inc*1e-12*h.mat_velocity/2;
    x1 = h.x_offset;
    x2 = x1 - dx*nx; % NOTE: dx is negative (due to right to left x def)
    y1 = h.y_offset;
    y2 = y1 + dy*ny;
    vel = h.mat_velocity;
    z1 = h.t_delay*1e-9*h.mat_velocity/2;
    z2 = z1 + dz*nz;
    data_scale_factor = h.data_scale_factor;

%    fprintf('num_pts: %d\n',num_pts)
%    fprintf('x1 x2 nx = %f %f %d\n',x1,x2,nx)
%    fprintf('y1 y2 ny = %f %f %d\n',y1,y2,ny)
%    fprintf('z1 z2 nz = %f %f %d\n',z1,z2,nz)
%    fprintf('velocity: %f m/s\n',vel)
%    fprintf('Data storage order: %d\n',h.data_storage_order)
%    fprintf('Word type: (code %d)\n',h.word_type)

    xvals = linspace(x1,x2,nx);
    yvals = linspace(y1,y2,ny);
    zvals = linspace(z1,z2,nz);
    Lx = max(xvals)-min(xvals);
    Ly = max(yvals)-min(yvals);
    Lz = max(zvals)-min(zvals);

    % read *.a3d data : real float XYZ order - fastest to slowest index
    if (num_pts==1 && h.data_storage_order==9 && h.word_type==4)
        fid = fopen(fileName);
        fseek(fid,512,'bof');
        % read data and convert to complex double of size (nf,nwaveforms)
        data = fread(fid,nx*ny*nz,'uint16');
        data = data*data_scale_factor; % scale data back to original float scale
        data = reshape(data,nx,ny,nz); % make into a 3D array
        data = flipdim(data,1); % mirrors the data on the x axis
        fclose(fid);
    else
        fprintf('Error - only real (16 bit unsigned integer data with TYX data order is supported\n')
        return
    end