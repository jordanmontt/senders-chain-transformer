Extension { #name : 'OrderedDictionary' }

{ #category : '*SendersChainTransformer' }
OrderedDictionary >> initializeTenured: aCapacity [

	dictionary := self dictionaryClass newTenured: aCapacity.
	orderedKeys := Array newTenured: aCapacity
]

{ #category : '*SendersChainTransformer' }
OrderedDictionary class >> newTenured [

	^ self newTenured: 10
]

{ #category : '*SendersChainTransformer' }
OrderedDictionary class >> newTenured: aCapacity [

	^ self basicNewTenured initializeTenured: aCapacity
]
