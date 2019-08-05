classdef Slider < handle
   properties (Constant)
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
   end

    properties (Access = protected)
        % Serial connection to Arduino
        Arduino
    end

    % `bool` on arduino is 8 bits. `int8` on matlab is 8 bits
    % `int` on arduino is 16 bits. `int16` on matlab is 16 bits
    % `long` on arduino is 32 bits. `int32` on matlab is 32 bits
    % `float` on arduino is 32 bits. `float32` on matlab is 32 bits

    methods (Access = protected)
        function writeCmd(obj, cmd)
            fwrite(obj.Arduino, cmd, 'int8');
        end
    end

    methods (Access = public)
        function obj = Slider(serialPort)
            % obj = Slider(serialPort)
            %
            % ---
            % Parameters:
            %     `serialPort`:
            %         - Serial port connected to Arduino.
            %         - If not provided, a selection box will prompt the user to
            %           choose a serial port.
            %         - Type: string

            if nargin < 1
                serialPorts = seriallist();

                [selection, ok] = listdlg( ...
                    'PromptString', 'Select Arduino serial port', ...
                    'SelectionMode', 'single', ...
                    'ListString', serialPorts ...
                );

                if ~ok
                    error('No serial port selected');
                end

                serialPort = serialPorts{selection};
            end

            obj.Arduino = serial(serialPort);
            fopen(obj.Arduino);

            % Wait for `fopen`
            pause(2);
        end

        function delete(obj)
            % delete(obj)

            fclose(obj.Arduino);
            delete(obj.Arduino);
        end

        function pinMode(obj, pin, mode)
            % pinMode(obj, pin, mode)
            %
            % See `pinMode` in Arduino reference

            obj.writeCmd(Slider.cmdPinMode);
            fwrite(obj.Arduino, pin, 'int16');
            fwrite(obj.Arduino, mode, 'int16');
        end

        function digitalWrite(obj, pin, value)
            % digitalWrite(obj, pin, value)
            %
            % See `digitalWrite` in Arduino reference

            obj.writeCmd(Slider.cmdDigitalWrite);
            fwrite(obj.Arduino, pin, 'int16');
            fwrite(obj.Arduino, value, 'int8');
        end

        function analogWrite(obj, pin, value)
            % analogWrite(obj, pin, value)
            %
            % See `analogWrite` in Arduino reference

            obj.writeCmd(Slider.cmdAnalogWrite);
            fwrite(obj.Arduino, pin, 'int16');
            fwrite(obj.Arduino, value, 'int16');
        end

        function moveTo(obj, pos, speed)
            % moveTo(obj, pos, speed)
            %
            % Move to absolute position with constant speed
            %
            % ---
            % Parameters:
            %     `pos`:
            %         - Absolute position from initial position
            %         - Units: steps
            %     `speed`:
            %         - Units: steps per second

            % Due to `AccelStepper` implementation, `moveTo` must be called
            % before `setSpeed`

            obj.writeCmd(Slider.cmdMoveTo);
            fwrite(obj.Arduino, pos, 'int32');

            obj.writeCmd(Slider.cmdSetSpeed);
            fwrite(obj.Arduino, speed, 'float32');
        end

        function result = distanceToGo(obj)
            % result = distanceToGo(obj)
            %
            % Get remaining distance from target position from last `moveTo`
            % call
            %
            % ---
            % Returns:
            %     `result`:
            %         - Units: steps

            obj.writeCmd(Slider.cmdDistanceToGo);
            result = fread(obj.Arduino, 1, 'int32');
        end

        function result = targetPosition(obj)
            % result = targetPosition(obj)
            %
            % Get target position from last `moveTo` call
            %
            % ---
            % Returns:
            %     `result`:
            %         - Units: steps

            obj.writeCmd(Slider.cmdTargetPosition);
            result = fread(obj.Arduino, 1, 'int32');
        end

        function result = currentPosition(obj)
            % result = currentPosition(obj)
            %
            % Get current position from last `moveTo` call
            %
            % ---
            % Returns:
            %     `result`:
            %         - Units: steps

            obj.writeCmd(Slider.cmdCurrentPosition);
            result = fread(obj.Arduino, 1, 'int32');
        end

        function result = hasArrived(obj)
            % result = hasArrived(obj)
            %
            % Whether the motor has arrived at the target position of the last
            % `moveTo` call

            obj.writeCmd(Slider.cmdHasArrived);
            result = fread(obj.Arduino, 1, 'int8');
        end
    end
end
