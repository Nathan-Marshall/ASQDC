classdef Eve
    %EVE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % NOTE: n bit key according to protocol description, but we'll just store
        % a Lehmer code because it makes way more sense
        eK1 = utilities.createLehmerCode(n*3/4);
        % NOTE: n/2 bit key according to protocol description, but we'll just store
        % a Lehmer code because it makes way more sense
        eK2 = utilities.createLehmerCode(n*1/4);
        eAlice = Alice(eK1, eK2);
        eBob = Bob(eK1, eK2);
    end
    
    methods
        function obj = Eve(inputArg1,inputArg2)
            %EVE Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
        
        function [] = impersonation(obj, bob, m)
            %IMPERSONATION Sends a message to Bob using random keys
            %   in  bob:Bob - Recipient
            %   in  m:[number] - message cbits
            obj.eAlice.sendMessage(obj, bob, m);
        end
        
        function [] = interceptResend(obj, alice, Q_, bob, m)
            % INTERCEPTRESEND Receives a message from Alice, measures it,
            % and resends it to Bob
            %   in  alice:Alice - Sender
            %   in  Q:state - message as a quantum state containing the
            %       message component S which is shuffled with the 2nd part
            %       of the check component Cb, followed by the first part
            %       of the check component Ca. Ca is technically not sent
            %       by Alice and should not be touched by Bob in this
            %       simulation.
            %   in  bob:Bob - Recipient
            %   in  m:[number] - message cbits
            alice.sendMessage(obj.eBob, m);
            obj.eAlice.sendMessage(bob, m);
        end
        
        function [] = modification(obj, alice, Q_, bob, m)
            % MODIFICATION Receives a message from Alice, changes it,
            % and resends it to Bob
            %   in  alice:Alice - Sender
            %   in  Q:state - message as a quantum state containing the
            %       message component S which is shuffled with the 2nd part
            %       of the check component Cb, followed by the first part
            %       of the check component Ca. Ca is technically not sent
            %       by Alice and should not be touched by Bob in this
            %       simulation.
            %   in  bob:Bob - Recipient
            %   in  m:[number] - message cbits
            disp('Alice is sending a message to Bob.');
            alice.success = false;
            M = [m; utilities.hash(m)];
            S = Alice.generateBellPairs(M);
            % Eve modifies a single Bell pair (corresponding to a cbit)
            % here
            
            alice.checkSequence = randi([0 1], length(M), 1);
            C = Alice.generateBellPairs(obj.checkSequence);
            Cba = Alice.separateCheckPairs(C);
            SCba = tensor(S, Cba);
            Q = utilities.LehmerShuffleK1(SCba, obj.K1);
            bob.receiveMessage(obj, Q);
        end
    end
end

