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
AllocationSitesPretenurerTest >> testCompileDoesNotGenerateStringNewTenured [

    | initialCaller transformedCaller senders |
    initialCaller := IllMethodWithOffset method: (SCMockClassWithDumbMethods >> #callsStringNew) offset: 43.
    senders := { IllMethodWithOffset method: (String class >> #new:) offset: 63 }.

    pretenurator compilePretenuredPathsFrom: { senders , { initialCaller } }.
    transformedCaller := pretenurator transformedCallSites first.

    self assert: transformedCaller ast body formattedCode equals: 'String newTenured: 10'.
    self assert: pretenurator transformedSenders isEmpty
]

{ #category : 'tests' }
AllocationSitesPretenurerTest >> testCompileOneCallerInNestedBlock [

    | initialCaller transformedCaller |
    initialCaller := IllMethodWithOffset
        method: (SCMockClassWithDumbMethods >> #availableProbes) literals fourth literals fourth compiledBlock
        offset: 37.

    pretenurator compilePretenuredPathsFrom: { { initialCaller } }.
    transformedCaller := pretenurator transformedCallSites first.

    self assert: (transformedCaller sourceCode includesSubstring: '_pretenured_fromHexString: colorString').
    self assert: transformedCaller selector equals: #availableProbes
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

    self assert: (transformedCaller sourceCode includesSubstring: '_pretenured_fromHexString: colorString').
    self assert: transformedCaller selector equals: #availableProbes.

    self assert: (transformedSender sourceCode includesSubstring: '_pretenured_fromHexString:').
    self assert: transformedSender selector equals: #_pretenured_fromHexString:.

    self assert: ((transformedSender sourceNodeForPC: 186) selector includesSubstring: #_pretenured_readFrom:base:)
]

{ #category : 'tests' }
AllocationSitesPretenurerTest >> testTransformationsOneAllocationSiteSimpleBlock [

	| initialCaller transformedCaller |
	initialCaller := IllMethodWithOffset
	    method: (SCMockClassWithDumbMethods >> #addOccupant:) literals fourth compiledBlock
	    offset: 26.

	pretenurator compilePretenuredPathsFrom: { { initialCaller } }.
	transformedCaller := pretenurator transformedCallSites first.

	self assert: (transformedCaller sourceCode includesSubstring: 'OrderedCollection newTenured').
	self assert: transformedCaller selector equals: #addOccupant:
]

{ #category : 'tests' }
AllocationSitesPretenurerTest >> testTransformationsOneAllocationSiteSimpleMethod [

	| initialCaller transformedCaller |
	initialCaller := IllMethodWithOffset
	    method: (SCMockClassWithDumbMethods >> #foo)
	    offset: 45.

	pretenurator compilePretenuredPathsFrom: { { initialCaller } }.
	transformedCaller := pretenurator transformedCallSites first.

	self assert: (transformedCaller sourceCode includesSubstring: 'anotherFakeClass _pretenured_bar').
	
	self assert: transformedCaller selector equals: #foo.
	
	self deny: (transformedCaller sourceNodeForPC: 45) selector equals: #bar.
	self assert: ((transformedCaller sourceNodeForPC: 45) selector includesSubstring: #_pretenured_bar)
]
