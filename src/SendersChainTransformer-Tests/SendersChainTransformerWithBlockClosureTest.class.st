Class {
	#name : 'SendersChainTransformerWithBlockClosureTest',
	#superclass : 'TestCase',
	#instVars : [
		'codeTransformer',
		'fixture'
	],
	#category : 'SendersChainTransformer-Tests-Tests',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Tests'
}

{ #category : 'running' }
SendersChainTransformerWithBlockClosureTest >> setUp [

	super setUp.

	fixture := SCFullBlockClosureFixture new.
	codeTransformer := SendersChainTransformer new.
	codeTransformer backupSenders: fixture senders caller: fixture initialCaller
]

{ #category : 'running' }
SendersChainTransformerWithBlockClosureTest >> tearDown [

	codeTransformer restoreOriginalState.

	super tearDown
]

{ #category : 'tests' }
SendersChainTransformerWithBlockClosureTest >> testTransformMessageSendOffsetWithBlock [

	| transformedMethod |
	transformedMethod := codeTransformer
		                     transformMessageSend: fixture initialCaller method
		                     offset: fixture initialCaller offset.
	self assert: (transformedMethod sourceCode includesSubstring: 'newTenured').
	self assert: (transformedMethod sourceCode includesSubstring: 'myVar').

	codeTransformer restoreOriginalState.
	self deny: ((SCMockWithBlockclosureClass >> #theMethod) sourceCode includesSubstring: 'newTenured')
]
