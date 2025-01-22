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
		  ifTrue: [ "Do not copy blocks as it does not work"
		  		MethodWithOffset method: anIllSender method offset: anIllSender offset ]
		  ifFalse: [ MethodWithOffset method: anIllSender method copy offset: anIllSender offset ]
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

	transformedSenders do: [ :aMethodWithOffset | self installMethod: aMethodWithOffset method ].
	self installMethod: transformedInitialCaller method
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

{ #category : 'instance creation' }
SendersChainTransformer >> newMergeCompiledMethods: aListOfMethodsWithOffset into: aCompiledMethod [

	| astToTransform mergedCompiledMethod |
	astToTransform := aCompiledMethod parseTree.
	aListOfMethodsWithOffset do: [ :aMethodWithOffset |
		(astToTransform allChildren select: #isMessage)
			with: (aMethodWithOffset method parseTree allChildren select: #isMessage)
			do: [ :nodeToTransform :nodeWithChanges |
				(nodeWithChanges selector includesSubstring: 'tenured' caseSensitive: false) ifTrue: [
					nodeToTransform selector: nodeWithChanges selector ] ] ].
	mergedCompiledMethod := astToTransform methodNode generateIR generate.
	mergedCompiledMethod propertyAt: #source put: astToTransform formattedCode.
	^ mergedCompiledMethod
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

{ #category : 'accessing' }
SendersChainTransformer >> selectorMaker [

	^ selectorMaker
]

{ #category : 'api' }
SendersChainTransformer >> transformCallingSenders: senders initialCaller: initialCaller [
	"the stack is top to bottom so we need to reverse it"

	transformedSenders := senders reversed collect: [ :aMethodWithOffset | self transformMessageSend: (self cloneCompiledCode: aMethodWithOffset) ].
	transformedSenders := self mergeTransformedSenders.
	transformedInitialCaller := self transformMessageSend: initialCaller.
	self renameSendersSelectors.
	^ transformedSenders
]

{ #category : 'method manipulation' }
SendersChainTransformer >> transformMessageSend: methodWithOffset [

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
SendersChainTransformer >> transformedInitialCaller [

	^ transformedInitialCaller
]

{ #category : 'accessing' }
SendersChainTransformer >> transformedSenders [

	^ transformedSenders
]
