Class {
	#name : 'CallSiteTransformerTransformMessageSendTest',
	#superclass : 'TestCase',
	#instVars : [
		'codeTransformer',
		'methodWithOffsetToTransform'
	],
	#category : 'SendersChainTransformer-Tests-Tests',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Tests'
}

{ #category : 'running' }
CallSiteTransformerTransformMessageSendTest >> setUp [

    super setUp.

    codeTransformer := CallSiteTransformer new
]

{ #category : 'tests' }
CallSiteTransformerTransformMessageSendTest >> testTransformMessageSend [

	| tenuredCompiledMethod symbolicMessageSendBytecode expectedSelector |
	methodWithOffsetToTransform :=  IllMethodWithOffset method: SCMockDictionary >> #at:put: offset: 82.
	expectedSelector := codeTransformer makeNewSelectorForSelector: (methodWithOffsetToTransform method sourceNodeForPC: methodWithOffsetToTransform offset) selector.

	self
		shouldnt: [ methodWithOffsetToTransform method valueWithReceiver: methodWithOffsetToTransform methodClass new arguments: #( #key #value ) ]
		raise: PrimitiveFailed.

	tenuredCompiledMethod := codeTransformer transformMessageSend: methodWithOffsetToTransform.

	symbolicMessageSendBytecode := tenuredCompiledMethod symbolicBytecodes detect: [ :e |
		                               e bytes includes: methodWithOffsetToTransform bytecode ].
	self assert: symbolicMessageSendBytecode description equals: 'send: ' , expectedSelector.
	"Method's selector remaine unchanged"
	self assert: tenuredCompiledMethod selector equals: methodWithOffsetToTransform selector.
	"We pretenure one message send to a method that does not exists"
	self
		should: [ tenuredCompiledMethod valueWithReceiver: methodWithOffsetToTransform methodClass new arguments: #( #key #value ) ]
		raise: MessageNotUnderstood
]

{ #category : 'tests' }
CallSiteTransformerTransformMessageSendTest >> testTransformMessageSendBasicNewTenuredDoesNotChange [

	| transformedMethod |
	methodWithOffsetToTransform := IllMethodWithOffset
		method: (SCMockClassWithDumbMethods class >> #newTenured)
		offset: 42.

	transformedMethod := codeTransformer transformMessageSend: methodWithOffsetToTransform.

	self deny: (transformedMethod sourceCode includesSubstring: '_pretenured_').
	self deny: ((SCMockClassWithDumbMethods class >> #newTenured) sourceCode includesSubstring: '_pretenured_').
	self assert: (transformedMethod sourceNodeForPC: 42) selector equals: #basicNewTenured
]

{ #category : 'tests' }
CallSiteTransformerTransformMessageSendTest >> testTransformMessageSendNewTenuredDoesNotChange [

	| transformedMethod |
	methodWithOffsetToTransform := IllMethodWithOffset
		method: (SCMockClassWithDumbMethods class >> #createTenured)
		offset: 34.

	transformedMethod := codeTransformer transformMessageSend: methodWithOffsetToTransform.

	self deny: (transformedMethod sourceCode includesSubstring: '_pretenured_').
	self deny: ((SCMockClassWithDumbMethods class >> #createTenured) sourceCode includesSubstring: '_pretenured_').
	self assert: (transformedMethod sourceNodeForPC: 34) selector equals: #newTenured
]

{ #category : 'tests' }
CallSiteTransformerTransformMessageSendTest >> testTransformMessageSendOffsetWithBlock [

	| transformedMethod |
	methodWithOffsetToTransform := IllMethodWithOffset
		method: (SCMockClassWithDumbMethods >> #theMethodWithBlock) literals third compiledBlock
		offset: 37.

	transformedMethod := codeTransformer transformMessageSend: methodWithOffsetToTransform.
	
	self assert: (transformedMethod sourceCode includesSubstring: 'newTenured').
	self assert: (transformedMethod sourceCode includesSubstring: 'myVar').

	self deny: ((SCMockClassWithDumbMethods >> #theMethodWithBlock) sourceCode includesSubstring: 'newTenured')
]

{ #category : 'tests' }
CallSiteTransformerTransformMessageSendTest >> testTransformMessageSendOffsetWithNestedBlock [

	| transformedMethod |
	methodWithOffsetToTransform := IllMethodWithOffset
		method: (SCMockClassWithDumbMethods >> #availableProbes) literals fourth literals fourth
		offset: 37.

	transformedMethod := codeTransformer transformMessageSend: methodWithOffsetToTransform.

	self assert: (transformedMethod sourceCode includesSubstring: '_pretenured_').
	self deny: ((SCMockClassWithDumbMethods >> #availableProbes) sourceCode includesSubstring: '_pretenured_')
]

{ #category : 'tests' }
CallSiteTransformerTransformMessageSendTest >> testTransformMessageSendWithBinarySelector [

	| tenuredCompiledMethod expectedMethodsAST |
	methodWithOffsetToTransform := IllMethodWithOffset
			method: SCMockClassWithDumbMethods >> #binaryMethod
			offset: 44.
	expectedMethodsAST:= RBParser parseMethod: 'binaryMethod

	self foo: (self ', (codeTransformer selectorMaker makeSelectorForSelector: #',,') ,' 1) andBar: 0'.

	tenuredCompiledMethod := codeTransformer transformMessageSend: methodWithOffsetToTransform.

	self assert: tenuredCompiledMethod parseTree equals: expectedMethodsAST
]
