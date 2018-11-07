function [output, stpEvt] = is_stop_event(key_pressed,key_desired)
%key_pressed should be a valid keycode (see the BbCheck function)
%key_desired should be a string in MacStim format
%output a a boolean variable that indicates whether a stop event has
%occurred, while stpEvt holds the key that caused the event.

%k\ matches any character
if strcmp(key_desired, 'k\')
    output = true;
    stpEvt = key_pressed;
    return;
end;

%'n' matches nothing
if isempty(key_desired) || strcmp( key_desired, 'n' ) 
    output = false;
    stpEvt = [];
    return;
end;

%0 means it was blank, so we match nothing
if isnumeric(key_desired) 
    if key_desired == 0 
        output = false;
        stpEvt = [];
        return;
    end;
end;

if ischar(key_desired)
        
    keylist = key_pressed;
    while sum(keylist)>0, %if a key was pressed 
        j = find(keylist==min(nonzeros(keylist))); %find the earliest key pressed
        
        for k = 1:length(j) %for each of the earliest keys pressed
            for i = 1:length(key_desired) %check if it is a desired key
                if BbName(j(k)) == key_desired(i);
                    output = true;
                    stpEvt = key_desired(i);
                    return; 
                end;
                keylist(j(k)) = 0; %remove undesired key from list of pressed keys
            end;
        end;
    end;

    
    output = false;
    stpEvt = [];
    return;
    
else
    %key_desired should have been a string
    fprintf('\nerror! in is_stop_event key_desired = %d\n',key_desired);
    output = false;
    stpEvt = [];
    return;
end

%Defaults to false
fprintf('is_stop_event was confused.  Returning false\nkey_pressed = %d key_desired = %d\n',key_pressed,key_desired);
output = false;
stpEvt = [];
return;

    
    