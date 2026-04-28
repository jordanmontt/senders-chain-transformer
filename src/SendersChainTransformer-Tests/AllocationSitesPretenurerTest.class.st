Class {
	#name : 'AllocationSitesPretenurerTest',
	#superclass : 'TestCase',
	#instVars : [
		'pretenurator'
	],
	#category : 'SendersChainTransformer-Tests-Tests',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Tests'
}

{ #category : 'running' }
AllocationSitesPretenurerTest >> setUp [

	super setUp.
	pretenurator := AllocationSitesPretenurer new.
]

{ #category : 'running' }
AllocationSitesPretenurerTest >> tearDown [

	pretenurator restoreOriginalState.

	super tearDown
]

{ #category : 'tests' }
AllocationSitesPretenurerTest >> testCompileOneCallerInNestedBlock [

    | initialCaller transformedCaller |
    initialCaller := IllMethodWithOffset
        method: (SCMockClassWithDumbMethods >> #availableProbes) literals fourth literals fourth compiledBlock
        offset: 37.

    pretenurator compilePretenuredPathsFrom: { { initialCaller } }.
    transformedCaller := pretenurator transformedCallSites first.

    self assert: (transformedCaller sourceCode includesSubstring: '_pretenured_').
    self assert: (transformedCaller sourceCode includesSubstring: '_fromHexString: colorString')
]

{ #category : 'tests' }
AllocationSitesPretenurerTest >> testCompileOneCallerInNestedBlockOneSender [

    | initialCaller senders transformedCaller transformedSender |
    initialCaller := IllMethodWithOffset
        method: (SCMockClassWithDumbMethods >> #availableProbes) literals fourth literals fourth compiledBlock
        offset: 37.
    senders := { (IllMethodWithOffset method: SCMockClassWithDumbMethods class >> #fromHexString: offset: 178) }.

    pretenurator compilePretenuredPathsFrom: { senders , { initialCaller } }.

    transformedCaller := pretenurator transformedCallSites first.
    transformedSender := pretenurator transformedSenders first.

    self assert: (transformedCaller sourceCode includesSubstring: '_pretenured_').
    self assert: (transformedCaller sourceCode includesSubstring: '_fromHexString: colorString').
    self deny: (transformedCaller selector includesSubstring: #pretenured).
    self assert:(transformedSender sourceCode includesSubstring: '_pretenured_').
    self assert:(transformedSender selector includesSubstring: '_pretenured_').
]

{ #category : 'tests' }
AllocationSitesPretenurerTest >> testTransformationsForTwoAllocationSitesInSameMethod [

    | transformedInitialCaller toPretenurePaths senders initialCaller initialCaller2 |
	initialCaller := IllMethodWithOffset method: (SCMockClassWithDumbMethods >> #addOccupant:) offset:  81.
	senders := {
		           (IllMethodWithOffset method: SCMockAssociation class >> #key:value: offset: 42).
		           (IllMethodWithOffset method: SCMockDictionary >> #at:put: offset: 82).
		           (IllMethodWithOffset method: (SCMockDictionary >> #at:ifAbsentPut:) literals first offset: 21).
		           (IllMethodWithOffset method: SCMockDictionary >> #at:ifAbsent: offset: 54).
		           (IllMethodWithOffset method: SCMockDictionary >> #at:ifAbsentPut: offset: 48) }.
	initialCaller2 := IllMethodWithOffset
		             method: (SCMockClassWithDumbMethods >> #addOccupant:) literals fourth compiledBlock
		             offset: 26.	
   toPretenurePaths := { (senders , { initialCaller }) . ({ } , { initialCaller2 }) }.

   pretenurator compilePretenuredPathsFrom: toPretenurePaths.

	transformedInitialCaller := pretenurator transformedCallSites first.
	self assert: (transformedInitialCaller sourceCode includesSubstring: 'OrderedCollection newTenured').
	self deny: (transformedInitialCaller sourceNodeForPC: 81) selector equals: #at:ifAbsentPut:
]

{ #category : 'tests' }
AllocationSitesPretenurerTest >> testTransformationsOneAllocationSitesSimpleBlock [

	| initialCaller transformedCaller |
	initialCaller := IllMethodWithOffset
	    method: (SCMockClassWithDumbMethods >> #addOccupant:) literals fourth compiledBlock
	    offset: 26.

	pretenurator compilePretenuredPathsFrom: { { initialCaller } }.
	transformedCaller := pretenurator transformedCallSites first.

	self assert: (transformedCaller sourceCode includesSubstring: 'OrderedCollection newTenured')
]
