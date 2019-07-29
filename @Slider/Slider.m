classdef Slider < handle
    properties (Access = private)
        Arduino

        % The pins on the arduino controlling the stepper motor
        Pins

        % Whether the motor has taken it's first step
        IsFirstStep

        % Output from `tic` function recording the time of the last step
        LastStepTic

        % Which step the motor is currently on.
        % Ranges from 1 to `length(obj.Pins)`
        StepNumber

        % The delay between each step. Controls the speed of the motor.
        % Units: sec
        StepDelay

        % Steps remaining until destination reached
        StepsRemaining

        % Displacement in steps from the initial position
        Pos
    end

    methods (Access = protected)
        % TODO: function for testing without arduino, comment this out
        function step(obj)
            % step(obj)
            %
            % Step the motor

            if length(obj.Pins) == 4
                switch obj.StepNumber
                    case 1
                        fprintf('1 0 1 0\n');
                    case 2
                        fprintf('0 1 1 0\n');
                    case 3
                        fprintf('0 1 0 1\n');
                    case 4
                        fprintf('1 0 0 1\n');
                end
            end
        end

        % TODO: uncomment this and comment out the function above
        % function step(obj)
        %     % step(obj)
        %     %
        %     % Step the motor

        %     if length(obj.Pins) == 4
        %         switch obj.StepNumber
        %             case 1
        %                 writeDigitalPin(obj.Arduino, obj.Pins(1), 1);
        %                 writeDigitalPin(obj.Arduino, obj.Pins(2), 0);
        %                 writeDigitalPin(obj.Arduino, obj.Pins(3), 1);
        %                 writeDigitalPin(obj.Arduino, obj.Pins(4), 0);
        %             case 2
        %                 writeDigitalPin(obj.Arduino, obj.Pins(1), 0);
        %                 writeDigitalPin(obj.Arduino, obj.Pins(2), 1);
        %                 writeDigitalPin(obj.Arduino, obj.Pins(3), 1);
        %                 writeDigitalPin(obj.Arduino, obj.Pins(4), 0);
        %             case 3
        %                 writeDigitalPin(obj.Arduino, obj.Pins(1), 0);
        %                 writeDigitalPin(obj.Arduino, obj.Pins(2), 1);
        %                 writeDigitalPin(obj.Arduino, obj.Pins(3), 0);
        %                 writeDigitalPin(obj.Arduino, obj.Pins(4), 1);
        %             case 4
        %                 writeDigitalPin(obj.Arduino, obj.Pins(1), 1);
        %                 writeDigitalPin(obj.Arduino, obj.Pins(2), 0);
        %                 writeDigitalPin(obj.Arduino, obj.Pins(3), 0);
        %                 writeDigitalPin(obj.Arduino, obj.Pins(4), 1);
        %         end
        %     end
        % end
    end

    methods (Access = public)
        function obj = Slider(a, pins)
            % obj = Slider(a)
            %
            % ---
            % Parameters:
            %     `a`: arduino object
            %     `pos`: vector of the pin numbers controlling the stepper motor

            obj.Arduino = a;

            if length(pins) == 4
                obj.Pins = pins;
            else
                fprintf('Only 4 wire stepper motors are currently supported\n');
            end

            obj.IsFirstStep = true;
            obj.StepNumber = 1;
            obj.StepsRemaining = 0;
            obj.Pos = 0;
        end

        function setSpeed(obj, speed)
            % setSpeed(obj, speed)
            %
            % ---
            % Parameters:
            %     `speed`: Units: steps / second

            obj.StepDelay = 1 / speed;
        end

        function setDestination(obj, steps)
            % setDestination(obj, steps)
            %
            % ---
            % Parameters:
            %    `steps`: Integer. Negative number means reverse direction

            obj.StepsRemaining = steps;
        end

        function run(obj)
            % run(obj)
            %
            % Step the motor if necessary. Call this function in a loop. You
            % can do other things in the loop, as long as its execution time
            % does not exceed `obj.StepDelay`

            if obj.StepsRemaining ~= 0
                if obj.IsFirstStep || toc(obj.LastStepTic) >= obj.StepDelay
                    obj.step();

                    obj.LastStepTic = tic();

                    if obj.IsFirstStep
                        obj.IsFirstStep = false;
                    end

                    if obj.StepsRemaining > 0
                        obj.StepsRemaining = obj.StepsRemaining - 1;
                        obj.Pos = obj.Pos + 1;

                        if obj.StepNumber == 4
                            obj.StepNumber = 1;
                        else
                            obj.StepNumber = obj.StepNumber + 1;
                        end
                    elseif obj.StepsRemaining < 0
                        obj.StepsRemaining = obj.StepsRemaining + 1;
                        obj.Pos = obj.Pos - 1;

                        if obj.StepNumber == 1
                            obj.StepNumber = 4;
                        else
                            obj.StepNumber = obj.StepNumber - 1;
                        end
                    end
                end
            end
        end

        function pos = getPos(obj)
            % pos = getPos(obj)
            %
            % ---
            % Returns:
            %     `pos`: See `obj.Pos`

            pos = obj.Pos;
        end

        function stepsRemaining = getStepsRemaining(obj)
            % stepsRemaining = getStepsRemaining(obj)
            %
            % ---
            % Returns:
            %     `pos`: See `obj.Pos`

            stepsRemaining = obj.StepsRemaining;
        end

        function resetPos(obj)
            % resetPos(obj)
            %
            % Set destination of the slider to its initial position

            obj.setDestination(-obj.getPos())
        end
    end
end
