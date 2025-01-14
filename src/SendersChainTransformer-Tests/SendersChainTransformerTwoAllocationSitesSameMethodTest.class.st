Class {
	#name : 'SendersChainTransformerTwoAllocationSitesSameMethodTest',
	#superclass : 'TestCase',
	#instVars : [
		'fixture',
		'codeTransformer2',
		'codeTransformer1'
	],
	#category : 'SendersChainTransformer-Tests-Tests',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Tests'
}

{ #category : 'running' }
SendersChainTransformerTwoAllocationSitesSameMethodTest >> setUp [

	super setUp.

	fixture := SCTwoAllocationSitesInSameMethodFixture new.
	codeTransformer1 := SendersChainTransformer new.
	codeTransformer2 := SendersChainTransformer new.

	codeTransformer1 backupSenders: fixture senders caller: fixture initialCaller.
	codeTransformer2 backupSenders: fixture senders2 caller: fixture initialCaller2
]

{ #category : 'running' }
SendersChainTransformerTwoAllocationSitesSameMethodTest >> tearDown [

	codeTransformer1 restoreOriginalState.
	codeTransformer2 restoreOriginalState.

	super tearDown
]

{ #category : 'tests' }
SendersChainTransformerTwoAllocationSitesSameMethodTest >> testTransformationsForTwoAllocationSitesInSameMethod [

	| transformedInitialCaller |
	transformedInitialCaller := SCTransformationsForTwoAllocationSitesInSameMethodMock >> #addOccupant:.
	self deny: (transformedInitialCaller sourceCode includesSubstring: 'OrderedCollection newTenured').
	self assert: (transformedInitialCaller sourceNodeForPC: fixture initialCaller offset) selector equals: #at:ifAbsentPut:.

	codeTransformer1 transformCallingSenders: fixture senders initialCaller: fixture initialCaller.
	codeTransformer2 transformCallingSenders: fixture senders2 initialCaller: fixture initialCaller2.

	transformedInitialCaller := SCTransformationsForTwoAllocationSitesInSameMethodMock >> #addOccupant:.
	self assert: (transformedInitialCaller sourceCode includesSubstring: 'OrderedCollection newTenured').
	self deny: (transformedInitialCaller sourceNodeForPC: fixture initialCaller offset) selector equals: #at:ifAbsentPut:
]
