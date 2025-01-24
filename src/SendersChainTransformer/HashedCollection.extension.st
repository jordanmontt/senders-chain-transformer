Extension { #name : 'HashedCollection' }

{ #category : '*SendersChainTransformer' }
HashedCollection >> initializeTenured: n [

	array := Array newTenured: n.
	tally := 0
]

{ #category : '*SendersChainTransformer' }
HashedCollection class >> newTenured [

	^ self basicNewTenured
		  initializeTenured: 5;
		  yourself
]

{ #category : '*SendersChainTransformer' }
HashedCollection class >> newTenured: nElements [

	^ self basicNewTenured initializeTenured: (self sizeFor: nElements)
]
