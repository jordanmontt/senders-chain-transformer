Extension { #name : 'Bag' }

{ #category : '*SendersChainTransformer' }
Bag class >> newTenured [

	^ self newTenured: 4
]

{ #category : '*SendersChainTransformer' }
Bag class >> newTenured: nElements [

	^ super newTenured setContents: (self contentsClass newTenured: nElements)
]
