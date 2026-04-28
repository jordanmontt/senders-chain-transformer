Class {
	#name : 'AllocationSitesPretenurerTest',
	#superclass : 'TestCase',
	#instVars : [
		'pretenurator',
		'initialCaller',
		'senders',
		'initialCaller2'
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

	initialCaller := IllMethodWithOffset method: (SCMockClassWithDumbMethods >> #addOccupant:) offset:  81.
	senders := {
		           (IllMethodWithOffset method: SCMockAssociation class >> #key:value: offset: 42).
		           (IllMethodWithOffset method: SCMockDictionary >> #at:put: offset: 82).
		           (IllMethodWithOffset method: (SCMockDictionary >> #at:ifAbsentPut:) literals first offset: 21).
		           (IllMethodWithOffset method: SCMockDictionary >> #at:ifAbsent: offset: 54).
		           (IllMethodWithOffset method: SCMockDictionary >> #at:ifAbsentPut: offset: 48) }.

	blockClosure := (SCMockClassWithDumbMethods >> #addOccupant:) literals fourth.
	initialCaller2 := IllMethodWithOffset
		                  method: blockClosure compiledBlock
		                  offset: 26
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
        backupMethodsWithOffset: { initialCaller };
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
        backupMethodsWithOffset: senders , { initialCaller };
        compilePretenuredPathsFrom: { senders , { initialCaller } };
        installPretenuredMethods.

    self assert: ((SCMockClassWithDumbMethods >> #availableProbes) sourceCode includesSubstring: '_pretenured_').
    self assert: ((SCMockClassWithDumbMethods >> #availableProbes) sourceCode includesSubstring: '_fromHexString: colorString').
    self assert:
        ((SCMockClassWithDumbMethods class >> pretenurator fetchPretenuredCompiledMethods first selector)
            sourceCode includesSubstring: '_pretenured_').
    self deny: ((SCMockClassWithDumbMethods class >> #sendersFromHexString:) sourceCode includesSubstring: '_pretenured_')
]

{ #category : 'tests' }
AllocationSitesPretenurerTest >> testTransformationsForTwoAllocationSitesInSameMethod [

    | transformedInitialCaller toPretenurePaths |
    toPretenurePaths := { (senders , { initialCaller }) . ({ } , { initialCaller2 }) }.


    pretenurator
        backupMethodsWithOffset: senders , { initialCaller } , { initialCaller2 };
        compilePretenuredPathsFrom: toPretenurePaths;
        installPretenuredMethods.

	transformedInitialCaller := SCMockClassWithDumbMethods >> #addOccupant:.
	self assert: (transformedInitialCaller sourceCode includesSubstring: 'OrderedCollection newTenured').
	self deny: (transformedInitialCaller sourceNodeForPC: initialCaller offset) selector equals: #at:ifAbsentPut:
]

{ #category : 'tests' }
AllocationSitesPretenurerTest >> testTransformationsOneAllocationSitesSimpleBlock [

	| block |
	block := (SCMockClassWithDumbMethods >> #addOccupant:) literals fourth compiledBlock.
	initialCaller := IllMethodWithOffset method: block offset: 26.

	pretenurator
	   backupMethodsWithOffset: { initialCaller };
		compilePretenuredPathsFrom: { { initialCaller } };
		installPretenuredMethods.

	block := (SCMockClassWithDumbMethods >> #addOccupant:) literals fourth compiledBlock.
	self assert: ((SCMockClassWithDumbMethods >> #addOccupant:) sourceCode includesSubstring: 'OrderedCollection newTenured').
	self deny: (block sourceNodeForPC: 34) selector equals: #new.
	self assert: (block sourceNodeForPC: 34) selector equals: #newTenured
]
