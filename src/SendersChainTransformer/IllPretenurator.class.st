Class {
	#name : 'IllPretenurator',
	#superclass : 'Object',
	#instVars : [
		'codeTransformers',
		'transformedInitialCallers'
	],
	#category : 'SendersChainTransformer',
	#package : 'SendersChainTransformer'
}

{ #category : 'initialization' }
IllPretenurator >> initialize [

	super initialize.
	codeTransformers := OrderedCollection new
]

{ #category : 'api' }
IllPretenurator >> installPretenuredMethods [

	| installer |
	installer := codeTransformers anyOne.
	transformedInitialCallers do: [ :aCompiledMethod | installer installMethod: aCompiledMethod ].
	codeTransformers do: [ :codeTransformer |
		codeTransformer transformedSenders do: [ :aCompiledMethod | 
			installer installMethod: aCompiledMethod ] ]
]

{ #category : 'internals' }
IllPretenurator >> mergeInitialCallers [
	 "It can happen that the same method was modified twice because it appeared in the senders stack twice with different bytecode offsets"

	transformedInitialCallers := codeTransformers collect: [ :codeTransformer | codeTransformer transformedInitialCaller ].
	transformedInitialCallers := CodeTransformationMerger new mergeCompiledMethods: transformedInitialCallers
]

{ #category : 'internals' }
IllPretenurator >> pretenureAllocationChainForInitialCaller: initialCaller senders: sendersToTransform [

	| sct |
	sct := SendersChainTransformer new.
	codeTransformers add: sct.
	sct backupSenders: sendersToTransform caller: initialCaller.
	sct transformCallingSenders: sendersToTransform initialCaller: initialCaller
]

{ #category : 'api' }
IllPretenurator >> pretenureAllocations: toPretenureSitesArray [


	toPretenureSitesArray do: [ :methodsWithOffsets |
		self pretenureAllocationChainForInitialCaller: methodsWithOffsets last senders: methodsWithOffsets allButLast ].
	self mergeInitialCallers
]

{ #category : 'api' }
IllPretenurator >> restoreOriginalState [

	codeTransformers do: #restoreOriginalState
]
