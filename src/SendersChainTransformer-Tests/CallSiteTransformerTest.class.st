"
An IllRewriterTest is a test class for testing the behavior of IllRewriter
"
Class {
	#name : 'CallSiteTransformerTest',
	#superclass : 'TestCase',
	#instVars : [
		'codeTransformer',
		'initialCaller',
		'senders'
	],
	#category : 'SendersChainTransformer-Tests-Tests',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Tests'
}

{ #category : 'running' }
CallSiteTransformerTest >> setUp [

    super setUp.

    codeTransformer := CallSiteTransformer new.

    initialCaller := IllMethodWithOffset method: SCMockClassWithDumbMethods >> #foo offset: 45.
    senders := {
                   (IllMethodWithOffset method: SCMockAssociation class >> #key:value: offset: 42).
                   (IllMethodWithOffset method: SCMockDictionary >> #at:put: offset: 82).
                   (IllMethodWithOffset method: SCMockClassWithDumbMethods >> #bar offset: 47) }
]

{ #category : 'tests' }
CallSiteTransformerTest >> testExtensionMethods [

    codeTransformer class package extensionMethods do: [ :e |
        self assert: (e name includesSubstring: 'Tenured') ]
]

{ #category : 'tests' }
CallSiteTransformerTest >> testInstallBinaryPretenuredMethodCopiesDownToAllSubclasses [

	| pretenuredSelector compiledMethod nonPretenuredSelector |
	nonPretenuredSelector := #@.
	pretenuredSelector := TenuredSelectorMaker new makeSelectorForSelector: nonPretenuredSelector.
	
	self deny: (SCMockClassWithDumbMethods includesSelector: pretenuredSelector).
	self assert: (SCMockClassWithDumbMethods includesSelector: nonPretenuredSelector).
	
	self deny: (SCMockClassSubclass includesSelector: pretenuredSelector).
	self deny: (SCMockClassSubclass includesSelector: nonPretenuredSelector).
	
	self deny: (SCMockClassSubSubclass includesSelector: pretenuredSelector).
	self assert: (SCMockClassSubSubclass includesSelector: nonPretenuredSelector).

	compiledMethod := OpalCompiler new
		source: (pretenuredSelector , ' anObj');
		class: SCMockClassWithDumbMethods;
		compile.

	[
		codeTransformer installPretenuredMethod: compiledMethod.

		self assert: (SCMockClassWithDumbMethods includesSelector: pretenuredSelector).
		self deny: (SCMockClassSubclass includesSelector: pretenuredSelector).
		self assert: (SCMockClassSubSubclass includesSelector: pretenuredSelector) ]
	ensure: [ 
		{ SCMockClassWithDumbMethods . SCMockClassSubSubclass }
				do: [ :aClass | aClass removeSelector: pretenuredSelector ] ]
]

{ #category : 'tests' }
CallSiteTransformerTest >> testInstallPretenuredMethodCopiesDownToAllSubclasses [

	| pretenuredSelector compiledMethod nonPretenuredSelector |
	pretenuredSelector :=  #_pretenured_foo.
	nonPretenuredSelector := #foo.
	self deny: (SCMockClassWithDumbMethods includesSelector: pretenuredSelector).
	self assert: (SCMockClassWithDumbMethods includesSelector: nonPretenuredSelector).
	
	self deny: (SCMockClassSubclass includesSelector: pretenuredSelector).
	self deny: (SCMockClassSubclass includesSelector: nonPretenuredSelector).
	
	self deny: (SCMockClassSubSubclass includesSelector: pretenuredSelector).
	self assert: (SCMockClassSubSubclass includesSelector: nonPretenuredSelector).

	compiledMethod := OpalCompiler new
		source: pretenuredSelector;
		class: SCMockClassWithDumbMethods;
		compile.

	[
		codeTransformer installPretenuredMethod: compiledMethod.

		self assert: (SCMockClassWithDumbMethods includesSelector: pretenuredSelector).
		self deny: (SCMockClassSubclass includesSelector: pretenuredSelector).
		self assert: (SCMockClassSubSubclass includesSelector: pretenuredSelector) ]
	ensure: [ 
		{ SCMockClassWithDumbMethods . SCMockClassSubSubclass }
				do: [ :aClass | aClass removeSelector: pretenuredSelector ] ]
]

{ #category : 'tests' }
CallSiteTransformerTest >> testInstallPretenuredMethodFailsIfSelectorIsNotPretenured [

	| nonExistingSelector compiledMethod |
	nonExistingSelector :=  #noNExisTingSELect0r.
	compiledMethod := OpalCompiler new
		source: nonExistingSelector;
		class: SCMockClassWithDumbMethods;
		compile.

	self should: [ codeTransformer installPretenuredMethod: compiledMethod ] raise: Error
]

{ #category : 'tests' }
CallSiteTransformerTest >> testInstallPretenuredMethodWithoutNonPretenuredVersionImplemented [

	| pretenuredSelector compiledMethod |
	pretenuredSelector :=  #_pretenured_noNExisTingSELect0r.
	
	(OrderedCollection withAll: SCMockClassWithDumbMethods allSubclasses)
		add: SCMockClassWithDumbMethods;
		do: [ :aClass |  self deny: (aClass includesSelector: pretenuredSelector) ].

	compiledMethod := OpalCompiler new
		source: pretenuredSelector;
		class: SCMockClassWithDumbMethods;
		compile.

	self should: [ codeTransformer installPretenuredMethod: compiledMethod ] raise: AssertionFailure
]

{ #category : 'tests' }
CallSiteTransformerTest >> testRemoveAlreadyImplemented [

    self assert: (codeTransformer removeAlreadyImplemented: { (Bag class >> #new) }) isEmpty.
    self assert: (codeTransformer removeAlreadyImplemented: { (OrderedCollection class >> #new) }) isEmpty.
    self assert: (codeTransformer removeAlreadyImplemented: { (OrderedCollection class >> #new:) }) isEmpty.
    self assert: (codeTransformer removeAlreadyImplemented: { (ArrayedCollection class >> #new) }) isEmpty.
    self assert: (codeTransformer removeAlreadyImplemented: { (ArrayedCollection class >> #new:) }) isEmpty.
    self assert: (codeTransformer removeAlreadyImplemented: { (Behavior >> #newTenured:) }) isEmpty.
    self assert: (codeTransformer removeAlreadyImplemented: { (Behavior >> #newTenured) }) isEmpty.
    self assert: (codeTransformer removeAlreadyImplemented: { (Behavior >> #basicNewTenured) }) isEmpty.
    self assert: (codeTransformer removeAlreadyImplemented: { (Behavior >> #basicNewTenured:) }) isEmpty.

    self deny: (codeTransformer removeAlreadyImplemented: { (Object >> #printString) }) isEmpty
]

{ #category : 'tests' }
CallSiteTransformerTest >> testRenameSendersBinarySelectors [

	| methodToRename expectedSelector expectedSelectorInSourceCode |
	methodToRename := (SCMockClassWithDumbMethods >> #@) copy.
	
	codeTransformer transformedSenders: { methodToRename }.
	codeTransformer renameSendersSelectors.

	expectedSelector := codeTransformer makeNewSelectorForSelector: #@.
	self deny: methodToRename selector equals: #@.
	self assert: methodToRename selector equals: expectedSelector.
	
	expectedSelectorInSourceCode := (codeTransformer makeNewSelectorForSelector: #@), ' anObject'.
	self deny: methodToRename sourceCode lines first equals: '@ anObject'.
	self assert: methodToRename sourceCode lines first equals: expectedSelectorInSourceCode
]

{ #category : 'tests' }
CallSiteTransformerTest >> testRenameSendersKeywordSelectors [

	| methodToRename expectedSelectorInSourceCode |
	methodToRename := (SCMockClassWithDumbMethods >> #at:ifAbsentPut:) copy.
	
	codeTransformer transformedSenders: { methodToRename }.
	codeTransformer renameSendersSelectors.
	
	self assert: methodToRename selector equals: #_pretenured_at:ifAbsentPut:.

	expectedSelectorInSourceCode := '_pretenured_at: key ifAbsentPut: aBlock'.
	self assert: methodToRename sourceCode lines first equals: expectedSelectorInSourceCode
]

{ #category : 'tests' }
CallSiteTransformerTest >> testRenameSendersLongSelector [

	| methodToRename expectedSelector expectedSelectorInSourceCode |
	methodToRename := (SCMockClassWithDumbMethods class >> #with:with:with:with:) copy.

	self assert: methodToRename selector equals: #with:with:with:with:.
	self assert: methodToRename sourceCode lines first equals: 'with: firstObject with: secondObject with: thirdObject with: fourthObject'.
	
	codeTransformer transformedSenders: { methodToRename }.
	codeTransformer renameSendersSelectors.
	
	expectedSelector := codeTransformer makeNewSelectorForSelector: #with:with:with:with:.
	self deny: methodToRename selector equals: #with:with:with:with:.
	self assert: methodToRename selector equals: expectedSelector.
	
	expectedSelectorInSourceCode := (codeTransformer makeNewSelectorForSelector: #with:) , ' firstObject with: secondObject with: thirdObject with: fourthObject'. 
	self deny: methodToRename sourceCode lines first equals: 'with: firstObject with: secondObject with: thirdObject with: fourthObject'.
	self assert: methodToRename sourceCode lines first equals: expectedSelectorInSourceCode
]

{ #category : 'tests' }
CallSiteTransformerTest >> testRenameSendersSelectors [

	| methodToRename expectedSelector |
	methodToRename := (SCMockClassWithDumbMethods >> #bar) copy.

	self assert: methodToRename selector equals: #bar.
	self assert: methodToRename sourceCode lines first equals: 'bar'.
	
	codeTransformer transformedSenders: { methodToRename }.
	codeTransformer renameSendersSelectors.
	
	expectedSelector := codeTransformer makeNewSelectorForSelector: #bar.
	self deny: methodToRename selector equals: #bar.
	self assert: methodToRename selector equals: expectedSelector.
	
	self deny: methodToRename sourceCode lines first equals: 'bar'.
	self assert: methodToRename sourceCode lines first equals: expectedSelector.
]
