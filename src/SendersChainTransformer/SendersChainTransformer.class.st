Class {
	#name : 'SendersChainTransformer',
	#superclass : 'Object',
	#instVars : [
		'originalCaller',
		'originalSenders',
		'selectorMaker'
	],
	#category : 'SendersChainTransformer-Core',
	#package : 'SendersChainTransformer',
	#tag : 'Core'
}

{ #category : 'backup' }
SendersChainTransformer >> backupSenders: senders caller: initialCaller [
	"method method for blocks"

	originalCaller := initialCaller method method copy.
	originalSenders := senders collect: [ :illSender | illSender method method copy ]
]

{ #category : 'method manipulation' }
SendersChainTransformer >> cloneMethodWithNewSelector: anIllSender [

	| clonedMethod |
	clonedMethod := anIllSender method copy.
	clonedMethod selector: (self makeNewSelector: clonedMethod selector).
	^ clonedMethod
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
SendersChainTransformer >> makeNewSelector: aByteSymbol [

	^ selectorMaker makeSelector: aByteSymbol
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

	senders reversed "the stack is top to bottom" do: [ :anIllSender |
		| clonedMethod |
		clonedMethod := self cloneMethodWithNewSelector: anIllSender.
		clonedMethod := self transformMessageSend: clonedMethod offset: anIllSender offset.
		self installMethod: clonedMethod ].
	
	initialCaller method methodClass methodDict
		at: initialCaller selector
		put: (self transformMessageSend: initialCaller method offset: initialCaller offset).
]

{ #category : 'method manipulation' }
SendersChainTransformer >> transformMessageSend: compiledMethodOrBlock offset: offset [

	| oldSelector newSelector messageNodeToTransform ast compiledMethod |
	compiledMethodOrBlock isCompiledBlock
		ifTrue: [
			ast := compiledMethodOrBlock method parseTree.
			messageNodeToTransform := (ast sourceNodeForPC: compiledMethodOrBlock pcInOuter) sourceNodeForPC: offset ]
		ifFalse: [
			ast := compiledMethodOrBlock parseTree.
			messageNodeToTransform := ast sourceNodeForPC: offset ].

	ast methodNode selector: compiledMethodOrBlock selector. "to keep the new selector that was changed but not yet installed"

	oldSelector := messageNodeToTransform selector.
	newSelector := self makeNewSelector: oldSelector.

	messageNodeToTransform selector: newSelector.
	compiledMethod := ast methodNode generateIR generate.
	compiledMethod propertyAt: #source put: ast formattedCode.
	^ compiledMethod
]
