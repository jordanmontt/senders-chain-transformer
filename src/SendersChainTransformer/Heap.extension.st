Extension { #name : 'Heap' }

{ #category : '*SendersChainTransformer' }
Heap class >> newTenured [

	^ self newTenured: 10
]

{ #category : '*SendersChainTransformer' }
Heap class >> newTenured: n [

	^ super newTenured setCollection: (Array newTenured: n)
]
