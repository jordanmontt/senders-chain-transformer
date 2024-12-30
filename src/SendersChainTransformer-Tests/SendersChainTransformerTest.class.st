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
SendersChainTransformerTest >> testCloneMethodWithNewSelector [

	| illSender tenuredNewSelector clonedCompiledMethod |
	illSender := fixture senders last.
	tenuredNewSelector := codeTransformer makeNewSelector: #bar.

	"Make sure the method does not exist yet"
	self should: [ SCAnotherMockClass new perform: tenuredNewSelector ] raise: MessageNotUnderstood.
	self deny: (SCAnotherMockClass includesSelector: tenuredNewSelector).

	clonedCompiledMethod := codeTransformer cloneMethodWithNewSelector: illSender.
	codeTransformer installMethod: clonedCompiledMethod.

	self shouldnt: [ SCAnotherMockClass new perform: tenuredNewSelector ] raise: MessageNotUnderstood.
	self assert: clonedCompiledMethod selector equals: tenuredNewSelector.
	self assert: (SCAnotherMockClass methodDict at: tenuredNewSelector) equals: clonedCompiledMethod.
	self assert: clonedCompiledMethod bytecodes equals: illSender method bytecodes
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

	codeTransformer transformCallingSenders: fixture senders initialCaller: fixture initialCaller.

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
SendersChainTransformerTest >> testTransformMessageSendOffset [

	| illSender tenuredCompiledMethod symbolicMessageSendBytecode expectedSelector offset methodToTenure |
	illSender := fixture senders second. "Dictionary >> #at:put:"
	methodToTenure := illSender method.
	offset := illSender offset.
	expectedSelector := codeTransformer makeNewSelector: (illSender method sourceNodeForPC: offset) selector.

	self
		shouldnt: [ methodToTenure valueWithReceiver: methodToTenure methodClass new arguments: #( #key #value ) ]
		raise: PrimitiveFailed.

	tenuredCompiledMethod := codeTransformer transformMessageSend: methodToTenure clone offset: offset.

	symbolicMessageSendBytecode := tenuredCompiledMethod symbolicBytecodes detect: [ :e |
		                               e bytes includes: illSender bytecode ].
	self assert: symbolicMessageSendBytecode description equals: 'send: ' , expectedSelector.
	"Method's selector remaine unchanged"
	self assert: tenuredCompiledMethod selector equals: illSender selector.
	"We pretenure one message send to a method that does not exists"
	self
		should: [ tenuredCompiledMethod valueWithReceiver: methodToTenure methodClass new arguments: #( #key #value ) ]
		raise: MessageNotUnderstood
]
