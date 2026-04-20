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

    codeTransformer := CallSiteTransformer new
        methodProtocol: ('*' , self class package name);
        yourself.

    initialCaller := IllMethodWithOffset method: SCMockClassWithDumbMethods >> #foo offset: 45.
    senders := {
                   (IllMethodWithOffset method: Association class >> #key:value: offset: 42).
                   (IllMethodWithOffset method: Dictionary >> #at:put: offset: 82).
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
CallSiteTransformerTest >> testTransformCallingSendersInitialCaller [
	"Make sure methods do not exist"
	self
		should: [ SCMockClassWithDumbMethods new perform: (codeTransformer makeNewSelectorForSelector: #bar) ]
		raise: MessageNotUnderstood.
	self
		should: [ Dictionary new perform: (codeTransformer makeNewSelectorForSelector: #at:put:) withArguments: #( #key 2 ) ]
		raise: MessageNotUnderstood.
	self
		should: [ Association perform: (codeTransformer makeNewSelectorForSelector: #key:value:) withArguments: #( #key #value ) ]
		raise: MessageNotUnderstood.

	codeTransformer
		backupSenders: senders caller: initialCaller;
		transformCallSite: initialCaller senders: senders;
		installTransformations.

	self
		shouldnt: [ SCMockClassWithDumbMethods new perform: (codeTransformer makeNewSelectorForSelector: #bar) ]
		raise: MessageNotUnderstood.
	self
		shouldnt: [ Dictionary new perform: (codeTransformer makeNewSelectorForSelector: #at:put:) withArguments: #( #key 2 ) ]
		raise: MessageNotUnderstood.
	self
		shouldnt: [ Association perform: (codeTransformer makeNewSelectorForSelector: #key:value:) withArguments: #( #key #value ) ]
		raise: MessageNotUnderstood.

	codeTransformer restoreOriginalState
]
