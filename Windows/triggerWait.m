function [scan_startTime] = triggerWait(portName)

%This function waits for a scan trigger from a specified port
IOPort('Flush', portName); %flush event buffer
scanPulse=0;
while scanPulse~=1 %wait for a pulse
    [portData,portTime,readerror] = IOPort('read', portName);
    if any(portData==BbName('5')) %Trigger name is mapped to '5' in BbName; 53 is the actual ASCII code the scan trigger sends through the port
        scanPulse=1;
    end
    WaitSecs(.005); %poll every 5 ms
end

%Get scan start time
scan_startTime = portTime;

end

