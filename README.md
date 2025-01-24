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
                      |            #addOccupant:            |
                      |                                     |
                      +-------------------------------------+
                                        |
                                        |
                                        |
                                    	|
                                        v
                      +-------------------------------------+
                      |   Sender 1                          |
                      +-------------------------------------+
                      | Association >> #key:value:          |
					  | at offset: 42                       |
					  |                                     |

```Smalltalk
                  |	key: newKey value: newValue         |
                  |    	^ self basicNew key: newKey     |
				  |			value: newValue             |
```                               
                      +-------------------------------------+
                                        |
                                    	|
                                        v
                      +-------------------------------------+
                      |   Sender 2                          |
                      +-------------------------------------+
                      |  Dictionary >> #at:put:             |
                      | at offfset: **82**                  |
                      |                                     |
```smalltalk
                  |at: key put: anObject                |
                  | | index assoc |                     |
                  | index := self findElementOrNil: key.|
                  | assoc := array at: index.           |
                  | assoc ifNil: [self atNewIndex: index|
				  |     put: (Association key: key      |
				  |  	  value: anObject)]             |
                  |   ifNotNil: [assoc value: anObject].|
                  | ^ anObject                          |
```
                      +-------------------------------------+
                                        |
                                    	|
                                        v
                      +-------------------------------------+
                      |   Sender 3                          |
                      +-------------------------------------+
                      | Dictionary >> #at:ifAbsentPut:|     |
                      | at offset: **21**                   |
                      |                                     |
```Smalltalk
                  |at: key ifAbsentPut: aBlock          |
                  | ^ self                              |
				  |    at: key                          |
				  |    ifAbsent: [ self at: key         |
				  |                put: aBlock value]   |
```
                      +-------------------------------------+
                                   |
                                   |
                                   v
                      +-------------------------------------+
                      |   4. Dictionary >> #at:ifAbsent:   |
                      |      Offset: **54**                 |
                      |                                     |
                      |   ```smalltalk                     |
                      |   at: key ifAbsent: aBlock          |
                      |       ^ <((array at: (self findElementOrNil: key)) |
                      |           ifNil: [aBlock]           |
                      |           ifNotNil: [:assoc | assoc]) value> |
                      |   ```                               |
                      +-------------------------------------+
                                   |
                                   |
                                   v
                      +-------------------------------------+
                      |   5. Dictionary >> #at:ifAbsentPut:|
                      |      Offset: **48**                 |
                      |                                     |
                      |   ```smalltalk                     |
                      |   at: key ifAbsentPut: aBlock       |
                      |       ^ <self at: key ifAbsent: [self at: key put: aBlock value]> |
                      |   ```                               |
                      +-------------------------------------+
