function [bbNameResult] = BbName(arg)

%This function maps between button box inputs from the Lumina box in ASCII mode (e.g. 52) and button names (e.g. "4" for button 4). 
%Mimicks the function KbName for keyboards. 

%Create cell array that maps ASCII codes to button names
bbLumina = cell(1,53);
bbLumina{49} = '1'; %Button 1
bbLumina{50} = '2'; %Button 2
bbLumina{51} = '3'; %Button 3
bbLumina{52} = '4'; %Button 4
bbLumina{53} = '5'; %Scan trigger

if isa(arg, 'double') %If argument is ASCII code, return button name
    if length(arg) == length(bbLumina)
        bbNameResult = find(arg);
        bbNameResult = BbName(bbNameResult);
    else
        bbNameResult = bbLumina{arg};
    end
elseif isa(arg, 'char') %If argument is button name, return ASCII code
    for i=1:length(bbLumina)
        if strcmpi(char(bbLumina{i}), arg)
            bbNameResult = i;
            break;
        end
    end
end

end

