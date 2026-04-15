Class {
	#name : 'AllocationSitesPretenurer',
	#superclass : 'Object',
	#instVars : [
		'transformedCallSites',
		'callSiteTransformers'
	],
	#category : 'SendersChainTransformer-Code-Rewriter',
	#package : 'SendersChainTransformer',
	#tag : 'Code-Rewriter'
}

{ #category : 'initialization' }
AllocationSitesPretenurer >> initialize [

	super initialize.
	callSiteTransformers := OrderedCollection new
]

{ #category : 'api' }
AllocationSitesPretenurer >> installPretenuredMethods [

    | installer |
    callSiteTransformers := callSiteTransformers reject: [ :e | e transformedSenders isNil ].
    self flag: 'should debug why something there are an extra callsitetransformer initialized.'.

    installer := callSiteTransformers anyOne.
    "First install the senders as they have unique selectors and nobody calls them"
    callSiteTransformers do: [ :codeTransformer |
            codeTransformer transformedSenders do: [ :aCompiledMethod |
                    ('Installing method ' , aCompiledMethod name) traceCr.
                    installer installMethod: aCompiledMethod ] ].
    "Then the call sites that they not have unique selectors "
    transformedCallSites do: [ :aCompiledMethod |
            ('Installing method ' , aCompiledMethod name) traceCr.
            installer installMethod: aCompiledMethod ]
]

{ #category : 'internals' }
AllocationSitesPretenurer >> mergeCallSites [
	 "It can happen that the same method was modified twice because it appeared in the senders stack twice with different bytecode offsets"

	transformedCallSites := callSiteTransformers collect: [ :codeTransformer | codeTransformer transformedCallSite ].
	transformedCallSites := transformedCallSites reject: #isNil.
	transformedCallSites := CodeTransformationsMerger new mergeTransformedCompiledMethods: transformedCallSites
]

{ #category : 'internals' }
AllocationSitesPretenurer >> pretenureAllocationCallSite: methodWithOffset senders: callStack [

	| sct |
	sct := CallSiteTransformer new.
	callSiteTransformers add: sct.
	sct backupSenders: callStack caller: methodWithOffset.
	sct transformCallSite: methodWithOffset senders: callStack
]

{ #category : 'api' }
AllocationSitesPretenurer >> pretenureAllocations: toPretenureCallSitesArray [

	toPretenureCallSitesArray do: [ :callStack |
		self pretenureAllocationCallSite: callStack last senders: callStack allButLast ].
	self mergeCallSites.
	self installPretenuredMethods
]

{ #category : 'api' }
AllocationSitesPretenurer >> restoreOriginalState [

	callSiteTransformers do: #restoreOriginalState
]
