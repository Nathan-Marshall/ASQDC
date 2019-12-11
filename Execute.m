n = 16;
numExecutions = 10;

fprintf('Executing randomization-based protocol, no attacker...\n');
successCount = 0;
for i = 1:numExecutions
    [m, alice, bob, ~] = prepare(n);
    alice.sendMessage(bob, m);
    
    if isequal(bob.receivedMessage, m) && bob.hashVerified && alice.success
        successCount = successCount + 1;
    end
end
fprintf('Number of simulations: %+5s\n', sprintf('%d', numExecutions));
fprintf('Protocol succeeded:    %+5s\n\n', sprintf('%d', successCount));

fprintf('Executing impersonation of Alice attack on randomization-based protocol...\n');
hashVerifiedCount = 0;
for i = 1:numExecutions
    [m, alice, bob, eve] = prepare(n);
    eve.impersonateAlice(bob, m);
    
    if bob.hashVerified
        hashVerifiedCount = hashVerifiedCount + 1;
    end
end
fprintf('Number of simulations:   %+5s\n', sprintf('%d', numExecutions));
fprintf('Eve was detected by Bob: %+5s\n\n', sprintf('%d', numExecutions - hashVerifiedCount));

fprintf('Executing impersonation of Bob attack on randomization-based protocol...\n');
checkVerifiedCount = 0;
for i = 1:numExecutions
    [m, alice, bob, eve] = prepare(n);
    eve.impersonateBob(alice, m);
    
    if alice.success
        checkVerifiedCount = checkVerifiedCount + 1;
    end
end
fprintf('Number of simulations:     %+5s\n', sprintf('%d', numExecutions));
fprintf('Eve was detected by Alice: %+5s\n\n', sprintf('%d', numExecutions - checkVerifiedCount));

fprintf('Executing intercept and resend attack randomization-based protocol...\n');
hashVerifiedCount = 0;
checkVerifiedCount = 0;
undetectedCount = 0;
for i = 1:numExecutions
    [m, alice, bob, eve] = prepare(n);
    eve.interceptResend(alice, bob, m);
    
    if bob.hashVerified
        hashVerifiedCount = hashVerifiedCount + 1;
        if alice.success
            undetectedCount = undetectedCount + 1;
        end
    end
    if alice.success
        checkVerifiedCount = checkVerifiedCount + 1;
    end
end
fprintf('Number of simulations:             %+5s\n', sprintf('%d', numExecutions));
fprintf('Eve was detected by Bob:           %+5s\n', sprintf('%d', numExecutions - hashVerifiedCount));
fprintf('Eve was detected by Alice:         %+5s\n', sprintf('%d', numExecutions - checkVerifiedCount));
fprintf('Eve was detected by at least one:  %+5s\n\n', sprintf('%d', numExecutions - undetectedCount));

fprintf('Executing 1-qbit modification attack on randomization-based protocol...\n');
hashVerifiedCount = 0;
checkVerifiedCount = 0;
bothVerifiedCount = 0;
for i = 1:numExecutions
    [m, alice, bob, eve] = prepare(n);
    eve.modification(alice, bob, m);
    
    if bob.hashVerified
        hashVerifiedCount = hashVerifiedCount + 1;
        if alice.success
            bothVerifiedCount = bothVerifiedCount + 1;
        end
    end
    if alice.success
        checkVerifiedCount = checkVerifiedCount + 1;
    end
end
fprintf('Number of simulations:     %+5s\n', sprintf('%d', numExecutions));
fprintf('Eve was detected by Bob:   %+5s\n', sprintf('%d', numExecutions - hashVerifiedCount));
fprintf('Eve was detected by Alice: %+5s\n', sprintf('%d', hashVerifiedCount - checkVerifiedCount));
fprintf('Eve was detected:          %+5s\n', sprintf('%d', numExecutions - bothVerifiedCount));


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