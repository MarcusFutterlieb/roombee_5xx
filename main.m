%RoombaInit();
clear all;
close all;
clc;

ps = RoombaInit('/dev/ttyUSB0');

speed       = 0.4;
distance    = 0.5;
turnangle   = 90;


travel_success      = lmo_travelDist(ps,speed,distance);
pause(1);
lmo_turnAngle      (ps,speed/2,90);
pause(1);
travel_success      = lmo_travelDist(ps,speed,distance);
pause(1);
lmo_turnAngle      (ps,speed/2,90);
pause(1);
travel_success      = lmo_travelDist(ps,speed,distance);
pause(1);
lmo_turnAngle      (ps,speed/2,90);
pause(1);
travel_success      = lmo_travelDist(ps,speed,distance);
pause(1);
lmo_turnAngle      (ps,speed/2,90);
pause(1);

disp('finished');
%travelDist(ps, 0.25, 100);