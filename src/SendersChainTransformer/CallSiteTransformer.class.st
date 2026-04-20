Class {
	#name : 'CallSiteTransformer',
	#superclass : 'Object',
	#instVars : [
		'originalCaller',
		'originalSenders',
		'selectorMaker',
		'transformedSenders',
		'transformedCallSite',
		'methodProtocol'
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
	selectorMaker := TenuredSelectorMaker new.
	methodProtocol := 'automatically-generated'
]

{ #category : 'method manipulation' }
CallSiteTransformer >> installMethod: aCompiledMethod [

    aCompiledMethod methodClass
        addAndClassifySelector: aCompiledMethod selector
        withMethod: aCompiledMethod
        inProtocol: methodProtocol
]

{ #category : 'method manipulation' }
CallSiteTransformer >> installTransformations [

	transformedSenders do: [ :aMethodWithOffset | self installMethod: aMethodWithOffset method ].
	self installMethod: transformedCallSite method
]

{ #category : 'method manipulation' }
CallSiteTransformer >> makeNewSelectorForMethod: aCompiledMethod [

    ^ selectorMaker makeSelectorForMethod: aCompiledMethod
]

{ #category : 'method manipulation' }
CallSiteTransformer >> makeNewSelectorForSelector: aSymbol [

    ^ selectorMaker makeSelectorForSelector: aSymbol
]

{ #category : 'method manipulation' }
CallSiteTransformer >> mergeTransformedSenders [
	"It can happen that the same method was modified twice because it appeared in the senders stack twice with different bytecode offsets"
	transformedSenders := CodeTransformationsMerger new mergeTransformedCompiledMethods: transformedSenders.
	^ transformedSenders
]

{ #category : 'accessing' }
CallSiteTransformer >> methodProtocol: aString [

	methodProtocol := aString
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

    transformedSenders do: [ :aCompiledMethod |
        aCompiledMethod selector: (self makeNewSelectorForMethod: aCompiledMethod) ]
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

    | compiledMethodOrBlock offset ast messageNode transformedCompiledMethod rootMethod |
    compiledMethodOrBlock := methodWithOffset method.
    offset := methodWithOffset offset.

    "Walk up outerCode chain to find the root CompiledMethod"
    rootMethod := compiledMethodOrBlock.
    [ rootMethod isCompiledBlock ] whileTrue: [ rootMethod := rootMethod outerCode ].

    ast := rootMethod parseTree.

    "Navigate down into the block nesting to find the node at the right offset"
    messageNode := compiledMethodOrBlock isCompiledBlock
        ifTrue: [
            | currentNode chain cursor |
            currentNode := ast.
            chain := OrderedCollection new.
            cursor := compiledMethodOrBlock.

            [ cursor isCompiledBlock ] whileTrue: [
                chain addFirst: cursor.
                cursor := cursor outerCode ].
            "Walk down: for each compiled block in the chain, go one sourceNodeForPC level deeper"
            chain do: [ :eachBlock | currentNode := currentNode sourceNodeForPC: eachBlock pcInOuter ].
            currentNode sourceNodeForPC: offset ]
        ifFalse: [ ast sourceNodeForPC: offset ].

    messageNode selector: (OCSelectorNode value: (self makeNewSelectorForSelector: messageNode selector)).

    transformedCompiledMethod := rootMethod methodClass compiler compile: ast methodNode formattedCode.
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
