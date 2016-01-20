function [success] = lmo_travelDist(serPort, roombaSpeed, distance)
success = false;

try

    var = distance/roombaSpeed;
    
    if (roombaSpeed < 0) %Speed given by user shouldn't be negative
        disp('WARNING: Speed inputted is negative. Should be positive. Taking the absolute value');
        roombaSpeed = abs(roombaSpeed);
    end
    
    if (abs(roombaSpeed) < .025) %Speed too low
        disp('WARNING: Speed inputted is too low. Setting speed to minimum, .025 m/s');
        roombaSpeed = .025;
    end
    
    
    if (distance < 0) %Definition of SetFwdVelRAdius Roomba, speed has to be negative to go backwards. Takes care of this case. User shouldn't worry about negative speeds
        roombaSpeed = -1 * roombaSpeed;
    end
    
    
    roombaSpeed_mm = roombaSpeed *1000;
    
    fwrite(serPort, [137]);  
    fwrite(serPort,roombaSpeed_mm, 'int16');
    fwrite(serPort,0, 'int16');
    pause(var);
    fwrite(serPort, [137]);  
    fwrite(serPort,0, 'int16');
    fwrite(serPort,0, 'int16');
    pause(0.015);
    success =true;
    
catch
    disp('WARNING:  travel dist function did not terminate correctly.  Output may be unreliable.')

end