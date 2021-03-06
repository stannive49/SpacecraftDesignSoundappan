%% HW2 Problem 3
% Two-line element set
close all
clear all
clc

mu = 398600; %  Standard gravitational parameter for the earth

% TLE file name
fname = 'TLE.txt';

% Open the TLE file and read TLE elements
fid = fopen(fname, 'rb');
L1c = fscanf(fid,'%*1c %69c',1); % L1c contains the first line of the TLE as CHARACTERS
L2c = fscanf(fid,'%*2c %67c',1);  % L2c contains the second line of the TLE as Characters

% Close the TLE file
fclose(fid);

%Line 1
SatCatNum = str2num(L1c(1,1:5));
Classification = (L1c(6:6));
LaunchYear = str2num(L1c(1,7:9));
LaunchNumber = str2num(L1c(1,10:12));
PieceofLaunch = (L1c(13:13));
EpochYear = str2num(L1c(16:18));
Epoch = str2double(L1c(19:30));
n_dot = str2double(L1c(33:41));
n_dotdot = str2num(L1c(43:50))*10^(-str2num(L1c(59:59))-(50-42));%decimal point assumed
BSTAR = str2num(L1c(52:57))*10^(-str2num(L1c(59:59))-(57-52));%decimal point assumed
Ephemeris = str2num(L1c(61:61));
ESetNum = str2num(L1c(63:66));
Checksum1 = str2num(L1c(67:67));

%Line 2
catalog = str2num(L2c(1,1:5));
inc = str2num(L2c(1,7:15));
RAAN = str2num(L2c(1,16:23));
ecc = str2num(L2c(1,24:31))*10^(-(31-24));%decimal point assumed
om = str2num(L2c(1,32:40));
M = str2num(L2c(1,42:48)); %mean anomaly
n = str2double(L2c(1,50:60));
revolution_epoch = str2num(L2c(1,61:65));
Checksum2 = str2num(L2c(1,66:66));

%Find Semi-Major Axis (a)
%Source: https://space.stackexchange.com/questions/18289/how-to-get-semi-major-axis-from-tle#:~:text=Therefore%2C%20to%20go%20directly%20from,n%CF%80864002%2F3.
mu = 3.986004418*10^(14); %m^3*s^-2 for Earth
a = (mu^(1/3))/(((2*n*pi)/86400)^(2/3)); %m

% Calculating the true anomaly requires Newton Rhapson mehtod, uncomment the following to calculate true anomaly from Eccentric anomaly (E)
% Calculate the eccentric anomaly using Mean anomaly (M). True anomaly can then be calculated form the Eccentric Anomaly.
err = 1e-10;            %Calculation Error
E0 = M; t =1;
itt = 0;
while(t)
      E =  M + ecc*sind(E0);
     if ( abs(E - E0) < err)
         t = 0;
     end
     E0 = E;
     itt = itt+1;
end
nu = acosd((cosd(E)-ecc)/(1-ecc*cosd(E)));

%Part c 
%Sources:
%https://space.stackexchange.com/questions/19322/converting-orbital-elements-to-cartesian-state-vectors
%https://downloads.rene-schwarz.com/download/M001-Keplerian_Orbit_Elements_to_Cartesian_State_Vectors.pdf
r_c = a*(1 - ecc*cos(E)); %Use eccentric anomaly (E) to get distance to central body

%Position Vector o(t) in Orbital Frame
ox = r_c*cos(nu);
oy = r_c*sin(nu);
oz = 0.0;

%Velocity Vector o_dot(t) in Orbital Frame
ox_dot = (sqrt(mu*a)/r_c)*-sin(E);
oy_dot = (sqrt(mu*a)/r_c)*(sqrt(1-(ecc^2))*cos(E));
oz_dot = 0.0;

%Position Vector r(t) in Inertial Frame Bodycentric
rx = (ox*(cos(om)*cos(RAAN))-(sin(om)*cos(inc)*sin(RAAN)))-oy*((sin(om)*cos(RAAN))+(cos(om)*cos(inc)*sin(RAAN)));
ry = (ox*((cos(om)*sin(RAAN))-(sin(om)*cos(inc)*cos(RAAN)))-oy*((cos(om)*cos(inc)*cos(RAAN))+(sin(om)*sin(RAAN))));
rz = ox*sin(om)*sin(inc)-oy*cos(om)*sin(inc);
r = [rx, ry, rz];

%Velocity Vector v(t) in Inertial Frame Bodycentric
vx = (ox_dot*(cos(om)*cos(RAAN))-(sin(om)*cos(inc)*sin(RAAN)))-oy_dot*((sin(om)*cos(RAAN))+(cos(om)*cos(inc)*sin(RAAN)));
vy = (ox_dot*((cos(om)*sin(RAAN))-(sin(om)*cos(inc)*cos(RAAN)))-oy_dot*((cos(om)*cos(inc)*cos(RAAN))+(sin(om)*sin(RAAN))));
vz = ox_dot*sin(om)*sin(inc)-oy_dot*cos(om)*sin(inc);
v = [vx, vy, vz];

%Write data to KERV.txt
fileID = fopen('KERV.txt','w');
fprintf(fileID,'Position Vector is [%12.8f %12.8f %12.8f] \n', r);
fprintf(fileID,'Velocity Vector is [%12.8f %12.8f %12.8f] \n', v);
fclose(fileID);

disp('done')