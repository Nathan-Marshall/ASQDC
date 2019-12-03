n = 16;
numExecutions = 50;

fprintf('Executing randomization-based protocol, no attacker...\n');
messageOnlyCount = 0;
checkOnlyCount = 0;
bothCount = 0;
neitherCount = 0;
for i = 1:numExecutions
    [m, alice, bob, ~] = prepare(n);
    alice.sendMessage(bob, m);
    [messageOnlyCount, checkOnlyCount, bothCount, neitherCount] = count(alice, bob, m, messageOnlyCount, checkOnlyCount, bothCount, neitherCount);
end
printResults(messageOnlyCount, checkOnlyCount, bothCount, neitherCount);

fprintf('Executing impersonation of Alice attack on randomization-based protocol...\n');
messageOnlyCount = 0;
checkOnlyCount = 0;
bothCount = 0;
neitherCount = 0;
for i = 1:numExecutions
    [m, alice, bob, eve] = prepare(n);
    eve.impersonateAlice(bob, m);
    [messageOnlyCount, checkOnlyCount, bothCount, neitherCount] = count(eve.eAlice, bob, m, messageOnlyCount, checkOnlyCount, bothCount, neitherCount);
end
printResults(messageOnlyCount, checkOnlyCount, bothCount, neitherCount);

fprintf('Executing impersonation of Bob attack on randomization-based protocol...\n');
messageOnlyCount = 0;
checkOnlyCount = 0;
bothCount = 0;
neitherCount = 0;
for i = 1:numExecutions
    [m, alice, bob, eve] = prepare(n);
    eve.impersonateBob(alice, m);
    [messageOnlyCount, checkOnlyCount, bothCount, neitherCount] = count(alice, eve.eBob, m, messageOnlyCount, checkOnlyCount, bothCount, neitherCount);
end
printResults(messageOnlyCount, checkOnlyCount, bothCount, neitherCount);

fprintf('Executing intercept and resend attack randomization-based protocol...\n');
messageOnlyCount = 0;
checkOnlyCount = 0;
bothCount = 0;
neitherCount = 0;
for i = 1:numExecutions
    [m, alice, bob, eve] = prepare(n);
    eve.interceptResend(alice, bob, m);
    [messageOnlyCount, checkOnlyCount, bothCount, neitherCount] = count(alice, bob, m, messageOnlyCount, checkOnlyCount, bothCount, neitherCount);
end
printResults(messageOnlyCount, checkOnlyCount, bothCount, neitherCount);

fprintf('Executing 1-qbit modification attack on randomization-based protocol...\n');
messageOnlyCount = 0;
checkOnlyCount = 0;
bothCount = 0;
neitherCount = 0;
for i = 1:numExecutions
    [m, alice, bob, eve] = prepare(n);
    eve.modification(alice, bob, m);
    [messageOnlyCount, checkOnlyCount, bothCount, neitherCount] = count(alice, bob, m, messageOnlyCount, checkOnlyCount, bothCount, neitherCount);
end
printResults(messageOnlyCount, checkOnlyCount, bothCount, neitherCount);




%fprintf(['K1Encode: ' repmat('%d ', 1, length(K1Encode)) '\n'], K1Encode);
%fprintf(['K1Decode: ' repmat('%d ', 1, length(K1Decode)) '\n'], K1Decode);
%fprintf(['K2Encode: ' repmat('%d ', 1, length(K2Encode)) '\n'], K2Encode);
%fprintf(['K2Decode: ' repmat('%d ', 1, length(K2Decode)) '\n'], K2Decode);
%fprintf('Message: %s\n', utilities.bitstring(m));

%alice.sendMessage(bob, m);
%if alice.success
%    disp('Protocol succeeded.');
%    disp('Message sent:');
%    disp(m);
%    disp('Message received by Bob:');
%    disp(bob.receivedMessage);
%else
%    disp('Protocol failed.');
%    disp('Message sent:');
%    disp(m);
%    disp('Message received by Bob:');
%    disp(bob.receivedMessage);
%end

function [m, alice, bob, eve] = prepare(n)
    m = randi([0 1], n/8, 1);
    % NOTE: this should be an n bit key according to protocol description,
    % but we'll just store a Lehmer code because it makes way more sense
    K1Encode = utilities.createLehmerCode(n*3/4);
    K1Decode = utilities.invertLehmerCode(K1Encode);
    % NOTE: this should be an n/2 bit key according to protocol
    % description, but we'll just store a Lehmer code because it makes way
    % more sense
    K2Encode = utilities.createLehmerCode(n*1/4);
    K2Decode = utilities.invertLehmerCode(K2Encode);
    
    alice = Alice(K1Encode, K2Decode);
    bob = Bob(K1Decode, K2Encode);
    eve = Eve(n);
end

function [messageOnlyCountOut, checkOnlyCountOut, bothCountOut, neitherCountOut] = count(alice, bob, m, messageOnlyCountIn, checkOnlyCountIn, bothCountIn, neitherCountIn)
    messageOnlyCountOut = messageOnlyCountIn;
    checkOnlyCountOut = checkOnlyCountIn;
    bothCountOut = bothCountIn;
    neitherCountOut = neitherCountIn;

    if bob.receivedMessage == m
        if alice.success
            bothCountOut = bothCountIn + 1;
        else
            messageOnlyCountOut = messageOnlyCountIn + 1;
        end
    else
        if alice.success
            checkOnlyCountOut = checkOnlyCountIn + 1;
        else
            neitherCountOut = neitherCountIn + 1;
        end
    end
end

function [] = printResults(messageOnlyCount, checkOnlyCount, bothCount, neitherCount)
    fprintf('Message Only: %+5s\n', sprintf('%d', messageOnlyCount));
    fprintf('Check Only:   %+5s\n', sprintf('%d', checkOnlyCount));
    fprintf('Both:         %+5s\n', sprintf('%d', bothCount));
    fprintf('Neither:      %+5s\n\n', sprintf('%d', neitherCount));
end