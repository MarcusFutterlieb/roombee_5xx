%RoombaInit();
clear all;
close all;
clc;

ps = RoombaInit('/dev/ttyUSB0');

speed       = 0.1;
distance    = 0.5;
turnangle   = 90;

lmo_turnAngle      (ps,speed,90);
travel_success      = lmo_travelDist(ps,speed,0.05);
pause(1);

disp('finished');
%travelDist(ps, 0.25, 100);