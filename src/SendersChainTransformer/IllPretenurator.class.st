Class {
	#name : 'IllPretenurator',
	#superclass : 'Object',
	#instVars : [
		'transformedCallSites',
		'callSiteTransformer'
	],
	#category : 'SendersChainTransformer',
	#package : 'SendersChainTransformer'
}

{ #category : 'initialization' }
IllPretenurator >> initialize [

	super initialize.
	callSiteTransformer := OrderedCollection new
]

{ #category : 'api' }
IllPretenurator >> installPretenuredMethods [

	| installer |
	installer := callSiteTransformer anyOne.
	transformedCallSites do: [ :aCompiledMethod | installer installMethod: aCompiledMethod ].
	callSiteTransformer do: [ :codeTransformer |
		codeTransformer transformedSenders do: [ :aCompiledMethod | 
			installer installMethod: aCompiledMethod ] ]
]

{ #category : 'internals' }
IllPretenurator >> mergeCallSites [
	 "It can happen that the same method was modified twice because it appeared in the senders stack twice with different bytecode offsets"

	transformedCallSites := callSiteTransformer collect: [ :codeTransformer | codeTransformer transformedInitialCaller ].
	transformedCallSites := CodeTransformationMerger new mergeTransformedCompiledMethods: transformedCallSites
]

{ #category : 'internals' }
IllPretenurator >> pretenureAllocationCallSiter: allocationCallSite senders: sendersToTransform [

	| sct |
	sct := CallSiteTransformer new.
	callSiteTransformer add: sct.
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

	callSiteTransformer do: #restoreOriginalState
]
