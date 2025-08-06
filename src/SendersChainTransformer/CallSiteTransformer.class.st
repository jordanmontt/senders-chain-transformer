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
	#category : 'SendersChainTransformer-Code-Rewriter',
	#package : 'SendersChainTransformer',
	#tag : 'Code-Rewriter'
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
		  		IllMethodWithOffset method: anIllSender method offset: anIllSender offset ]
		  ifFalse: [ IllMethodWithOffset method: anIllSender method copy offset: anIllSender offset ]
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
	transformedSenders := CodeTransformationsMerger new mergeTransformedCompiledMethods: transformedSenders.
	^ transformedSenders
]

{ #category : 'method manipulation' }
CallSiteTransformer >> removeAlreadyImplemented: senders [
	"These methods are already implemented as extension methods as they are methods that require special treatment. So we need to ignore them because we will transform incorrectly the method."
	| toBan |
	self class package extensionMethods do: [ :e | self assert: (e name includesSubstring: 'Tenured') ].

	toBan := (self class package extensionMethods collect: #name) 
			collect: [ :e | e copyReplaceAll: 'Tenured' with: '' ].
	^ senders reject: [ :aMethodWithOffset | toBan includes: aMethodWithOffset name ]
]

{ #category : 'method manipulation' }
CallSiteTransformer >> renameSendersSelectors [

	transformedSenders do: [ :aCompiledMethod | aCompiledMethod selector: (self makeNewSelector: aCompiledMethod selector) ]
]

{ #category : 'backup' }
CallSiteTransformer >> restoreOriginalState [

	self installMethod: originalCaller.
	originalSenders do: [ :aCompiledMethod | self installMethod: aCompiledMethod ].
	transformedSenders do: [ :aCompiledMethod | aCompiledMethod methodClass removeSelector: aCompiledMethod selector ]
]

{ #category : 'accessing' }
CallSiteTransformer >> selectorMaker [

	^ selectorMaker
]

{ #category : 'api' }
CallSiteTransformer >> transformCallSite: initialCaller senders: senders [

	(self removeAlreadyImplemented: { initialCaller })
		ifEmpty: [ ^ self "Method has been already implemented" ].

	transformedSenders := self removeAlreadyImplemented: senders.
	"the stack is top to bottom so we need to reverse it"
	transformedSenders := transformedSenders reversed collect: [ :aMethodWithOffset |
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
