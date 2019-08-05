clear;

% Commands
cmdPinMode = 0;
cmdDigitalWrite = 1;
cmdAnalogWrite = 2;
cmdMoveTo = 3;
cmdSetSpeed = 4;
cmdDistanceToGo = 5;
cmdTargetPosition = 6;
cmdCurrentPosition = 7;
cmdHasArrived = 8;

% Pin modes
pmOutput = 0;
pmInput = 1;
pmInputPullup = 2;

% Digtal write values
dwvLow = 0;
dwvHigh = 1;

q = 'q';

ports = seriallist();

[selection, ok] = listdlg( ...
    'PromptString', 'Select Arduino serial port', ...
    'SelectionMode', 'single', ...
    'ListString', ports ...
);

if ~ok
    error('No serial port selected');
end

port = ports{selection};
arduino = serial(port);
fopen(arduino);

% Wait for `fopen`
pause(2);

state = struct();

while true
    command = input('Send command to arduino: ');

    if command == 'q'
        break
    elseif ...
        command == cmdPinMode || ...
        command == cmdDigitalWrite || ...
        command == cmdAnalogWrite ...

        state.pin = input('Enter pin: ');

        if command == cmdPinMode
            state.pinMode = input('Enter pin mode: ');
        elseif command == cmdDigitalWrite
            state.digitalWriteValue = input('Enter value: ');
        elseif command == cmdAnalogWrite
            state.analogWriteValue = input('Enter value: ');
        end

    elseif command == cmdMoveTo
        state.targetPos = input('Enter targetPos: ');
    elseif command == cmdSetSpeed
        state.speed = input('Enter speed: ');
    end

    % `bool` on arduino is 8 bits. `int8` on matlab is 8 bits
    % `int` on arduino is 16 bits. `int16` on matlab is 16 bits
    % `long` on arduino is 32 bits. `int32` on matlab is 32 bits
    % `float` on arduino is 32 bits. `float32` on matlab is 32 bits

    fwrite(arduino, command, 'int8');

    if ...
        command == cmdPinMode || ...
        command == cmdDigitalWrite || ...
        command == cmdAnalogWrite ...
        %
        fwrite(arduino, state.pin, 'int16')

        if command == cmdPinMode
            fwrite(arduino, state.pinMode, 'int16')
        elseif command == cmdDigitalWrite
            fwrite(arduino, state.digitalWriteValue, 'int8')
        elseif command == cmdAnalogWrite
            fwrite(arduino, state.analogWriteValue, 'int16')
        end

    elseif command == cmdMoveTo
        fwrite(arduino, state.targetPos, 'int32')
    elseif command == cmdSetSpeed
        fwrite(arduino, state.speed, 'float32')
    end

    % Short pause to receive messages from arduino
    pause(0.20);

    if arduino.BytesAvailable
        if command == cmdDistanceToGo
            pos = fread(arduino, 1, 'int32');
            fprintf('Distance to go: %i\n', pos);
        elseif command == cmdTargetPosition
            pos = fread(arduino, 1, 'int32');
            fprintf('Target position: %i\n', pos);
        elseif command == cmdCurrentPosition
            pos = fread(arduino, 1, 'int32');
            fprintf('Current pos: %i\n', pos);
        elseif command == cmdHasArrived
            hasArrived = fread(arduino, 1, 'int8');
            fprintf('Has arrived: %i\n', hasArrived);
        else
            msg = fscanf(arduino);
            fprintf('Message from arduino:\n    %s', msg);
        end
    end
end

fclose(arduino);
delete(arduino);
