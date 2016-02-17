clear all;
close all;
clc;

disp('************************************************************');
disp('Hey roomba, wake up!!!');
disp('************************************************************');

disp('roomba: .')
pause(0.2);
disp('roomba: ..')
pause(0.2);
disp('roomba: ...')
pause(0.2);
disp('roomba: ....')
pause(0.2);
disp('roomba: .....')
pause(0.2);



debug_mfu = true;

%% init
port_string                 = '/dev/ttyUSB0';
speed                       = 0.1;
oa_left_or_right_angle      = 45;
oa_front                    = 90;
start_wait                  = 5;
number_target               = 1;
robot_pose_abs              = [0;0;0];
robo_path                   = [0;0;0];


root                        = pwd;








% variables needed to have a nice window which lets us stop the program
% with a single click of the mouse
stop_program                = false;
f                           = figure;
b                           = uicontrol('style','push','string','stop','callback','stop_program=true');


%% main code
% this code will move the robot indefinitely and will try to avoid
% encountered obstacles


% wake up the robot
disp('roomba: okay, let''s go :) ');
pause(2.5);
if (debug_mfu==false)
    try 
        serPort = RoombaInit(port_string);
    catch
        disp('try another port');
        serPort = RoombaInit(port_string);
        
    end%try 

    pause(start_wait);
    BeepRoomba(serPort);
    pause(0.1);
    BeepRoomba(serPort);
    
    %get the global variable
    global td;
else
    global td
    % td = 0.015;
    td = 0.02;
end%if


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%find xbox
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%controller
disp('roomba: searching for controller');
joy = vrjoystick(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%find xbox
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%controller

robot_pose_rel = robot_pose_abs;

disp('************************************************************');
disp('Hey roomba, where are you going?');
disp('************************************************************');
pause(2.5);

[axes, buttons, povs] = read(joy);

run_program = true;
while (run_program==true)
    [axes, buttons, povs] = read(joy);
%     display(axes);
%     display(buttons);
%     display(povs);
    cmd_linear      = 0;
    cmd_angular     = 0;
    if ((axes(1)~=0) || (axes(2)~=0))
        cmd_linear  = -axes(2);
        cmd_angular = -axes(1);
    else
        if ((axes(3)~=0) || (axes(4)~=0))
            cmd_linear  = -axes(4);
            cmd_angular = -axes(3);
        else
            cmd_linear  = -axes(6);
            cmd_angular = -axes(5);
        end%if
    end%if
    
    
    mfu_set_robot_lin_speed(serPort, cmd_linear);
    if (cmd_angular>0)
        lmo_turnAngle(serPort, speed/2, 5);
    elseif (cmd_angular<0)
        lmo_turnAngle(serPort, speed/2, -5);
    else
        %do nothing
    end%if
    
    pause(0.05);
end%while


close(joy);

disp('************************************************************');
disp('roomba: main.m executed succesfully');
disp('************************************************************');
pause(3.);
disp('roomba: going back to sleep');
pause(0.1);
disp('roomba: going back to sleep .');
pause(0.1);
disp('roomba: going back to sleep ..');
pause(0.1);
disp('roomba: going back to sleep ...');
pause(0.1);
disp('roomba: zzzzz ZZZZ zzzzz ZZZZZ');
pause(0.1);
