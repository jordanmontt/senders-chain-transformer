Extension { #name : 'Interval' }

{ #category : '*SendersChainTransformer' }
Interval class >> newTenured [

	<primitive: 70>
	self isVariable ifTrue: [ ^ self newTenured: 0 ].
	OutOfMemory signal.
	^ self newTenured
]
