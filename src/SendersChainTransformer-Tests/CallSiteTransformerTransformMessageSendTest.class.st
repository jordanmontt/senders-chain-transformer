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

	| tenuredCompiledMethod expectedSelector expectedSourceCodeLine |
	methodWithOffsetToTransform :=  IllMethodWithOffset method: SCMockDictionary >> #at:put: offset: 82.
	expectedSelector := codeTransformer makeNewSelectorForSelector: #key:value:.

	tenuredCompiledMethod := codeTransformer transformMessageSend: methodWithOffsetToTransform.

	"Check the selector was changed at the correct PC"
	self assert: (tenuredCompiledMethod sourceNodeForPC: 82) selector equals: expectedSelector.
	self deny: (tenuredCompiledMethod sourceNodeForPC: 82) selector equals: #key:value:.

	"Check the method-level selector was not changed"
	self assert: tenuredCompiledMethod selector equals: #at:put:.

	"Check the source code reflects the transformed selector"
	expectedSourceCodeLine := expectedSelector asString, ' value'.
	self assert: (tenuredCompiledMethod sourceCode includesSubstring: expectedSelector asString).
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

	"Check the source code was not modified with pretenuring markers"
	self deny: (transformedMethod sourceCode includesSubstring: '_pretenured_').
	self deny: ((SCMockClassWithDumbMethods class >> #newTenured) sourceCode includesSubstring: '_pretenured_')
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

	"Check the source code was not modified with pretenuring markers"
	self deny: (transformedMethod sourceCode includesSubstring: '_pretenured_').
	self deny: ((SCMockClassWithDumbMethods class >> #createTenured) sourceCode includesSubstring: '_pretenured_')
]

{ #category : 'tests' }
CallSiteTransformerTransformMessageSendTest >> testTransformMessageSendOffsetWithBlock [

	| transformedMethod |
	methodWithOffsetToTransform := IllMethodWithOffset
		method: (SCMockClassWithDumbMethods >> #theMethodWithBlock) literals third compiledBlock
		offset: 37.

	transformedMethod := codeTransformer transformMessageSend: methodWithOffsetToTransform.
	
	"Check the source code reflects the correct receiver transformations"
	self assert: (transformedMethod sourceCode includesSubstring: 'SCMockClassWithDumbMethods newTenured').
	self assert: (transformedMethod sourceCode includesSubstring: 'Object new').
	self deny: (transformedMethod sourceCode includesSubstring: 'Object newTenured').

	"Check the selectors at the correct PC were transformed"
	self assert: (transformedMethod sourceNodeForPC: 37) selector equals: #basicNewTenured.
	self deny: (transformedMethod sourceNodeForPC: 37) selector equals: #newTenured
]

{ #category : 'tests' }
CallSiteTransformerTransformMessageSendTest >> testTransformMessageSendOffsetWithNestedBlock [

	| transformedMethod |
	methodWithOffsetToTransform := IllMethodWithOffset
		method: (SCMockClassWithDumbMethods >> #availableProbes) literals fourth literals fourth
		offset: 37.

	transformedMethod := codeTransformer transformMessageSend: methodWithOffsetToTransform.

	"Check the source code reflects the pretenuring transformation"
	self assert: (transformedMethod sourceCode includesSubstring: '_pretenured_').
	self deny: (transformedMethod sourceCode includesSubstring: 'Color fromHexString: colorString').

	"Check the selector at the correct PC was transformed"
	self assert: ((transformedMethod sourceNodeForPC: 37) selector asString includesSubstring: '_pretenured_')
]

{ #category : 'tests' }
CallSiteTransformerTransformMessageSendTest >> testTransformMessageSendWithBinarySelector [

	| tenuredCompiledMethod expectedSelector |
	methodWithOffsetToTransform := IllMethodWithOffset
			method: SCMockClassWithDumbMethods >> #binaryMethod
			offset: 44.
	expectedSelector := codeTransformer selectorMaker makeSelectorForSelector: #',,'.

	tenuredCompiledMethod := codeTransformer transformMessageSend: methodWithOffsetToTransform.

	"Check the selector was changed at the correct PC"
	self assert: (tenuredCompiledMethod sourceNodeForPC: 44) selector equals: expectedSelector.
	self deny: (tenuredCompiledMethod sourceNodeForPC: 44) selector equals: #',,'.

	"Check the source code reflects the transformed selector"
	self assert: (tenuredCompiledMethod sourceCode includesSubstring: expectedSelector asString).
	self deny: (tenuredCompiledMethod sourceCode includesSubstring: ',,')
]
