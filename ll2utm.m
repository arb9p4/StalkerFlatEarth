function [fullzonestr, east, north] = ll2utm(latdeg, lathemi, longdeg, longhemi)

% function [ZONEStr, east, north] = LL2Utm(latdeg, lathemi, longdeg, longhemi);
%
% Converts Latitude & Longitude into UTM using WGS-84 Datum
%
% Inputs:
%   latdeg - Latitude in decimal degrees (dd.dddd) (positive #) [NOTE: Not ddmmss.sss]
%   lathemi - Hemishpere for latitude (N or S)
%   longdeg - Longitude in decimal degrees (dd.dddd) (positive #)
%   longhemi - Hemishphere for longitude (E or W)
%
% Outputs:
%   ZONEStr - String representing the zone number & letter (i.e., 18S)
%   east - Easting number in meters
%   north - Northing number in meters
%
% Display ouput:
%   Latitude decimal degrees with hemisphere indicator
%   Longitude decimal degrees with hemisphere indicator
%   UTM Zone number & letter
%   Easting in meters
%   Northing in meters
%   MGRS (Military Grid Reference System) nomenclature to 1 meter res
%
% B. Barbour
%
%   V 1.00.01   12/02/02    Initial Release



% WGS84 constants
SMA = 6378137;
ESQR = .00669437999013;
X = 1;
SCALFAC = .9996;
EASTF = 500000;   % False easting #
SPHEROIDStr = 'WGS-84';
% Zone "row" indicators
GStr = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
G1Str = GStr(1:20);
NStr = 'NPQRSTUVWXY';       % Northern hemisphere row letters
SStr = 'MLKJHGFEDC';        % Southern hemisphere row letters
ZPI = 3.141592653589887;

lathemi = upper(lathemi);     % Make sure hemisphere indicators are cap letters
longhemi = upper(longhemi);

if lathemi == 'S'       % Southern hemisphere should have negative latitued
    latdeg = -abs(latdeg);
    NORTHF = 10000000;  % False northing for southern hemisphere
else
    NORTHF = 0;
end
if longhemi == 'W'      % Western hemisphere should have negative longitude
    longdeg = -abs(longdeg);
end

% Convert degrees to radians for trig functions
latrad = latdeg * ZPI / 180;
longrad = longdeg * ZPI / 180;

W = fix(abs(latdeg / 8)) + 1;  % Row number
if latdeg > 0           % Get letter for row number
    WStr = NStr(W);     % Northern hemisphere
else
    WStr = SStr(W);     % Southern Hemisphere
end

zone = fix(longdeg / 6 + 31);   % Zone number

% **************** Meridian Arc Routine ********************
% Calculations based on WGS-84 ellipse constants
A5 = 1 - 2 * ESQR / 8 - 12 * ESQR ^ 2 / 256 - 60 * ESQR ^ 3 / 3072 - 75 * ESQR ^ 4 / 16384 ...
    - 441 * ESQR ^ 5 / 65536;
B5 = 3 * ESQR / 8 + 24 * ESQR ^ 2 / 256 + 135 * ESQR ^ 3 / 3072 + 105 * ESQR ^ 4 / 2048 ...
    + 2205 * ESQR ^ 5 / 65536;
C5 = 15 * ESQR ^ 2 / 256 + 135 * ESQR ^ 3 / 3072 + 525 * ESQR ^ 4 / 4096 + 1575 * ESQR ^ 5 / 16384;
D5 = 35 * ESQR ^ 3 / 3072 + 175 * ESQR ^ 4 / 2048 + 11025 * ESQR ^ 5 / 131072;
E5 = 315 * ESQR ^ 4 / 16384 + 2205 * ESQR ^ 5 / 65536;
F5 = 693 * ESQR ^ 5 / 131072;
M1 = SCALFAC * SMA * (A5 * latrad - B5 * sin(2 * latrad) + C5 * sin(4 * latrad) - D5 * sin(6 * latrad) ...
    + E5 * sin(8 * latrad) - F5 * sin(10 * latrad));

%        ' ********************************************
%        ' *    MGRS NONSTANDARD ZONES                *
%        ' ********************************************
%        ' NORTHERN NONSTANDARD ZONES
if (latdeg > 56 & latdeg < 64 & longdeg > 3 & longdeg < 12)
    zone = 32;
end
if (latdeg > 72 & longdeg > 0 & longdeg < 9)
    zone = 31;
end
if (latdeg > 72 & longdeg > 9 & longdeg < 21)
    zone = 33;
end
if (latdeg > 72 & longdeg > 21 & longdeg < 33)
    zone = 35;
end
if (latdeg > 72 & longdeg > 33 & longdeg < 42)
    zone = 37;
end

% More ellipse calculations
LAMBDA0 = zone * 6 - 183;
Z7 = ((longdeg - LAMBDA0) ./ (180 / ZPI)) .* cos(latrad);
V0 = SCALFAC * SMA ./ sqrt(1 - ESQR * sin(latrad) .^ 2);
N0 = ESQR * cos(latrad) .^ 2 / (1 - ESQR);
T0 = tan(latrad) .^ 2;
EAST = ((((2 * T0 - 58) .* T0 + 14) .* N0 + (T0 - 18) .* T0 + 5) .* (Z7 .^ 2 / 20) + N0 - T0 + 1);
EAST = (EAST .* (Z7 .^ 2 / 6) + 1) .* V0 .* Z7 + EASTF;
NORTH = ((T0 - 58) .* T0 + 61) .* (Z7 .^ 2 / 30) + (9 + 4 .* N0) .* N0 - T0 + 5;
NORTH = (NORTH .* (Z7 .^ 2 / 12) + 1) .* V0 .* (Z7 .^ 2 / 2) .* tan(latrad) + M1 + NORTHF;

X = hemitest(X, latdeg, longdeg, zone, EAST, NORTH);    % Correct something????

if fix(EAST + .01) == fix(EAST) + 1
    EAST = EAST + .01;
end
if fix(NORTH + .01) == fix(NORTH) + 1
    NORTH = NORTH + .01;
end
EAST = EAST * .00001;
NORTH = NORTH * .00001;
if NORTH < 0
    NORTH = NORTH + 100;
end

%            2660   'label
%            ' ***************************************
%            ' *       UTM TO MGRS CONVERSION        *
%            ' ***************************************
%            GOTO 2730
%            2700   'label
%            EAST = EAST * .00001
%            IF D1 < 0 THEN NORTH = 10000000# - ABS(NORTH)
%            NORTH = NORTH * .00001
%            2730   'label
ROW = fix(abs(latdeg / 8)) + 1;
if latdeg > 0
    ROWStr = NStr(ROW(1));
else
    ROWStr = SStr(ROW(1));
end
if zone == 61
    zone = 1;
end
ZONEStr = num2str(zone);
if length(ZONEStr) < 2
    MGRSStr(1:2) = ['0' ZONEStr];
else
    MGRSStr(1:2) = ZONEStr(1:2);
end
if (latdeg >= 80 & latdeg < 84)
    ROWStr = 'X';
end
MGRSStr(3) = ROWStr;
fullzonestr = MGRSStr;
EASTINGStr = num2str(EAST, 10);
EASTINGStr = EASTINGStr(1,:);
EASTINGStr = [EASTINGStr '00000'];
pdpos = findstr(EASTINGStr, '.');
EASTINGStr = EASTINGStr(pdpos + 1:pdpos + 5);
MGRSStr(6:10) = EASTINGStr;
NORTHINGStr = num2str(NORTH, 10);
NORTHINGStr = NORTHINGStr(1,:);
NORTHINGStr = [NORTHINGStr '00000'];
pdpos = findstr(NORTHINGStr, '.');
NORTHINGStr = NORTHINGStr(pdpos + 1:pdpos + 5);
MGRSStr(11:15) = NORTHINGStr;
E1 = ((zone * 8) - 7) / 24;
if E1 == fix(E1)
    E1 = E1 + .04176;
end
%            ' THIS RETURNS AN IDENTITY INSTEAD OF ZERO TO PREVENT ERRORS
%E1 = CINT(((E1 - INT(E1)) * 24))
E1 = fix(double(single((E1 - fix(E1)) * 24))); %Need single to limit accuracy & double to use fix
%            ' E1 IS THE NUMBER OF REPEATS

M1Str = GStr(E1:E1 + 7);
MGRSStr(4) = M1Str(fix(EAST(1)));
if fix(zone / 2) == zone / 2
    X = X + 5;
end
M2Str(1:21 - X) = G1Str(X:(X-1)+21 - X);
if X > 1
    M2Str(22 - X:22 - X + X - 2) = G1Str(1:X - 1);
end
%            '  M2$ IS WORKING VARIABLE FOR NORTHING ALPHAS
N1 = NORTH / 20;
N1 = fix(((N1 - fix(N1)) * 20) + 1);
MGRSStr(5) = M2Str(N1(1));
if latdeg < 0
    NORTH = -NORTH;
end
%            RETURN

EAST = fix(EAST * 1000000000) / 1000000000;
NORTH = fix(NORTH * 1000000000) / 1000000000;
%            CLS
%            LOCATE 6, 25
if(0)
disp(['LATITUDE  =  ' num2str(latdeg) lathemi]);
disp(['LONGITUDE = ' num2str(longdeg) longhemi]);
%            PRINT TAB(25); "SPHEROID  = "; SPHEROID$
disp(['ZONE      = ' fullzonestr]);
disp(['EASTING   = ' num2str(EAST * 100000) ' meters']);
disp(['NORTHING  = ' num2str(NORTH * 100000) ' meters']);
disp(['MGRS      = ' MGRSStr]);
end

east = EAST * 100000;
north = NORTH * 100000;


%        ' *************************************
%        ' *         HEMISPHERE TEST           *
%        ' *************************************
function Xout = hemitest(Xin, latdeg, longdeg, zone, EAST, NORTH);

Xout = Xin;

%        5710   'label
if longdeg < 60
    return
end
%        ' *************************************
%        ' *       PLATE 9,10,15,16  WGS       *
%        ' *************************************
if (longdeg < 96 & longdeg >= 126 & latdeg >= 56 & latdeg < .4167)
    return
end
%        IF WS = 7 GOTO 5920
%        IF WS = 3 GOTO 5970
%        IF WS = 1 GOTO 6020
if ((zone == 47 & latdeg < 44.2532493156 & latdeg > 16) | ...
        (zone == 48 & latdeg < 45.15348924575 & latdeg > 16) | ...
        (zone == 49 & latdeg < 49.65255633089 & latdeg >= 7.5) | ...
        (zone == 50 & latdeg < 40 & latdeg > 8) | ...
        (latdeg >= 21 & longdeg >= 120 & latdeg < 31.63083999912 & longdeg < 126) | ...
        (EAST < 600000 & longdeg >= 120 & latdeg < 337.94209528695 & latdeg >= 31.63083999912) | ...
        (zone == 52 & NORTH < 6000000 & latdeg > 40) | ...
        (zone == 53 & NORTH < 6200000 & latdeg > 40) | ...
        (zone == 54 & NORTH < 6100000 & latdeg > 40) | ...
        (zone == 55 & NORTH < 6000000 & latdeg > 40))
    %GOTO 5900
    Xout = 11;
end
%        GOTO 5910
%        5900   'label
%        X = 11
%        5910   'label
%        RETURN
