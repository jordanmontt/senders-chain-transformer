# senders-chain-transformer

A tool that modifies the execution path for a given context while leaving other callers intact. It takes a list of senders and an initial caller as input. It modifies the initial caller's message send with a new selector and, for each sender, clones the method with the new selector while changing the message send.
