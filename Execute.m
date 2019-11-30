disp('Executing randomization-based protocol, no attacker.');

n = 16;
m = randi([0 1], n/8, 1);
% NOTE: n bit key according to protocol description, but we'll just store
% a Lehmer code because it makes way more sense
K1 = utilities.createLehmerCode(n*3/4);
% NOTE: n/2 bit key according to protocol description, but we'll just store
% a Lehmer code because it makes way more sense
K2 = utilities.createLehmerCode(n*1/4);

fprintf(['K1: ' repmat('%d ', 1, length(K1)) '\n'], K1);
fprintf(['K2: ' repmat('%d ', 1, length(K2)) '\n'], K2);
fprintf('Message: %s\n', utilities.bitstring(m));

alice = Alice(K1, K2);
bob = Bob(K1, K2);

alice.sendMessage(bob, m);
if alice.success
    disp('Protocol succeeded.');
    disp('Message sent:');
    disp(m);
    disp('Message received by Bob:');
    disp(bob.receivedMessage);
else
    disp('Protocol failed.');
end

% impersonation - Eve sends message to Bob

% interceptResend - 