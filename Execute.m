disp('Executing randomization-based protocol, no attacker.');

n = 16;
m = randi([0 1], n/8, 1);
K1 = randi([0 1], 2, 1); % NOTE: n bits according to protocol description
K2 = randi([0 1], 1, 1); % NOTE: n/2 bits according to protocol description

fprintf('K1: %s\n', utilities.bitstring(K1));
fprintf('K2: %s\n', utilities.bitstring(K2));
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