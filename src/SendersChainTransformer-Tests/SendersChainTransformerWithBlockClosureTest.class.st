Class {
	#name : 'SendersChainTransformerWithBlockClosureTest',
	#superclass : 'TestCase',
	#instVars : [
		'codeTransformer',
		'initialCaller'
	],
	#category : 'SendersChainTransformer-Tests-Tests',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Tests'
}

{ #category : 'running' }
SendersChainTransformerWithBlockClosureTest >> setUp [

	super setUp.

	initialCaller := MethodWithOffset
		method: (SCMockClassWithDumbMethods >> #theMethodWithBlock) literals third "the desired block closure"
		offset: 37.

	codeTransformer := SendersChainTransformer new.
	codeTransformer backupSenders: {  } caller: initialCaller
]

{ #category : 'running' }
SendersChainTransformerWithBlockClosureTest >> tearDown [

	codeTransformer restoreOriginalState.

	super tearDown
]

{ #category : 'tests' }
SendersChainTransformerWithBlockClosureTest >> testTransformMessageSendOffsetWithBlock [

	| transformedMethod |
	transformedMethod := codeTransformer transformMessageSend: initialCaller.
	self assert: (transformedMethod sourceCode includesSubstring: 'newTenured').
	self assert: (transformedMethod sourceCode includesSubstring: 'myVar').

	codeTransformer restoreOriginalState.
	self deny: ((SCMockClassWithDumbMethods >> #theMethodWithBlock) sourceCode includesSubstring: 'newTenured')
]
