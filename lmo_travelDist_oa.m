function [success] = lmo_travelDist_oa(serPort, roombaSpeed, distance, oa_angle)
success                 = false;
global td;
distance_minimal        = roombaSpeed * td; 

try
    
    
    
    
    for (i=distance_minimal:distance_minimal:distance)
        %move robot
        success             = lmo_travelDist(serPort, roombaSpeed, distance_minimal);
        
        %test robot sensors
        [BumpRight, BumpLeft, BumpFront, Wall, virtWall, CliffLft, ...
        CliffRgt, CliffFrntLft, CliffFrntRgt, LeftCurrOver, RightCurrOver, ...
        DirtL, DirtR, ButtonPlay, ButtonAdv, Dist, Angle, ...
        Volts, Current, Temp, Charge, Capacity, pCharge]   = AllSensorsReadRoomba(serPort);
        
        if ((BumpRight==1) || (BumpLeft==1) || (BumpFront==1) )
            %  we have found an obstacle
            disp('performing OA');
            if ((BumpFront==1) )
                % obstacle is in front of us
                lmo_travelDist(serPort, 0.1, -0.05);
                lmo_turnAngle(serPort, 0.1, 90);
            elseif ((BumpRight==0) && (BumpLeft==1))
                % obstacle is on our left so we want to turn right
                lmo_travelDist(serPort, 0.1, -0.05);
                lmo_turnAngle(serPort, 0.1, -oa_angle);
            else
                % obstacle is on our right so we want to turn left
                lmo_travelDist(serPort, 0.1, -0.05);
                lmo_turnAngle(serPort, 0.1, oa_angle);
                
            end%if
        else
            disp('moving');
            %do nothing
        end%if
    
    
    end%for
       
        
    
catch
    disp('WARNING:  travel dist function did not terminate correctly.  Output may be unreliable.')

end