Class {
	#name : 'SendersChainTransformer',
	#superclass : 'Object',
	#instVars : [
		'originalCaller',
		'originalSenders',
		'selectorMaker',
		'transformedSenders',
		'transformedInitialCaller'
	],
	#category : 'SendersChainTransformer-Core',
	#package : 'SendersChainTransformer',
	#tag : 'Core'
}

{ #category : 'backup' }
SendersChainTransformer >> backupSenders: senders caller: caller [
	"method method for blocks"

	originalCaller := caller method method copy.
	originalSenders := senders collect: [ :illSender | illSender method method copy ]
]

{ #category : 'method manipulation' }
SendersChainTransformer >> cloneCompiledCode: anIllSender [

	^ anIllSender method isCompiledBlock
		  ifTrue: [  anIllSender method ]
		  ifFalse: [ anIllSender method copy ]
]

{ #category : 'initialization' }
SendersChainTransformer >> initialize [

	super initialize.
	selectorMaker := TenuredSelectorMaker new
]

{ #category : 'method manipulation' }
SendersChainTransformer >> installMethod: aCompiledMethod [

	aCompiledMethod methodClass methodDict at: aCompiledMethod selector put: aCompiledMethod
]

{ #category : 'method manipulation' }
SendersChainTransformer >> installTransformations [

	transformedSenders do: [ :aCompiledMethod | self installMethod: aCompiledMethod ].
	self installMethod: transformedInitialCaller
]

{ #category : 'method manipulation' }
SendersChainTransformer >> makeNewSelector: aByteSymbol [

	^ selectorMaker makeSelector: aByteSymbol
]

{ #category : 'method manipulation' }
SendersChainTransformer >> mergeTransformedSenders [
	"It can happen that the same method was modified twice because it appeared in the senders stack twice with different bytecode offsets"
	transformedSenders := CodeTransformationMerger new mergeCompiledMethods: transformedSenders.
	^ transformedSenders
]

{ #category : 'method manipulation' }
SendersChainTransformer >> renameSendersSelectors [

	transformedSenders do: [ :aCompiledMethod | aCompiledMethod selector: (self makeNewSelector: aCompiledMethod selector) ]
]

{ #category : 'backup' }
SendersChainTransformer >> restoreOriginalState [

	self installMethod: originalCaller.
	originalSenders do: [ :aCompiledMethod | self installMethod: aCompiledMethod ].
	originalSenders do: [ :aCompiledMethod |
		aCompiledMethod methodClass removeSelector: (self makeNewSelector: aCompiledMethod selector) ]
]

{ #category : 'api' }
SendersChainTransformer >> transformCallingSenders: senders initialCaller: initialCaller [
	"the stack is top to bottom so we need to reverse it"

	transformedSenders := senders reversed collect: [ :anIllSender |
		                      self transformMessageSend: (self cloneCompiledCode: anIllSender) offset: anIllSender offset ].
	transformedSenders := self mergeTransformedSenders.
	transformedInitialCaller := self transformMessageSend: initialCaller method offset: initialCaller offset.
	
	self renameSendersSelectors.
	^ transformedSenders
]

{ #category : 'method manipulation' }
SendersChainTransformer >> transformMessageSend: compiledMethodOrBlock offset: offset [

	| messageNodeToTransform ast transformedCompiledMethod |
	compiledMethodOrBlock isCompiledBlock
		ifTrue: [
			ast := compiledMethodOrBlock method parseTree.
			messageNodeToTransform := (ast sourceNodeForPC: compiledMethodOrBlock pcInOuter) sourceNodeForPC: offset ]
		ifFalse: [
			ast := compiledMethodOrBlock parseTree.
			messageNodeToTransform := ast sourceNodeForPC: offset ].

	messageNodeToTransform selector: (self makeNewSelector: messageNodeToTransform selector).

	transformedCompiledMethod := ast methodNode generateIR generate.
	transformedCompiledMethod propertyAt: #source put: ast formattedCode.
	^ transformedCompiledMethod
]

{ #category : 'accessing' }
SendersChainTransformer >> transformedInitialCaller [

	^ transformedInitialCaller
]

{ #category : 'accessing' }
SendersChainTransformer >> transformedSenders [

	^ transformedSenders
]

{ #category : 'accessing' }
SendersChainTransformer >> transformedSendersChain [

	^ ({ transformedInitialCaller } , transformedSenders) reversed
]
