%RoombaInit();
clear all;
close all;
clc;

%% initialisierung
port_string                 = '/dev/ttyUSB0';
speed                       = 0.2;
oa_left_or_right_angle      = 45;
oa_front                    = 90;
start_wait                  = 5;

% variables needed to have a nice window which lets us stop the program
% with a single click of the mouse
stop_program    = false;
f               = figure;
b               = uicontrol('style','push','string','stop','callback','stop_program=true');


%% main code
% this code will move the robot indefinitely and will try to avoid
% encountered obstacles


% wake up the robot
try 
    serPort = RoombaInit(port_string);
catch
    disp('try another port')
end%try 

pause(start_wait);
BeepRoomba(serPort);
pause(0.1);
BeepRoomba(serPort);

%get the global variable
global td;

% program loop
while (stop_program==false)
    % draw the user interface (so far only a stop button)
    drawnow;
    mfu_set_robot_lin_speed(serPort, speed);
    [BumpRight,BumpLeft,WheDropRight,WheDropLeft,WheDropCaster,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
    if ((BumpRight==1) || (BumpLeft==1) || (BumpFront==1) )
        %  we have found an obstacle
        disp('performing OA');
        if ((BumpFront==1) )
            % obstacle is in front of us
            lmo_travelDist(serPort, 0.1, -0.07);
            lmo_turnAngle(serPort, 0.1, oa_front);
        elseif ((BumpRight==0) && (BumpLeft==1))
            % obstacle is on our left so we want to turn right
            lmo_travelDist(serPort, 0.1, -0.07);
            lmo_turnAngle(serPort, 0.1, -oa_left_or_right_angle);
        else
            % obstacle is on our right so we want to turn left
            lmo_travelDist(serPort, 0.1, -0.05);
            lmo_turnAngle(serPort, 0.1, oa_left_or_right_angle);

        end%if
    else
        disp('moving');
        % no obstacle --> do nothing 
    end%if

    
    pause(td);
end%while
disp('the user has stopped the execution of main_plus_oa');
%play a song 
BeepRoomba(serPort);


%stop the robot
mfu_set_robot_lin_speed(serPort, 0);
pause(td);

%put the robot back to sleep

try 
    fwrite(serPort, [133]);  
    fwrite(serPort);
    pause(5);
    
catch
    disp('WARNING:  putting the robot back to sleep failed.')

end





disp('finished');
%travelDist(ps, 0.25, 100);