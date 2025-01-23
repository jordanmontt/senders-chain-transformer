Class {
	#name : 'SendersChainTransformerTwoAllocationSitesSameMethodTest',
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
SendersChainTransformerTwoAllocationSitesSameMethodTest >> setUp [

	super setUp.

	pretenurator := IllPretenurator new.

	initialCaller := MethodWithOffset
		                 method: SCMockClassWithDumbMethods >> #addOccupant:
		                 offset: 81.
	senders := {
		           (MethodWithOffset method: Association class >> #key:value: offset: 42).
		           (MethodWithOffset method: Dictionary >> #at:put: offset: 82).
		           (MethodWithOffset method: (Dictionary >> #at:ifAbsentPut:) literals first offset: 21).
		           (MethodWithOffset method: Dictionary >> #at:ifAbsent: offset: 54).
		           (MethodWithOffset method: Dictionary >> #at:ifAbsentPut: offset: 48) }.

	initialCaller2 := MethodWithOffset
		                  method: (SCMockClassWithDumbMethods >> #addOccupant: literalsAt: 4)
		                  offset: 26.
	senders2 := {  }.
	toPretenureAllocationSites := { (senders , { initialCaller }). (senders2 , { initialCaller2 }) }
]

{ #category : 'running' }
SendersChainTransformerTwoAllocationSitesSameMethodTest >> tearDown [

	pretenurator restoreOriginalState.

	super tearDown
]

{ #category : 'tests' }
SendersChainTransformerTwoAllocationSitesSameMethodTest >> testTransformationsForTwoAllocationSitesInSameMethod [

	| transformedInitialCaller |
	transformedInitialCaller := SCMockClassWithDumbMethods >> #addOccupant:.
	self deny: (transformedInitialCaller sourceCode includesSubstring: 'OrderedCollection newTenured').
	self assert: (transformedInitialCaller sourceNodeForPC: initialCaller offset) selector equals: #at:ifAbsentPut:.

	pretenurator
		pretenureAllocations: toPretenureAllocationSites;
		installPretenuredMethods.

	transformedInitialCaller := SCMockClassWithDumbMethods >> #addOccupant:.
	self assert: (transformedInitialCaller sourceCode includesSubstring: 'OrderedCollection newTenured').
	self deny: (transformedInitialCaller sourceNodeForPC: initialCaller offset) selector equals: #at:ifAbsentPut:
]
