Class {
	#name : 'CallSiteTransformer',
	#superclass : 'Object',
	#instVars : [
		'originalCaller',
		'originalSenders',
		'selectorMaker',
		'transformedSenders',
		'transformedCallSite'
	],
	#category : 'SendersChainTransformer-Core',
	#package : 'SendersChainTransformer',
	#tag : 'Core'
}

{ #category : 'backup' }
CallSiteTransformer >> backupSenders: senders caller: caller [
	"method method for blocks"

	originalCaller := caller method method copy.
	originalSenders := senders collect: [ :illSender | illSender method method copy ]
]

{ #category : 'method manipulation' }
CallSiteTransformer >> cloneCompiledCode: anIllSender [

	^ anIllSender method isCompiledBlock
		  ifTrue: [ "Do not copy blocks as it does not work"
		  		MethodWithOffset method: anIllSender method offset: anIllSender offset ]
		  ifFalse: [ MethodWithOffset method: anIllSender method copy offset: anIllSender offset ]
]

{ #category : 'initialization' }
CallSiteTransformer >> initialize [

	super initialize.
	selectorMaker := TenuredSelectorMaker new
]

{ #category : 'method manipulation' }
CallSiteTransformer >> installMethod: aCompiledMethod [

	aCompiledMethod methodClass methodDict at: aCompiledMethod selector put: aCompiledMethod
]

{ #category : 'method manipulation' }
CallSiteTransformer >> installTransformations [

	transformedSenders do: [ :aMethodWithOffset | self installMethod: aMethodWithOffset method ].
	self installMethod: transformedCallSite method
]

{ #category : 'method manipulation' }
CallSiteTransformer >> makeNewSelector: aByteSymbol [

	^ selectorMaker makeSelector: aByteSymbol
]

{ #category : 'method manipulation' }
CallSiteTransformer >> mergeTransformedSenders [
	"It can happen that the same method was modified twice because it appeared in the senders stack twice with different bytecode offsets"
	transformedSenders := CodeTransformationMerger new mergeTransformedCompiledMethods: transformedSenders.
	^ transformedSenders
]

{ #category : 'method manipulation' }
CallSiteTransformer >> renameSendersSelectors [

	transformedSenders do: [ :aCompiledMethod | aCompiledMethod selector: (self makeNewSelector: aCompiledMethod selector) ]
]

{ #category : 'backup' }
CallSiteTransformer >> restoreOriginalState [

	self installMethod: originalCaller.
	originalSenders do: [ :aCompiledMethod | self installMethod: aCompiledMethod ].
	originalSenders do: [ :aCompiledMethod |
		aCompiledMethod methodClass removeSelector: (self makeNewSelector: aCompiledMethod selector) ]
]

{ #category : 'accessing' }
CallSiteTransformer >> selectorMaker [

	^ selectorMaker
]

{ #category : 'api' }
CallSiteTransformer >> transformCallSite: initialCaller senders: senders [
	"the stack is top to bottom so we need to reverse it"

	transformedSenders := senders reversed collect: [ :aMethodWithOffset | 
			self transformMessageSend: (self cloneCompiledCode: aMethodWithOffset) ].
	transformedSenders := self mergeTransformedSenders.
	transformedCallSite := self transformMessageSend: initialCaller.
	self renameSendersSelectors.
	^ transformedSenders
]

{ #category : 'method manipulation' }
CallSiteTransformer >> transformMessageSend: methodWithOffset [

	| compiledMethodOrBlock offset messageNodeToTransform ast transformedCompiledMethod |
	compiledMethodOrBlock := methodWithOffset method.
	offset := methodWithOffset offset.
	ast := methodWithOffset parseTree.

	messageNodeToTransform := compiledMethodOrBlock isCompiledBlock
		ifTrue: [ (ast sourceNodeForPC: compiledMethodOrBlock pcInOuter) sourceNodeForPC: offset ]
		ifFalse: [ ast sourceNodeForPC: offset ].

	messageNodeToTransform selector: (self makeNewSelector: messageNodeToTransform selector).

	transformedCompiledMethod := ast methodNode generateIR generate.
	transformedCompiledMethod propertyAt: #source put: ast formattedCode.
	^ transformedCompiledMethod
]

{ #category : 'accessing' }
CallSiteTransformer >> transformedCallSite [

	^ transformedCallSite
]

{ #category : 'accessing' }
CallSiteTransformer >> transformedCallSite: anObject [

	transformedCallSite := anObject
]

{ #category : 'accessing' }
CallSiteTransformer >> transformedSenders [

	^ transformedSenders
]
