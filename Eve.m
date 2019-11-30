classdef Eve
    %EVE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        n
        % NOTE: n bit key according to protocol description, but we'll just store
        % a Lehmer code because it makes way more sense
        eK1
        % NOTE: n/2 bit key according to protocol description, but we'll just store
        % a Lehmer code because it makes way more sense
        eK2
        eAlice
        eBob
    end
    
    methods
        function obj = Eve(n)
            obj.n = n;
            % NOTE: n bit key according to protocol description, but we'll just store
            % a Lehmer code because it makes way more sense
            obj.eK1 = utilities.createLehmerCode(n*3/4);
            % NOTE: n/2 bit key according to protocol description, but we'll just store
            % a Lehmer code because it makes way more sense
            obj.eK2 = utilities.createLehmerCode(n*1/4);
            obj.eAlice = Alice(obj.eK1, obj.eK2);
            obj.eBob = Bob(obj.eK1, obj.eK2);
        end
        
        function [] = impersonateAlice(obj, bob, m)
            %IMPERSONATION Sends a message to Bob using random keys
            %   in  bob:Bob - Recipient
            %   in  m:[number] - message cbits
            obj.eAlice.sendMessage(obj, bob, m);
        end
        
        function [] = impersonateBob(obj, bob, m)
            %IMPERSONATION Sends a message to Bob using random keys
            %   in  bob:Bob - Recipient
            %   in  m:[number] - message cbits
            alice.sendMessage(obj, obj.eBob, m);
        end
        
        function [] = interceptResend(obj, alice, bob, m)
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
        
        function [] = modification(obj, alice, bob, m)
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
            alice.checkSequence = randi([0 1], length(M), 1);
            C = Alice.generateBellPairs(alice.checkSequence);
            Cba = Alice.separateCheckPairs(C);
            SCba = tensor(S, Cba);
            Q = utilities.LehmerShuffleK1(SCba, alice.K1);
            % Eve modifies a single qubit
            A_ind = randi(obj.n);
            A = tensor(helper.power(helper.I, A_ind-1), helper.X, helper.power(helper.I, obj.n-A_ind));
            Aq = u_propagate(Q,A);
            bob.receiveMessage(alice, Aq);
        end
    end
end

