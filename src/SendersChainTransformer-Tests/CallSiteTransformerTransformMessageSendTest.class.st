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

	| tenuredCompiledMethod expectedSelector |
	methodWithOffsetToTransform :=  IllMethodWithOffset method: SCMockDictionary >> #at:put: offset: 82.
	expectedSelector := codeTransformer makeNewSelectorForSelector: #key:value:.

	tenuredCompiledMethod := codeTransformer transformMessageSend: methodWithOffsetToTransform.

	self assert: (tenuredCompiledMethod sourceNodeForPC: 82) selector equals: expectedSelector.
	self deny: (tenuredCompiledMethod sourceNodeForPC: 82) selector equals: #key:value:.

	self assert: tenuredCompiledMethod selector equals: #at:put:.

	self assert: (tenuredCompiledMethod sourceCode includesSubstring: 'SCMockAssociation _pretenured_').
	self deny: (tenuredCompiledMethod sourceCode includesSubstring: 'key:value:')
]

{ #category : 'tests' }
CallSiteTransformerTransformMessageSendTest >> testTransformMessageSendBasicNewTenuredDoesNotChange [

	| transformedMethod |
	methodWithOffsetToTransform := IllMethodWithOffset
		method: (SCMockClassWithDumbMethods class >> #newTenured)
		offset: 42.

	transformedMethod := codeTransformer transformMessageSend: methodWithOffsetToTransform.

	"Check the selector was not changed (basicNewTenured is a pre-tenuring method)"
	self assert: (transformedMethod sourceNodeForPC: 42) selector equals: #basicNewTenured.
	self deny: (transformedMethod sourceCode includesSubstring: '_pretenured_')
]

{ #category : 'tests' }
CallSiteTransformerTransformMessageSendTest >> testTransformMessageSendNewTenuredDoesNotChange [

	| transformedMethod |
	methodWithOffsetToTransform := IllMethodWithOffset
		method: (SCMockClassWithDumbMethods class >> #createTenured)
		offset: 34.

	transformedMethod := codeTransformer transformMessageSend: methodWithOffsetToTransform.

	"Check the selector was not changed (newTenured is a pre-tenuring method)"
	self assert: (transformedMethod sourceNodeForPC: 34) selector equals: #newTenured.
	self deny: (transformedMethod sourceCode includesSubstring: '_pretenured_')
]

{ #category : 'tests' }
CallSiteTransformerTransformMessageSendTest >> testTransformMessageSendOffsetWithBlock [

	| transformedMethod block |
	methodWithOffsetToTransform := IllMethodWithOffset
		method: (SCMockClassWithDumbMethods >> #theMethodWithBlock) literals third compiledBlock
		offset: 37.

	transformedMethod := codeTransformer transformMessageSend: methodWithOffsetToTransform.
	
	self assert: (transformedMethod sourceCode includesSubstring: 'SCMockClassWithDumbMethods newTenured').
	self assert: (transformedMethod sourceCode includesSubstring: 'Object new').
	self deny: (transformedMethod sourceCode includesSubstring: 'Object newTenured').

	block := transformedMethod literals third compiledBlock.
	self assert: (block sourceNodeForPC: 45) selector equals: #newTenured.
	self assert: (block sourceNodeForPC: 42) selector equals: #new
]

{ #category : 'tests' }
CallSiteTransformerTransformMessageSendTest >> testTransformMessageSendOffsetWithNestedBlock [

	| transformedMethod block expectedSelector |
	methodWithOffsetToTransform := IllMethodWithOffset
		method: (SCMockClassWithDumbMethods >> #availableProbes) literals fourth literals fourth compiledBlock
		offset: 37.
	expectedSelector := codeTransformer makeNewSelectorForSelector: #fromHexString:.

	transformedMethod := codeTransformer transformMessageSend: methodWithOffsetToTransform.

	self assert: (transformedMethod sourceCode includesSubstring: '_pretenured_').
	self deny: (transformedMethod sourceCode includesSubstring: 'Color fromHexString: colorString').

	block := transformedMethod literals fourth literals fourth compiledBlock.
	self assert: (block sourceNodeForPC: 37) selector equals: expectedSelector
]

{ #category : 'tests' }
CallSiteTransformerTransformMessageSendTest >> testTransformMessageSendWithBinarySelector [

	| tenuredCompiledMethod expectedSelector |
	methodWithOffsetToTransform := IllMethodWithOffset
			method: SCMockClassWithDumbMethods >> #binaryMethod
			offset: 44.
	expectedSelector := codeTransformer selectorMaker makeSelectorForSelector: #',,'.

	tenuredCompiledMethod := codeTransformer transformMessageSend: methodWithOffsetToTransform.

	self assert: (tenuredCompiledMethod sourceNodeForPC: 44) selector equals: expectedSelector.

	self assert: (tenuredCompiledMethod sourceCode includesSubstring: expectedSelector).
	self deny: (tenuredCompiledMethod sourceCode includesSubstring: ',,')
]
