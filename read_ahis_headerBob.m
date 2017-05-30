function h_out = read_ahis_headerBob(fileName)
%read ahis binary header files
%JFernandes 03/25/2011 mod DMSheen 3/25/2011

fid = fopen(fileName);

h_out.filename            =   char(fread(fid,20,'char').');%char20
h_out.parent_filename     =   char(fread(fid,20,'char').');%char20
h_out.comments            =   char(fread(fid,160,'char').');%char160
h_out.energy_type         =   fread(fid,1,'short');%2, microwave
h_out.config_type         =   fread(fid,1,'short');%1, holographic
h_out.file_type           =   fread(fid,1,'short');%2, RAW data
h_out.trans_type          =   fread(fid,1,'short');%7, sweep freq waveform
h_out.scan_type           =   fread(fid,1,'short');%2, simultaneous source and receiver
h_out.data_type           =   fread(fid,1,'short');%5, amplitude data
h_out.date_modified       =   char(fread(fid,16,'char').');%char 16
h_out.frequency           =   fread(fid,1,'float');%MHz
h_out.mat_velocity        =   fread(fid,1,'float');%
h_out.num_pts             =   fread(fid,1,'long');%1, real data
h_out.num_polarization_channels   =   fread(fid,1,'short');%1
h_out.spare00              =   fread(fid,1,'short');%184
h_out.adc_min_voltage     =   fread(fid,1,'float');%-1
h_out.adc_max_voltage     =   fread(fid,1,'float');%1
h_out.band_width           =   fread(fid,1,'float');%MHz
h_out.spare01             =   fread(fid,5,'short');%short[10/2] 0;0;0;0;0
h_out.polarization_type   =   fread(fid,4,'short');%
h_out.record_header_size  =   fread(fid,1,'short');%0 in holographic mode
h_out.word_type           =   fread(fid,1,'short');%3 signed short
h_out.word_precision      =   fread(fid,1,'short');%12 bits
h_out.min_data_value      =   fread(fid,1,'float');%float
h_out.max_data_value      =   fread(fid,1,'float');%float
h_out.avg_data_value      =   fread(fid,1,'float');%float
h_out.data_scale_factor   =   fread(fid,1,'float');%units of data values
h_out.data_units          =   fread(fid,1,'short');%1 volts
h_out.surf_removal        =   fread(fid,1,'ushort');%0
h_out.edge_weighting      =   fread(fid,1,'ushort');%0, no windowing
h_out.x_units             =   fread(fid,1,'ushort');%4, degrees
h_out.y_units             =   fread(fid,1,'ushort');%4
h_out.z_units             =   fread(fid,1,'ushort');%1,distance
h_out.t_units             =   fread(fid,1,'ushort');%3, frequency
h_out.spare02             =   fread(fid,1,'short');%short
h_out.x_return_speed      =   fread(fid,1,'float');%5, return speeds
h_out.y_return_speed      =   fread(fid,1,'float');%0.0360
h_out.z_return_speed      =   fread(fid,1,'float');%0
h_out.scan_orientation    =   fread(fid,1,'short');%0
h_out.scan_direction      =   fread(fid,1,'short');%1, X scan axis
h_out.data_storage_order  =   fread(fid,1,'short');%4, data order yxz
h_out.scanner_type        =   fread(fid,1,'short');%22
h_out.x_inc               =   fread(fid,1,'float');%0.002 -> 500 (number of records) = 1/0.002
h_out.y_inc               =   fread(fid,1,'float');%0.0222
h_out.z_inc               =   fread(fid,1,'float');%float
h_out.t_inc               =   fread(fid,1,'float');%float
h_out.num_x_pts           =   fread(fid,1,'long');%long
h_out.num_y_pts           =   fread(fid,1,'long');%long
h_out.num_z_pts           =   fread(fid,1,'long');%long
h_out.num_t_pts           =   fread(fid,1,'long');%long
h_out.x_speed             =   fread(fid,1,'float');%float
h_out.y_speed             =   fread(fid,1,'float');%float
h_out.z_speed             =   fread(fid,1,'float');%float
h_out.x_acc               =   fread(fid,1,'float');%float
h_out.y_acc               =   fread(fid,1,'float');%float
h_out.z_acc               =   fread(fid,1,'float');%float
h_out.x_motor_res         =   fread(fid,1,'float');%float
h_out.y_motor_res         =   fread(fid,1,'float');%float
h_out.z_motor_res         =   fread(fid,1,'float');%float
h_out.x_encoder_res       =   fread(fid,1,'float');%float
h_out.y_encoder_res       =   fread(fid,1,'float');%float
h_out.z_encoder_res       =   fread(fid,1,'float');%float
h_out.date_processed      =   char(fread(fid, 8,'char').');%char 8
h_out.time_processed      =   char(fread(fid, 8,'char').');%char 8
h_out.depth_recon         =   fread(fid,1,'float');%float
h_out.x_max_travel        =   fread(fid,1,'float');%float
h_out.y_max_travel        =   fread(fid,1,'float');%float
h_out.elevation_offset_angle =   fread(fid,1,'float');%float
h_out.roll_offset_angle   =   fread(fid,1,'float');%float
h_out.z_max_travel        =   fread(fid,1,'float');%float
h_out.azimuth_offset_angle=   fread(fid,1,'float');%float
h_out.adc_type            =   fread(fid,1,'short');%short
h_out.spare06             =   fread(fid,1,'short');%short
h_out.scanner_radius      =   fread(fid,1,'float');%float
h_out.x_offset            =   fread(fid,1,'float');%float
h_out.y_offset            =   fread(fid,1,'float');%float
h_out.z_offset            =   fread(fid,1,'float');%float
h_out.t_delay             =   fread(fid,1,'float');%float
h_out.range_gate_start    =   fread(fid,1,'float');%float
h_out.range_gate_end      =   fread(fid,1,'float');%float
h_out.ahis_software_version =   fread(fid,1,'float');%float
h_out.spare_end           =   fread(fid,10,'short');%short10

fclose(fid);

return;

