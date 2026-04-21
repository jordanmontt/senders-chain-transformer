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
CallSiteTransformerTest >> testInstallMethodWithNewSelector [

	| aMethodWithOffset tenuredNewSelector clonedCompiledMethod |
	aMethodWithOffset := IllMethodWithOffset method: SCMockClassWithDumbMethods >> #bar offset: 47.
	tenuredNewSelector := codeTransformer makeNewSelectorForMethod: SCMockClassWithDumbMethods >> #bar.

	"Make sure the method does not exist yet"
	self should: [ SCMockClassWithDumbMethods new perform: tenuredNewSelector ] raise: MessageNotUnderstood.
	self deny: (SCMockClassWithDumbMethods includesSelector: tenuredNewSelector).

	clonedCompiledMethod := (codeTransformer cloneCompiledCode: aMethodWithOffset) method.
	clonedCompiledMethod selector: tenuredNewSelector.
	codeTransformer installMethod: clonedCompiledMethod.

	self shouldnt: [ SCMockClassWithDumbMethods new perform: tenuredNewSelector ] raise: MessageNotUnderstood.
	self assert: clonedCompiledMethod selector equals: tenuredNewSelector.
	self assert: (SCMockClassWithDumbMethods methodDict at: tenuredNewSelector) equals: clonedCompiledMethod.
	self assert: clonedCompiledMethod bytecodes equals: aMethodWithOffset method bytecodes.
	
	clonedCompiledMethod methodClass removeSelector: clonedCompiledMethod selector
]

{ #category : 'tests' }
CallSiteTransformerTest >> testRemoveAlreadyImplemented [

    self assert: (codeTransformer removeAlreadyImplemented: { (Bag class >> #new) }) isEmpty.
    self assert: (codeTransformer removeAlreadyImplemented: { (OrderedCollection class >> #new) }) isEmpty.
    self assert: (codeTransformer removeAlreadyImplemented: { (OrderedCollection class >> #new:) }) isEmpty.
    self assert: (codeTransformer removeAlreadyImplemented: { (ArrayedCollection class >> #new) }) isEmpty.
    self assert: (codeTransformer removeAlreadyImplemented: { (ArrayedCollection class >> #new:) }) isEmpty.

    self deny: (codeTransformer removeAlreadyImplemented: { (Object >> #printString) }) isEmpty
]

{ #category : 'tests' }
CallSiteTransformerTest >> testRenameSendersBinarySelectors [

	| methodToRename renamedMethod |
	methodToRename := (SCMockClassWithDumbMethods >> #@) copy.

	self assert: methodToRename selector equals: #@.
	self assert: methodToRename sourceCode lines first equals: '@ anObject'.
	
	codeTransformer transformedSenders: { methodToRename }.
	codeTransformer renameSendersSelectors.
	renamedMethod := codeTransformer transformedSenders first.
	
	self deny: methodToRename selector equals: #@.
	self assert: (renamedMethod selector includesSubstring: 'pretenured').
	self deny: methodToRename sourceCode lines first equals: '@ anObject'.
	self assert: (renamedMethod sourceCode lines first includesSubstring: 'pretenured').
	self assert: (renamedMethod sourceCode lines first includesSubstring: ':')
]

{ #category : 'tests' }
CallSiteTransformerTest >> testRenameSendersKeywordSelectors [

	| methodToRename renamedMethod |
	methodToRename := (SCMockClassWithDumbMethods >> #at:ifAbsentPut:) copy.

	self assert: methodToRename selector equals: #at:ifAbsentPut:.
	self assert: methodToRename sourceCode lines first equals: 'at: key ifAbsentPut: aBlock'.
	
	codeTransformer transformedSenders: { methodToRename }.
	codeTransformer renameSendersSelectors.
	renamedMethod := codeTransformer transformedSenders first.
	
	self deny: methodToRename selector equals:  #at:ifAbsentPut:.
	self assert: (renamedMethod selector includesSubstring: 'pretenured').
	self deny: methodToRename sourceCode lines first equals: 'at: key ifAbsentPut: aBlock'.
	self assert: (renamedMethod sourceCode lines first includesSubstring: 'pretenured')
]

{ #category : 'tests' }
CallSiteTransformerTest >> testRenameSendersSelectors [

	| methodToRename renamedMethod |
	methodToRename := (SCMockClassWithDumbMethods >> #bar) copy.

	self assert: methodToRename selector equals: #bar.
	self assert: methodToRename sourceCode lines first equals: 'bar'.
	
	codeTransformer transformedSenders: { methodToRename }.
	codeTransformer renameSendersSelectors.
	renamedMethod := codeTransformer transformedSenders first.
	
	self assert: (renamedMethod selector includesSubstring: 'pretenured').
	self deny: methodToRename selector equals: #bar.
	self assert: (renamedMethod sourceCode lines first includesSubstring: 'pretenured').
	self deny: methodToRename sourceCode lines first equals: 'bar'
]

{ #category : 'tests' }
CallSiteTransformerTest >> testTransformCallingSendersInitialCaller [
	"Make sure methods do not exist"
	self
		should: [ SCMockClassWithDumbMethods new perform: (codeTransformer makeNewSelectorForSelector: #bar) ]
		raise: MessageNotUnderstood.
	self
		should: [ SCMockDictionary new perform: (codeTransformer makeNewSelectorForSelector: #at:put:) withArguments: #( #key 2 ) ]
		raise: MessageNotUnderstood.
	self
		should: [ SCMockAssociation perform: (codeTransformer makeNewSelectorForSelector: #key:value:) withArguments: #( #key #value ) ]
		raise: MessageNotUnderstood.

	codeTransformer
		backupSenders: senders caller: initialCaller;
		transformCallSite: initialCaller senders: senders;
		installTransformations.

	self
		shouldnt: [ SCMockClassWithDumbMethods new perform: (codeTransformer makeNewSelectorForSelector: #bar) ]
		raise: MessageNotUnderstood.
	self
		shouldnt: [ SCMockDictionary new perform: (codeTransformer makeNewSelectorForSelector: #at:put:) withArguments: #( #key 2 ) ]
		raise: MessageNotUnderstood.
	self
		shouldnt: [ SCMockAssociation perform: (codeTransformer makeNewSelectorForSelector: #key:value:) withArguments: #( #key #value ) ]
		raise: MessageNotUnderstood.

	codeTransformer restoreOriginalState
]
