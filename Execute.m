disp('Executing randomization-based protocol, no attacker.');

n = 16;
m = randi([0 1], n/8, 1);
% NOTE: n bit key according to protocol description, but we'll just store
% a Lehmer code because it makes way more sense
K1Encode = utilities.createLehmerCode(n*3/4);
K1Decode = utilities.invertLehmerCode(K1Encode);
% NOTE: n/2 bit key according to protocol description, but we'll just store
% a Lehmer code because it makes way more sense
K2Encode = utilities.createLehmerCode(n*1/4);
K2Decode = utilities.invertLehmerCode(K2Encode);

fprintf(['K1Encode: ' repmat('%d ', 1, length(K1Encode)) '\n'], K1Encode);
fprintf(['K1Decode: ' repmat('%d ', 1, length(K1Decode)) '\n'], K1Decode);
fprintf(['K2Encode: ' repmat('%d ', 1, length(K2Encode)) '\n'], K2Encode);
fprintf(['K2Decode: ' repmat('%d ', 1, length(K2Decode)) '\n'], K2Decode);
fprintf('Message: %s\n', utilities.bitstring(m));

alice = Alice(K1Encode, K2Decode);
bob = Bob(K1Decode, K2Encode);
eve = Eve(n);

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