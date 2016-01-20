clear all;
close all;
clc;

disp('************************************************************');
disp('Hey roomba, wake up!!!');
disp('************************************************************');

disp('roomba: .')
pause(1.);
disp('roomba: ..')
pause(1.);
disp('roomba: ...')
pause(1.);
disp('roomba: ....')
pause(1.);
disp('roomba: .....')
pause(1.);



debug_mfu = true;

%% initialisierung
port_string                 = '/dev/ttyUSB0';
speed                       = 0.1;
oa_left_or_right_angle      = 45;
oa_front                    = 90;
start_wait                  = 5;
number_target               = 1;
robot_pose_abs              = [0;0;0];
robo_path                   = [0;0;0];
letter_count                = [];
happy_birthday_str          = 'roomba: Happy Birthday ';
kirsten_str                 = ['K';'I';'R';'S';'T';'E';'N';];


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

h_start_end     = 0.7;
h               = 0.5;
w               = 0.25;
space_between   = 0.2;

h_start_end     = h_start_end/2;
h               = h/2;
w               = w/2;
space_between   = space_between/2;

c1 = (2 * (w^2))^0.5;
c2 = (w^2 + h^2)^0.5;
c3 = h/(cos(pi/4));

turn_1080   = [0,1080];
turn_360    = [0,360];
go_to_K     = [space_between,90];
write_K     = [h_start_end,180;...
               h/2,135;...
               c1,180; ...
               c1,90;...
               c1,45];

go_to_I     = [space_between,90];
write_I     = [h,180; ...
               h,90];
            
go_to_R     = [space_between,90];

write_R     = [h,-90; ...
                w,-90;...
                w,-90;...
                w,135;...
                c1,45];

go_to_S     = [space_between,0];

write_S     = [w,90;...
                w,90;...
                w,-90;...
                w,-90;...
                w,0];

go_to_T     = go_to_S;

write_T     = [h,180;...
                w,90;...
                h,90];
            
go_to_E     = [w+space_between,90];

write_E     = [h,-90;...
                w,180;...
                w,90;...
                w,90;...
                w,180;...
                w,90;...
                w,90;...
                w,0];
            
go_to_N     =    go_to_R;        


write_N     = [h,-135;...
                c3,135;...
                h_start_end,-90];
  
go_to_end   = go_to_S;


target_vec =  [   turn_360;go_to_K; ... 
    write_K;go_to_I;   ...
    write_I;go_to_R;   ...
    write_R;go_to_S;   ...
    write_S;go_to_T;   ...
    write_T;go_to_E;   ...
    write_E;go_to_N;   ...
    write_N;go_to_end; ...
    turn_360           ...
];



robot_pose_rel = robot_pose_abs;

disp('************************************************************');
disp('Hey roomba, where are you going?');
disp('************************************************************');
pause(2.5);

% program loop
while (stop_program==false)
    % draw the user interface (so far only a stop button)
    drawnow;
    
    while (robot_pose_rel(1)<target_vec(number_target,1)-0.01)
        fprintf(['roomba: x/y   ' '%6.2f %6.2f \n'], robot_pose_abs(1), robot_pose_abs(2));
%         if(robot_pose_rel(1)<target_vec(number_target,1)-0.02)
%             disp('weird');
%             disp(robot_pose_rel(1));
%             disp(target_vec(number_target,1)-0.02);
%         end%if
        if (debug_mfu == false)
            mfu_set_robot_lin_speed(serPort, speed);
        end%if
        [robot_pose_abs,robo_path]  = mfu_update_euler_odometry(robot_pose_abs,0,speed,false,td,true,robo_path);
        [robot_pose_rel,robo_path]  = mfu_update_euler_odometry(robot_pose_rel,0,speed,false,td,false,robo_path);
        %disp('moving');
        pause(td);
    end%while
    if (debug_mfu == false)
        if (target_vec(number_target,2)<360)
            lmo_turnAngle(serPort, speed/2, target_vec(number_target,2));
        else
            turns = target_vec(number_target,2)/ 180;
            for (i=1:turns)
                lmo_turnAngle(serPort, speed/2, 180);
            end%for
        end%if
    end%if
    %disp('turning');
    [robot_pose_abs,robo_path] = mfu_update_euler_odometry(robot_pose_abs,(target_vec(number_target,2))/180*pi,0,true,td,true,robo_path);
    
    if (number_target<size (target_vec,1))
        number_target = number_target +1;
        letter_count(size(letter_count,1)+1,1) = size(robo_path,1);
        robot_pose_rel = [0;0;0];
%         for (i=1:100)
%             disp('going to next');
%         end%for
    else
        stop_program = true;
    end%if
    
    %now save the robot pose
end%while
%disp('the user has stopped the execution of Kirstens bday present');
%play a song 
if (debug_mfu == false)
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
end%if
fprintf(['roomba: arrived at final position   ' '%6.2f %6.2f \n'], robot_pose_abs(1), robot_pose_abs(2));
pause (3);

disp('************************************************************');
disp('Hey roomba, playback recorded odometry');
disp('************************************************************');
pause(2.5);

disp('roomba: loading odometry record');
disp('roomba: .')
pause(1.);
disp('roomba: ..')
pause(1.);
disp('roomba: ...')
pause(1.);
disp('roomba: ....')
pause(1.);
disp('roomba: .....')
pause(1.);


f2                           = figure(2);
set(gcf,'position',[360 260 800 400]);
hold on;
ii = 1;
l_K    = size(turn_360,1) +    size(go_to_K,1) + size(write_K,1); 
l_I    = l_K +                  size(go_to_I,1) + size(write_I,1);
l_R    = l_I +                  size(go_to_R,1) + size(write_R,1);
l_S    = l_R +                  size(go_to_S,1) + size(write_S,1);
l_T    = l_S +                  size(go_to_T,1) + size(write_T,1);
l_E    = l_T +                  size(go_to_E,1) + size(write_E,1);
l_N    = l_E +                  size(go_to_N,1) + size(write_N,1);
l_vec = [l_K;l_I;l_R;l_S;l_T;l_E;l_N];

for jj=1:4:size(robo_path,1)
    plot(robo_path(jj,1),robo_path(jj,2),'b--o');
    pause(0.002);
    if(ii<=size(l_vec,1))
        if (jj>letter_count(l_vec(ii)))
            happy_birthday_str = [happy_birthday_str kirsten_str(ii) ];
            ii = ii + 1;
        end%if
    end%if
    disp(happy_birthday_str);
end%for
hold off;



disp('roomba: kirsten_b_day.m executed succesfully');
pause(3.);
disp('roomba: going back to sleep');
pause(1.);
disp('roomba: going back to sleep .');
pause(1.);
disp('roomba: going back to sleep ..');
pause(1.);
disp('roomba: going back to sleep ...');
pause(1.);
disp('roomba: zzzzz ZZZZ zzzzz ZZZZZ');
pause(1.);
