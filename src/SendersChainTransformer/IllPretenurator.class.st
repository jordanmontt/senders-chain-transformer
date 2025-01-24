Class {
	#name : 'IllPretenurator',
	#superclass : 'Object',
	#instVars : [
		'transformedCallSites',
		'callSiteTransformers'
	],
	#category : 'SendersChainTransformer-Core',
	#package : 'SendersChainTransformer',
	#tag : 'Core'
}

{ #category : 'initialization' }
IllPretenurator >> initialize [

	super initialize.
	callSiteTransformers := OrderedCollection new
]

{ #category : 'api' }
IllPretenurator >> installPretenuredMethods [

	| installer |
	installer := callSiteTransformers anyOne.
	transformedCallSites do: [ :aCompiledMethod | installer installMethod: aCompiledMethod ].
	callSiteTransformers do: [ :codeTransformer |
		codeTransformer transformedSenders do: [ :aCompiledMethod | 
			installer installMethod: aCompiledMethod ] ]
]

{ #category : 'internals' }
IllPretenurator >> mergeCallSites [
	 "It can happen that the same method was modified twice because it appeared in the senders stack twice with different bytecode offsets"

	transformedCallSites := callSiteTransformers collect: [ :codeTransformer | codeTransformer transformedCallSite ].
	transformedCallSites := CodeTransformationMerger new mergeTransformedCompiledMethods: transformedCallSites
]

{ #category : 'internals' }
IllPretenurator >> pretenureAllocationCallSiter: allocationCallSite senders: sendersToTransform [

	| sct |
	sct := CallSiteTransformer new.
	callSiteTransformers add: sct.
	sct backupSenders: sendersToTransform caller: allocationCallSite.
	sct transformCallSite: allocationCallSite senders: sendersToTransform
]

{ #category : 'api' }
IllPretenurator >> pretenureAllocations: toPretenureCallSitesArray [

	toPretenureCallSitesArray do: [ :methodsWithOffsets |
		self pretenureAllocationCallSiter: methodsWithOffsets last senders: methodsWithOffsets allButLast ].
	self mergeCallSites
]

{ #category : 'api' }
IllPretenurator >> restoreOriginalState [

	callSiteTransformers do: #restoreOriginalState
]
