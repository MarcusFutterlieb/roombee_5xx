function mfu_set_robot_lin_speed(serPort, roombaSpeed)
% this function sets the linear speed of the robot as opposed
global td;
forward         = false;
stop_robot      = false;
if (roombaSpeed == 0)
    %the user wants the robot to stop
    stop_robot  = true;
else
    stop_robot  = false;
end%if

if (roombaSpeed>0)
    forward     = true; %the user wants to drive forward
else
    forward     = false;
end%if


% check if the speed that is requested is to small
if (abs(roombaSpeed) < .025) %Speed too low
    if (stop_robot==false)
        disp('WARNING: Speed inputted is too low. Setting speed to minimum, .025 m/s');
    else
        disp('sending ZERO speed --> stopping the robot');
    end%if
    
    if (forward==true)
        roombaSpeed =  0.025;
    else
        roombaSpeed = -0.025;
    end%if
end
   
%check if the speed that was requested is to high
if (abs(roombaSpeed) > 0.5) %Speed too low
    disp('WARNING: Speed inputted is too high. Setting speed to maximum, 0.5 m/s');
    if (forward==true)
        roombaSpeed =  0.5;
    else
        roombaSpeed = -0.5;
    end%if
end


try 
    
    %check if we wanted to stop the robot
    if(stop_robot==false)
        roombaSpeed_mm = roombaSpeed *1000;
    else
        roombaSpeed_mm = 0;
    end%if
    
    fwrite(serPort, [137]);  
    fwrite(serPort,roombaSpeed_mm, 'int16');
    fwrite(serPort,0, 'int16');
    %pause(td);
    
catch
    disp('WARNING:  setting speed function did not terminate correctly.  Output may be unreliable.')

end