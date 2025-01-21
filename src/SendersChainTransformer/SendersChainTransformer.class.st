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
		  ifTrue: [ MethodWithOffset method: anIllSender method offset: anIllSender offset ]
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

	transformedSenders do: [ :aMEthodWithOffset | self installMethod: aMEthodWithOffset method ].
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
SendersChainTransformer >> newMergeCompiledMethods: aListOfMethodsWithOffset [

	| mergedMethod |
	mergedMethod := aListOfMethodsWithOffset first method.

	aListOfMethodsWithOffset allButFirst do: [ :aMetodWithOffset |
		(aMetodWithOffset method sourceNodeForPC: aMetodWithOffset offset) isMessage
			ifTrue: [ self transformMessageSend: (MethodWithOffset method: mergedMethod offset: aMetodWithOffset offset) ]
			ifFalse: [
				| block |
				block := (mergedMethod literals select: #isCompiledBlock) detect: [ :aBlock |
					         (aBlock sourceNodeForPC: 55) isMessage ].
				self transformMessageSend: (MethodWithOffset method: block offset: aMetodWithOffset offset) ] ]
]

{ #category : 'instance creation' }
SendersChainTransformer >> newMergeCompiledMethods: aListOfMethodsWithOffset into: aCompiledMethod [

	| astToTransform nodeWithChanges nodeToTransform |
	astToTransform := aCompiledMethod parseTree.
	aListOfMethodsWithOffset do: [ :aMetodWithOffset |

		aMetodWithOffset isForCompiledBlock
			ifTrue: [ 
				1 halt.
				nodeWithChanges := (aMetodWithOffset method sourceNodeForPC: aMetodWithOffset pcInOuter)
					sourceNodeForPC: aMetodWithOffset offset.
				nodeToTransform := (astToTransform sourceNodeForPC: aMetodWithOffset pcInOuter)
					sourceNodeForPC: aMetodWithOffset offset ]
			ifFalse: [ 
				nodeWithChanges := aMetodWithOffset method sourceNodeForPC: aMetodWithOffset offset.
				nodeToTransform := astToTransform sourceNodeForPC: aMetodWithOffset offset ]. 
		
		nodeToTransform selector: nodeWithChanges selector ].
	1 halt
]

{ #category : 'method manipulation' }
SendersChainTransformer >> renameSendersSelectors [

	transformedSenders do: [ :aMethodWithOffset |
		aMethodWithOffset method selector: (self makeNewSelector: aMethodWithOffset selector) ]
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

	transformedSenders := senders reversed collect: [ :aMethodWithOffset |
		                      self transformMessageSend: (self cloneCompiledCode: aMethodWithOffset) ].
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
	
	^ compiledMethodOrBlock isCompiledBlock
		ifTrue: [ MethodWithOffset method: transformedCompiledMethod offset: offset pcInOuter: compiledMethodOrBlock pcInOuter ]
		ifFalse: [ MethodWithOffset method: transformedCompiledMethod offset: offset ]
]

{ #category : 'accessing' }
SendersChainTransformer >> transformedInitialCaller [

	^ transformedInitialCaller
]

{ #category : 'accessing' }
SendersChainTransformer >> transformedSenders [

	^ transformedSenders
]
