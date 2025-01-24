Extension { #name : 'OrderedDictionary' }

{ #category : '*SendersChainTransformer' }
OrderedDictionary class >> newTenured [

	^ self newTenured: 10
]

{ #category : '*SendersChainTransformer' }
OrderedDictionary class >> newTenured: aCapacity [

	^ self basicNewTenured initialize: aCapacity
]
