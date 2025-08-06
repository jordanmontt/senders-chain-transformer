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

	"The compiledBlock is necessary since in the newest versions of Pharo they added clean blocks. And clean blocks do not allocate the closure at run time.
	They put the closure in the literal frame "
	
	initialCaller := IllMethodWithOffset
		method: (SCMockClassWithDumbMethods >> #theMethodWithBlock) literals third compiledBlock
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
