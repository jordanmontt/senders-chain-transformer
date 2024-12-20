Extension { #name : 'OrderedCollection' }

{ #category : '*SendersChainTransformer' }
OrderedCollection class >> newTenured [

	^ self newTenured: 10
]

{ #category : '*SendersChainTransformer' }
OrderedCollection class >> newTenured: anInteger [

	^ self basicNewTenured setCollection: (self arrayType newTenured: anInteger)
]
