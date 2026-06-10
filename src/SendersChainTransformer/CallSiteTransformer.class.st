Class {
	#name : 'CallSiteTransformer',
	#superclass : 'Object',
	#instVars : [
		'selectorMaker',
		'methodProtocol',
		'alreadyImplementedMethods',
		'originalMethods',
		'transformedCalleeChains',
		'transformedCallSite'
	],
	#category : 'SendersChainTransformer-Code-Rewriter',
	#package : 'SendersChainTransformer',
	#tag : 'Code-Rewriter'
}

{ #category : 'backup' }
CallSiteTransformer >> backupMethods: methods [

    originalMethods := methods
        collect: [ :compiledMethod | compiledMethod copy ]
        as: Set
]

{ #category : 'method manipulation' }
CallSiteTransformer >> cloneCompiledCode: anIllSender [

	^ anIllSender method isCompiledBlock
		  ifTrue: [ "Do not copy blocks as it does not work"
		  		IllMethodWithOffset method: anIllSender method offset: anIllSender offset ]
		  ifFalse: [ IllMethodWithOffset method: anIllSender method copy offset: anIllSender offset ]
]

{ #category : 'safety checks' }
CallSiteTransformer >> includesMetaProgramingCalls: stack [

   | reflectiveSelectors |
   reflectiveSelectors := #( #perform: #perform:with: #perform:withArguments: #perform:withArguments:inSuperclass: ).
   stack do: [ :methodWithOffset |
		methodWithOffset sourceNodeAtOffset isAssignment ifTrue: [ ^ true ].
		(reflectiveSelectors includes: methodWithOffset sourceNodeAtOffset selector) ifTrue: [ ^ true ] ].
	^ false
]

{ #category : 'initialization' }
CallSiteTransformer >> initialize [

    super initialize.
    selectorMaker := TenuredSelectorMaker new.
    methodProtocol := 'automatically-generated'.
    originalMethods := { }. 

    self class package extensionMethods do: [ :e | self assert: (e name includesSubstring: 'Tenured') ].
    alreadyImplementedMethods := self class package extensionMethods , {
            (Behavior >> #newTenured).
            (Behavior >> #newTenured:).
            (Behavior >> #basicNewTenured).
            (Behavior >> #basicNewTenured:) }
]

{ #category : 'methods installation' }
CallSiteTransformer >> installMethod: aCompiledMethod [

    aCompiledMethod methodClass
        addAndClassifySelector: aCompiledMethod selector
        withMethod: aCompiledMethod
        inProtocol: methodProtocol
]

{ #category : 'methods installation' }
CallSiteTransformer >> installPretenuredMethod: aPretenuredCompiledMethod [

		| oldSelector |
	oldSelector := selectorMaker untenureSelector: aPretenuredCompiledMethod selector.

	"Install aliases to the new selector to keep behavior"
	oldSelector implementors do: [ :implementor |
		implementor methodClass methodDict at: aPretenuredCompiledMethod selector put: implementor ].

	self installMethod: aPretenuredCompiledMethod
]

{ #category : 'methods installation' }
CallSiteTransformer >> installTransformations [

	transformedCalleeChains do: [ :compiledMethod | self installPretenuredMethod: compiledMethod ].
	transformedCallSite ifNotNil: [ self installMethod: transformedCallSite ]
]

{ #category : 'method manipulation' }
CallSiteTransformer >> makeNewSelectorForMethod: aCompiledMethod [

    ^ selectorMaker makeSelectorForMethod: aCompiledMethod
]

{ #category : 'method manipulation' }
CallSiteTransformer >> makeNewSelectorForSelector: aSymbol [

    ^ selectorMaker makeSelectorForSelector: aSymbol
]

{ #category : 'accessing' }
CallSiteTransformer >> methodProtocol: aString [

	methodProtocol := aString
]

{ #category : 'safety checks' }
CallSiteTransformer >> removeAlreadyImplemented: senders [
	"Filter out methods that are already implemented or conflict with special-case implementations."

	| normalizedImplementedNames implementedMethods |
	
	normalizedImplementedNames := (alreadyImplementedMethods collect: [ :method |
		method name copyReplaceAll: 'Tenured' with: '' ]) asSet.
	
	implementedMethods := alreadyImplementedMethods asSet.

	^ senders reject: [ :methodWithOffset |
		(normalizedImplementedNames includes: methodWithOffset name)
			or: [ implementedMethods includes: methodWithOffset method ] ]
]

{ #category : 'method manipulation' }
CallSiteTransformer >> renameSendersSelectors [

    transformedCalleeChains do: [ :aCompiledMethod |
        | newSelector updatedSource |
        newSelector := self makeNewSelectorForMethod: aCompiledMethod.
        updatedSource := self
            updateSourceCode: aCompiledMethod sourceCode
            oldSelector: aCompiledMethod selector
            newSelector: newSelector.
        aCompiledMethod propertyAt: #source put: updatedSource.
        aCompiledMethod selector: newSelector ]
]

{ #category : 'backup' }
CallSiteTransformer >> restoreOriginalState [

    originalMethods do: [ :aCompiledMethod | self installMethod: aCompiledMethod ].

    transformedCalleeChains do: [ :aCompiledMethod | aCompiledMethod methodClass removeSelector: aCompiledMethod selector ]
]

{ #category : 'accessing' }
CallSiteTransformer >> selectorMaker [

	^ selectorMaker
]

{ #category : 'api' }
CallSiteTransformer >> transformCallSite: initialCaller senders: senders [

    | filteredMethods |
    transformedCalleeChains := self removeAlreadyImplemented: senders.
    
    filteredMethods := (self removeAlreadyImplemented: { initialCaller }) , transformedCalleeChains.
    (self includesMetaProgramingCalls: filteredMethods)
        ifTrue: [ SCTransformationException new signal ].

    transformedCalleeChains := transformedCalleeChains collect: [ :aMethodWithOffset |
        self transformMessageSend: (self cloneCompiledCode: aMethodWithOffset) ].

	 (self removeAlreadyImplemented: { initialCaller }) ifNotEmpty: [ :collection | 
		  | methodWithOffset |
		  methodWithOffset := collection first. 
        transformedCallSite := self transformMessageSend: methodWithOffset ].

    self renameSendersSelectors
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
CallSiteTransformer >> transformedSenders [

	^ transformedCalleeChains
]

{ #category : 'accessing' }
CallSiteTransformer >> transformedSenders: aCollectionOfCompiledMethods [

	transformedCalleeChains := aCollectionOfCompiledMethods
]

{ #category : 'method manipulation' }
CallSiteTransformer >> updateSourceCode: sourceCode oldSelector: oldSelector newSelector: newSelector [
    "Replace the selector keywords in the first line of sourceCode with those of newSelector.
    Keywords are replaced positionally (not by substring) to avoid corrupting already-replaced text.
    For example, given old selector with:with: and new selector _pre_with:with:, the first line
    'with: a with: b' becomes '_pre_with: a _pre_with: b'. The rest of the source is unchanged."

    | firstLine rest words updatedFirstLine |
    firstLine := sourceCode lines first.
    rest := sourceCode lines allButFirst.
    words := firstLine substrings.
    newSelector keywords doWithIndex: [ :newKw :i | words at: 2 * i - 1 put: newKw ].
    updatedFirstLine := ' ' join: words.

    ^ String cr join: { updatedFirstLine } , rest
]
