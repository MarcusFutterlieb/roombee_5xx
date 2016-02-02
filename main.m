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
letter_count                = [];
happy_birthday_str          = 'roomba: Happy Birthday ';
root                        = pwd;
alphabet_file_path          = [pwd,'/alphabet.xml'];
movement_encyclopedia       = xmlread(alphabet_file_path);

%ask for string to print
prompt                      = 'roomba: please enter the name you want me to write  -->';
string                      = input(prompt,'s');
string_vec                  = 'a';
for (i=1:1:size(string,2))
    string_vec(i,1)         = string(i);
end%for

%ask for scalefactor
prompt                      = 'roomba: what scale should the name have  -->';
scale_factor                = input(prompt);

%build movement-vector from string

disp('roomba: parsing alphabet for associated movements');
target_vec                  = 0;
target_vec_tmp              = 0;
out_vec                     = 0;
out_vec_tmp                 = 0;
symbol_length_vec           = 0;
symbol_length_vec_tmp       = 0;
for (i=1:1:size (string_vec,1))
    
    symbol_list = movement_encyclopedia.getElementsByTagName('letter');

                for j = 0:1:(symbol_list.getLength-1)
                    symbol      = symbol_list.item(j);
                    name        = char(symbol.getAttribute('name'));
                    name_cmp    = string_vec(i);
                    if(strcmp(name,name_cmp)==true)
                        out_vec_tmp                 = char(symbol.getAttribute('out'));
                        movement_sequence           = symbol.getElementsByTagName('movement_sequence').item(0);
                        movement_sequence_list      = movement_sequence.getElementsByTagName('move_turn');
                        target_vec_tmp              = 0;
                        for k = 1:1:(movement_sequence_list.getLength-1)
                            move_turn   = movement_sequence_list.item(k);
                            target_vec_tmp(k,1) = str2double(move_turn.getAttribute('move'));
                            target_vec_tmp(k,2) = str2double(move_turn.getAttribute('turn'));
                        end%for
                        symbol_length_vec_tmp = movement_sequence_list.getLength-1;
                        break;
                    end%if
                end%for
    if(i==1)
        target_vec          = target_vec_tmp;
        out_vec             = out_vec_tmp;
        symbol_length_vec   = symbol_length_vec_tmp;
    else
        target_vec          = [target_vec;target_vec_tmp];
        out_vec             = [out_vec;out_vec_tmp];
        
        symbol_length_vec   = [symbol_length_vec;(sum(symbol_length_vec)+symbol_length_vec_tmp)];
    end%if
    
end%for
%apply scale factor

target_vec = [target_vec(:,1).*scale_factor,target_vec(:,2)];

%kirsten_str                 = ['K';'I';'R';'S';'T';'E';'N';];


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
disp('roomba: .');
pause(0.3);
disp('roomba: ..');
pause(0.3);
disp('roomba: ...');
pause(0.3);
disp('roomba: ....');
pause(0.3);
disp('roomba: .....');
pause(0.3);


f2                           = figure(2);
set(gcf,'position',[360 260 800 400]);
hold on;
ii = 1;


l_vec = symbol_length_vec;

for jj=1:4:size(robo_path,1)
    plot(robo_path(jj,1),robo_path(jj,2),'b--o');
    pause(0.001);
    if(ii<=size(l_vec,1))
        if (jj>letter_count(l_vec(ii)-2))
            happy_birthday_str = [happy_birthday_str string_vec(ii) ];
            ii = ii + 1;
        end%if
    end%if
    disp(happy_birthday_str);
end%for
hold off;


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
