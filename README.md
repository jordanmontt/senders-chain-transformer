# senders-chain-transformer

A tool that modifies the execution path for a given context while leaving other callers intact. It takes a list of senders and an initial caller as input. It modifies the initial caller's message send with a new selector and, for each sender, clones the method with the new selector while changing the message send.

## How to install

```st
EpMonitor disableDuring: [
	Metacello new
		baseline: 'SendersChainTransformer';
		repository: 'github://jordanmontt/senders-chain-transformer:main';
		load ].
```

## How to use it

                      +-------------------------------------+
                      |           Allocation site           |
                      +-------------------------------------+
                      |            #allocSite:              |
                      |                                     |
                      |allocSite: anObject                  |
                      |   (self theOccupants                |
                      |       at: anObject class name       |
                      |       ifAbsentPut:                  |
                      |           [ OrderedCollection new ])|
                      |    add: anObject                    |
                      +-------------------------------------+
                                        |
                                        |
                                    	|
                                        v
                      +-------------------------------------+
                      |   Sender 1                          |
                      +-------------------------------------+
                      |   Dictionary >> #at:ifAbsentPut:    |
                      |                                     |
                      |                                     |
                      | at: key ifAbsentPut: aBlock         |
                      |    ^ self at: key                   |
                      |       ifAbsent: [ self at: key      |	
                      |               put: aBlock value]    |
                      +-------------------------------------+
                                        |
                                        |
                                        v
                      +-------------------------------------+
                      |   Sender 2                          |
                      +-------------------------------------+
                      |   Dictionary >> #at:ifAbsent:       |
                      |                                     |
                      |                                     |
                      | at: key ifAbsent: aBlock            |
                      |    ^ (array at: (self               |
                      |       findElementOrNil: key))       |
                      |         ifNil: [aBlock]             |
                      |         ifNotNil: [:assoc | assoc]) |
                      |    value                            |
                      +-------------------------------------+
                                        |
                                        |
                                        v
                      +-------------------------------------+
                      |   Sender 3                          |
                      +-------------------------------------+
                      | Dictionary >> #at:put:              |
                      |                                     |
                      |                                     |
                      |at: key put: anObject                |
                      | | index assoc |                     |
                      | index := self findElementOrNil: key.|
                      | assoc := array at: index.           |
                      | assoc ifNil: [self atNewIndex: index|
                      |     put: (Association key: key      |
                      |           value: anObject)]         |
                      |   ifNotNil: [assoc value: anObject].|
                      | ^ anObject                          |
                      +-------------------------------------+
                                        |
                                        |
                                        v
                      +-------------------------------------+
                      |   Sender 4                          |
                      +-------------------------------------+
                      |   Dictionary >> #at:ifAbsentPut:    |
                      |                                     |
                      |                                     |
                      | at: key ifAbsentPut: aBlock         |
                      |   ^ self                            |
                      |       at: key                       |
                      |       ifAbsent: [ self at: key      |
                      |                put: aBlock value]   |
                      +-------------------------------------+
                                        |
                                        |
                                        v
                      +-------------------------------------+
                      |   Sender 5                          |
                      +-------------------------------------+
                      | Association >> #key:value:          |
                      |                                     |
                      |                                     |
                      | key: newKey value: newValue         |
                      |     ^ self basicNew key: newKey     |
                      |                  value: newValue    |
                      +-------------------------------------+
