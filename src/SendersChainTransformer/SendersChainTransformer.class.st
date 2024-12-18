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

	originalCaller := initialCaller method copy.
	originalSenders := senders collect: [ :illSender | illSender method copy ]
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
	originalSenders do: [ :illSender |
		illSender method methodClass removeSelector: (self makeNewSelector: illSender selector) ]
]

{ #category : 'api' }
SendersChainTransformer >> transformCallingSenders: senders initialCaller: initialCaller [

	| clonedMethod |

	initialCaller method methodClass methodDict
		at: initialCaller selector
		put: (self transformMessageSend: initialCaller method offset: initialCaller offset).

	senders do: [ :anIllSender |
		clonedMethod := self cloneMethodWithNewSelector: anIllSender.
		clonedMethod := self transformMessageSend: clonedMethod offset: anIllSender offset.
		self installMethod: clonedMethod ]
]

{ #category : 'method manipulation' }
SendersChainTransformer >> transformMessageSend: compiledMethod offset: offset [

	| oldSelector newSelector irSendNode ir irSequences |
	oldSelector := (compiledMethod sourceNode sourceNodeForPC: offset) selector.
	newSelector := self makeNewSelector: oldSelector.

	ir := compiledMethod ir.
	irSequences := ir allSequences flatCollect: #children.
	irSendNode := (irSequences select: #isSend) detect: [ :e | e selector = oldSelector ].
	irSendNode selector: newSelector.

	^ ir generate
		  selector: compiledMethod selector;
		  yourself
]
