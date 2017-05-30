function [easting, northing] = LoadStalkerUTM(fileName)

    [~, txt] = xlsread(fileName);
    str1 = txt{8,2};
    str2 = txt{9,2};
    lat = [str2num(str1(findstr(str1, '=')+1:findstr(str1, ',')-1)) str2num(str2(findstr(str2, '=')+1:findstr(str2, ',')-1))];
    lon = [str2num(str1(findstr(str1, ',')+1:end)) str2num(str2(findstr(str2, ',')+1:end))];
    if(lat(1) == 0)
        easting = 0;
        northing = 0;
        return;
    end
    [~, easting, northing] = ll2utm(lat, 'N', lon, 'W');