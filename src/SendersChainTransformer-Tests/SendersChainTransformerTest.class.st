"
An IllRewriterTest is a test class for testing the behavior of IllRewriter
"
Class {
	#name : 'SendersChainTransformerTest',
	#superclass : 'TestCase',
	#instVars : [
		'codeTransformer',
		'fixture'
	],
	#category : 'SendersChainTransformer-Tests-Tests',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Tests'
}

{ #category : 'running' }
SendersChainTransformerTest >> setUp [

	super setUp.

	fixture := SCDefaultFixture new.
	codeTransformer := SendersChainTransformer new.
	codeTransformer backupSenders: fixture senders caller: fixture initialCaller
]

{ #category : 'running' }
SendersChainTransformerTest >> tearDown [

	codeTransformer restoreOriginalState.

	super tearDown
]

{ #category : 'tests' }
SendersChainTransformerTest >> testInstallMethodWithNewSelector [

	| aMethodWithOffset tenuredNewSelector clonedCompiledMethod |
	aMethodWithOffset := fixture senders last.
	tenuredNewSelector := codeTransformer makeNewSelector: #bar.

	"Make sure the method does not exist yet"
	self should: [ SCAnotherMockClass new perform: tenuredNewSelector ] raise: MessageNotUnderstood.
	self deny: (SCAnotherMockClass includesSelector: tenuredNewSelector).

	clonedCompiledMethod := (codeTransformer cloneCompiledCode: aMethodWithOffset) method.
	clonedCompiledMethod selector: tenuredNewSelector.
	codeTransformer installMethod: clonedCompiledMethod.

	self shouldnt: [ SCAnotherMockClass new perform: tenuredNewSelector ] raise: MessageNotUnderstood.
	self assert: clonedCompiledMethod selector equals: tenuredNewSelector.
	self assert: (SCAnotherMockClass methodDict at: tenuredNewSelector) equals: clonedCompiledMethod.
	self assert: clonedCompiledMethod bytecodes equals: aMethodWithOffset method bytecodes
]

{ #category : 'tests' }
SendersChainTransformerTest >> testTransformCallingSendersInitialCaller [
	"Make sure methods do not exist"

	self
		should: [ SCAnotherMockClass new perform: (codeTransformer makeNewSelector: #bar) ]
		raise: MessageNotUnderstood.
	self
		should: [
		Dictionary new perform: (codeTransformer makeNewSelector: #at:put:) withArguments: #( #key 2 ) ]
		raise: MessageNotUnderstood.
	self
		should: [
		Association perform: (codeTransformer makeNewSelector: #key:value:) withArguments: #( #key #value ) ]
		raise: MessageNotUnderstood.

	codeTransformer
		transformCallingSenders: fixture senders initialCaller: fixture initialCaller;
		installTransformations.

	self
		shouldnt: [ SCAnotherMockClass new perform: (codeTransformer makeNewSelector: #bar) ]
		raise: MessageNotUnderstood.
	self
		shouldnt: [
		Dictionary new perform: (codeTransformer makeNewSelector: #at:put:) withArguments: #( #key 2 ) ]
		raise: MessageNotUnderstood.
	self
		shouldnt: [
		Association perform: (codeTransformer makeNewSelector: #key:value:) withArguments: #( #key #value ) ]
		raise: MessageNotUnderstood
]

{ #category : 'tests' }
SendersChainTransformerTest >> testTransformMessageSend [

	| aMethodWithOffset tenuredCompiledMethod symbolicMessageSendBytecode expectedSelector |
	aMethodWithOffset := fixture senders second. "Dictionary >> #at:put:"
	expectedSelector := codeTransformer makeNewSelector: (aMethodWithOffset method sourceNodeForPC: aMethodWithOffset offset) selector.

	self
		shouldnt: [ aMethodWithOffset method valueWithReceiver: aMethodWithOffset methodClass new arguments: #( #key #value ) ]
		raise: PrimitiveFailed.

	tenuredCompiledMethod := codeTransformer transformMessageSend: aMethodWithOffset.

	symbolicMessageSendBytecode := tenuredCompiledMethod symbolicBytecodes detect: [ :e |
		                               e bytes includes: aMethodWithOffset bytecode ].
	self assert: symbolicMessageSendBytecode description equals: 'send: ' , expectedSelector.
	"Method's selector remaine unchanged"
	self assert: tenuredCompiledMethod selector equals: aMethodWithOffset selector.
	"We pretenure one message send to a method that does not exists"
	self
		should: [ tenuredCompiledMethod valueWithReceiver: aMethodWithOffset methodClass new arguments: #( #key #value ) ]
		raise: MessageNotUnderstood
]
