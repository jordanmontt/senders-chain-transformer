Class {
	#name : 'SendersChainTransformerTwoAllocationSitesSameMethodTest',
	#superclass : 'TestCase',
	#instVars : [
		'fixture',
		'pretenurator'
	],
	#category : 'SendersChainTransformer-Tests-Tests',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Tests'
}

{ #category : 'running' }
SendersChainTransformerTwoAllocationSitesSameMethodTest >> setUp [

	super setUp.

	fixture := SCTwoAllocationSitesInSameMethodFixture new.
	pretenurator := IllPretenurator new
]

{ #category : 'running' }
SendersChainTransformerTwoAllocationSitesSameMethodTest >> tearDown [

	pretenurator restoreOriginalState.

	super tearDown
]

{ #category : 'tests' }
SendersChainTransformerTwoAllocationSitesSameMethodTest >> testTransformationsForTwoAllocationSitesInSameMethod [

	| transformedInitialCaller |
	transformedInitialCaller := SCTransformationsForTwoAllocationSitesInSameMethodMock >> #addOccupant:.
	self deny: (transformedInitialCaller sourceCode includesSubstring: 'OrderedCollection newTenured').
	self assert: (transformedInitialCaller sourceNodeForPC: fixture initialCaller offset) selector equals: #at:ifAbsentPut:.

	pretenurator pretenureAllocations: fixture toPretenureAllocationSites.

	transformedInitialCaller := SCTransformationsForTwoAllocationSitesInSameMethodMock >> #addOccupant:.
	self assert: (transformedInitialCaller sourceCode includesSubstring: 'OrderedCollection newTenured').
	self deny: (transformedInitialCaller sourceNodeForPC: fixture initialCaller offset) selector equals: #at:ifAbsentPut:
]
