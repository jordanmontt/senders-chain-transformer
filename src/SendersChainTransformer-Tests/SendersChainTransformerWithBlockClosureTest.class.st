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

	codeTransformer := CallSiteTransformer new
]

{ #category : 'tests' }
SendersChainTransformerWithBlockClosureTest >> testTransformMessageSendOffsetWithBlock [

	| transformedMethod |
	transformedMethod := codeTransformer transformMessageSend: initialCaller.
	
	self assert: (transformedMethod sourceCode includesSubstring: 'newTenured').
	self assert: (transformedMethod sourceCode includesSubstring: 'myVar').

	self deny: ((SCMockClassWithDumbMethods >> #theMethodWithBlock) sourceCode includesSubstring: 'newTenured')
]
