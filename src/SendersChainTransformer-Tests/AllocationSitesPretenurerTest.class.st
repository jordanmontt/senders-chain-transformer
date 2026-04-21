Class {
	#name : 'AllocationSitesPretenurerTest',
	#superclass : 'TestCase',
	#instVars : [
		'pretenurator',
		'initialCaller',
		'senders',
		'initialCaller2',
		'senders2',
		'toPretenureAllocationSites'
	],
	#category : 'SendersChainTransformer-Tests-Tests',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Tests'
}

{ #category : 'running' }
AllocationSitesPretenurerTest >> setUp [

	| blockClosure |
	super setUp.

	pretenurator := AllocationSitesPretenurer new.

	initialCaller := IllMethodWithOffset
		                 method: (SCMockClassWithDumbMethods >> #addOccupant:)
		                 offset: (((SCMockClassWithDumbMethods >> #addOccupant:) symbolicBytecodes detect: [ :e | e description = 'send: at:ifAbsentPut:' ]) offset).
	senders := {
		           (IllMethodWithOffset method: SCMockAssociation class >> #key:value: offset: 42).
		           (IllMethodWithOffset method: SCMockDictionary >> #at:put: offset: 82).
		           (IllMethodWithOffset method: (SCMockDictionary >> #at:ifAbsentPut:) literals first offset: 21).
		           (IllMethodWithOffset method: SCMockDictionary >> #at:ifAbsent: offset: 54).
		           (IllMethodWithOffset method: SCMockDictionary >> #at:ifAbsentPut: offset: 48) }.

	blockClosure := (SCMockClassWithDumbMethods >> #addOccupant:) literals fourth.
	initialCaller2 := IllMethodWithOffset
		                  method: blockClosure compiledBlock
		                  offset: 26.
	senders2 := {  }.
	toPretenureAllocationSites := { (senders , { initialCaller }). (senders2 , { initialCaller2 }) }
]

{ #category : 'running' }
AllocationSitesPretenurerTest >> tearDown [

	pretenurator restoreOriginalState.

	super tearDown
]

{ #category : 'tests' }
AllocationSitesPretenurerTest >> testCompileAndInstallOneCallerInNestedBlock [

    initialCaller := IllMethodWithOffset
        method: (SCMockClassWithDumbMethods >> #availableProbes) literals fourth literals fourth
        offset: 37.

    self deny: ((SCMockClassWithDumbMethods >> #availableProbes) sourceCode includesSubstring: '_pretenured_').
    self deny: ((SCMockClassWithDumbMethods >> #availableProbes) sourceCode includesSubstring: '_fromHexString: colorString').
    self assert: ((SCMockClassWithDumbMethods >> #availableProbes) sourceCode includesSubstring: 'Color fromHexString: colorString').

    pretenurator
        compilePretenuredPathsFrom: { {  } , { initialCaller } };
        installPretenuredMethods.

    self assert: ((SCMockClassWithDumbMethods >> #availableProbes) sourceCode includesSubstring: '_pretenured_').
    self assert: ((SCMockClassWithDumbMethods >> #availableProbes) sourceCode includesSubstring: '_fromHexString: colorString')
]

{ #category : 'tests' }
AllocationSitesPretenurerTest >> testCompileAndInstallOneCallerInNestedBlockOneSender [

    initialCaller := IllMethodWithOffset
        method: (SCMockClassWithDumbMethods >> #availableProbes) literals fourth literals fourth
        offset: 37.
    senders := { (IllMethodWithOffset method: SCMockClassWithDumbMethods class >> #sendersFromHexString: offset: 178) }.

    self deny: ((SCMockClassWithDumbMethods >> #availableProbes) sourceCode includesSubstring: '_pretenured_').
    self deny: ((SCMockClassWithDumbMethods >> #availableProbes) sourceCode includesSubstring: '_fromHexString: colorString').
    self assert: ((SCMockClassWithDumbMethods >> #availableProbes) sourceCode includesSubstring: 'Color fromHexString: colorString').

    pretenurator
        compilePretenuredPathsFrom: { senders , { initialCaller } };
        installPretenuredMethods.

    self assert: ((SCMockClassWithDumbMethods >> #availableProbes) sourceCode includesSubstring: '_pretenured_').
    self assert: ((SCMockClassWithDumbMethods >> #availableProbes) sourceCode includesSubstring: '_fromHexString: colorString').
    self assert:
        ((SCMockClassWithDumbMethods class >> pretenurator pretenuredCompiledMethods first selector)
            sourceCode includesSubstring: '_pretenured_').
    self deny: ((SCMockClassWithDumbMethods class >> #sendersFromHexString:) sourceCode includesSubstring: '_pretenured_')
]

{ #category : 'tests' }
AllocationSitesPretenurerTest >> testTransformationsForTwoAllocationSitesInSameMethod [

	| transformedInitialCaller |
	transformedInitialCaller := SCMockClassWithDumbMethods >> #addOccupant:.
	self deny: (transformedInitialCaller sourceCode includesSubstring: 'OrderedCollection newTenured').
	self assert: (transformedInitialCaller sourceNodeForPC: initialCaller offset) selector equals: #at:ifAbsentPut:.

	pretenurator
		compilePretenuredPathsFrom: toPretenureAllocationSites;
		installPretenuredMethods.

	transformedInitialCaller := SCMockClassWithDumbMethods >> #addOccupant:.
	self assert: (transformedInitialCaller sourceCode includesSubstring: 'OrderedCollection newTenured').
	self deny: (transformedInitialCaller sourceNodeForPC: initialCaller offset) selector equals: #at:ifAbsentPut:
]

{ #category : 'tests' }
AllocationSitesPretenurerTest >> testTransformationsOneAllocationSitesSimpleBlock [

	| block |
	block := (SCMockClassWithDumbMethods >> #addOccupant:) literals fourth compiledBlock.
	initialCaller2 := IllMethodWithOffset
		                  method: block
		                  offset: 26.
	self deny: ((SCMockClassWithDumbMethods >> #addOccupant:) sourceCode includesSubstring: 'OrderedCollection newTenured').
	self assert: (block sourceNodeForPC: 26) selector equals: #new.
	self deny: (block sourceNodeForPC: 26) selector equals: #newTenured.

	pretenurator
		compilePretenuredPathsFrom: { {  } , { initialCaller2 } };
		installPretenuredMethods.

	block := (SCMockClassWithDumbMethods >> #addOccupant:) literals fourth compiledBlock.
	self assert: ((SCMockClassWithDumbMethods >> #addOccupant:) sourceCode includesSubstring: 'OrderedCollection newTenured').
	self deny: (block sourceNodeForPC: 34) selector equals: #new.
	self assert: (block sourceNodeForPC: 34) selector equals: #newTenured
]
