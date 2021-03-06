classdef laser_Scanner
    
    properties
        laserResponse;
        status = 0;
        oneScan;
        rob_pos;
        rob_ori;
        laserData;
        laserTimeStamp;
        robot_position;
        robot_orientation;
        
    end
    
    methods
        function obj = laser_Scanner(vrep,clientID,robot) %% Constructor
            %% Intializing Communication
%             [obj.laserResponse(1)] = vrep.simxSetStringSignal(clientID,'request','laser',vrep.simx_opmode_oneshot);
            [obj.laserResponse(2),obj.oneScan] = vrep.simxGetStringSignal(clientID,'reply',vrep.simx_opmode_streaming);
            [obj.laserResponse(3),obj.rob_pos] = vrep.simxGetObjectPosition(clientID, robot,-1, vrep.simx_opmode_streaming);
            [obj.laserResponse(4),obj.rob_ori] = vrep.simxGetObjectOrientation(clientID,robot,-1,vrep.simx_opmode_streaming);
            
            %% Checking for initial data reception
            while obj.status ==0
%                 [obj.laserResponse(1)] = vrep.simxSetStringSignal(clientID,'request','laser',vrep.simx_opmode_oneshot);
%                 if (obj.laserResponse(1)==vrep.simx_error_noerror)
                    [obj.laserResponse(2),obj.oneScan] = vrep.simxGetStringSignal(clientID,'reply',vrep.simx_opmode_buffer);
                    if (obj.laserResponse(2)==vrep.simx_error_noerror)
                        obj.status = 1;
                    end
%                 end
            end
        end
        
        function obj = Scan(obj,vrep,clientID,robot)
            %% Setting Laser Signal
%             [obj.laserResponse(1)] = vrep.simxSetStringSignal(clientID,'request','laser',vrep.simx_opmode_oneshot);
            
%             if (obj.laserResponse(1)==vrep.simx_error_noerror)
%                 fprintf('Signal is Set\n');
                
                %% Receiving response from Laser
                [obj.laserResponse(2),obj.oneScan] = vrep.simxGetStringSignal(clientID,'reply',vrep.simx_opmode_oneshot_wait);
                
                if (obj.laserResponse(2)==vrep.simx_error_noerror)
                    obj.laserTimeStamp = vrep.simxGetLastCmdTime(clientID); %% Getting time Stamp for Communication Signal
                    fprintf('Reply received\n');
                    
                    %% Acquiring Position
                    [obj.laserResponse(3),obj.rob_pos] = vrep.simxGetObjectPosition(clientID, robot,-1, vrep.simx_opmode_buffer);
                    [obj.laserResponse(4),obj.rob_ori] = vrep.simxGetObjectOrientation(clientID,robot,-1,vrep.simx_opmode_buffer);
                    
                    %% Setting Positions in Correct format
                    obj.robot_position(1) = obj.rob_pos(1); % Taking x out of {x,y,z}
                    obj.robot_position(2) = obj.rob_pos(2); % Taking y out of {x,y,z}
                    obj.robot_orientation = obj.rob_ori(3); % Taking gamma out of {alpha,beta,gamma}
                    
                else fprintf('Error in receiving Data\n');
                end
                
%             else fprintf('Error in set signal\n');
%             end
            
            %% Data Conversion from string to Numbers
            if(numel(obj.oneScan~=0))
                count =1;
                temp_count =1;
                laser_Data = zeros(1);
                
                for j= 2:(length(obj.oneScan))
                    if((obj.oneScan(j)== ',')||(obj.oneScan(j)=='}'))
                        laser_Data(count) = str2double(temp_Data);
                        count = count+1;
                        temp_count = 1;
                        continue;
                    end
                    
                    temp_Data(temp_count) = obj.oneScan(j);
                    temp_count = temp_count+1;
                end
                
                if(numel(laser_Data)>1)
                    reshapedData = reshape(laser_Data,3,(length(laser_Data)/3));
                    
                    for k = 1:length(reshapedData)
                        obj.laserData(:,k) = reshapedData(:,k);
                    end
                    
                end
            end
            %%
            pause(0.3); %% Necessary for communication. You may decrease the pause based on your requirements and System Capabilities
            
        end
    end
end