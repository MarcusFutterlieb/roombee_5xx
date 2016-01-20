function [ robot_pose,path ] = mfu_update_euler_odometry( robot_pose,dtheta,lin_speed,radians_traveled_direct,td,save_path,path )
%MFU_UPDATE_EULER_ODOMETRY Summary of this function goes here
%   Detailed explanation goes here
distance_traveled   = lin_speed * td;
if (radians_traveled_direct== true)
    radians_traveled    = wrapToPi(dtheta); % distance traveled in radians
else
    radians_traveled    = wrapToPi(dtheta*td); % distance traveled in radians
end%if

robot_pose(3)       = wrapToPi(  robot_pose(3) + radians_traveled);
robot_pose(1)       = robot_pose(1) + (cos(robot_pose(3))*distance_traveled);
robot_pose(2)       = robot_pose(2) + (sin(robot_pose(3))*distance_traveled);

if(save_path==true)
    theta = robot_pose(3);
    x = robot_pose(1);
    y = robot_pose(2);
    path(size(path,1)+1,1:3) = [x,y,theta]; 
%     f3 = figure(3);
%     plot (x,y);
%     hold on;
end%if
end

