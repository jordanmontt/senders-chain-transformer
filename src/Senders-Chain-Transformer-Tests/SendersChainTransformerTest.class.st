"
An IllRewriterTest is a test class for testing the behavior of IllRewriter
"
Class {
	#name : 'SendersChainTransformerTest',
	#superclass : 'TestCase',
	#instVars : [
		'rewriter',
		'senders',
		'initialCaller'
	],
	#category : 'Senders-Chain-Transformer-Tests',
	#package : 'Senders-Chain-Transformer-Tests'
}

{ #category : 'running' }
SendersChainTransformerTest >> setUp [

	super setUp.

	rewriter := SendersChainTransformer new.
	initialCaller := MethodWithOffset method: SCMockClass >> #foo offset: 45.
	senders := {
		           (MethodWithOffset method: SCAnotherMockClass >> #bar offset: 36).
		           (MethodWithOffset method: Dictionary >> #at:put: offset: 82).
		           (MethodWithOffset method: Association class >> #key:value: offset: 42) }.

	rewriter backupSenders: senders caller: initialCaller
]

{ #category : 'running' }
SendersChainTransformerTest >> tearDown [

	rewriter restoreOriginalState.

	super tearDown
]

{ #category : 'tests' }
SendersChainTransformerTest >> testCloneMethodWithNewSelector [

	| illSender tenuredNewSelector clonedCompiledMethod |
	illSender := senders first.
	tenuredNewSelector := rewriter makeNewSelector: #bar.

	"Make sure the method does not exist yet"
	self should: [ SCAnotherMockClass new perform: tenuredNewSelector ] raise: MessageNotUnderstood.
	self deny: (SCAnotherMockClass includesSelector: tenuredNewSelector).

	clonedCompiledMethod := rewriter cloneMethodWithNewSelector: illSender.
	rewriter installMethod: clonedCompiledMethod.

	self shouldnt: [ SCAnotherMockClass new perform: tenuredNewSelector ] raise: MessageNotUnderstood.
	self assert: clonedCompiledMethod selector equals: tenuredNewSelector.
	self assert: (SCAnotherMockClass methodDict at: tenuredNewSelector) equals: clonedCompiledMethod.
	self assert: clonedCompiledMethod bytecodes equals: illSender method bytecodes
]

{ #category : 'tests' }
SendersChainTransformerTest >> testTransformCallingSendersInitialCaller [
	
	"Make sure methods do not exist"
	self should: [ SCAnotherMockClass new perform: (rewriter makeNewSelector: #bar) ] raise: MessageNotUnderstood.
	self
		should: [ Dictionary new perform: (rewriter makeNewSelector: #at:put:) withArguments: #( #key 2 ) ]
		raise: MessageNotUnderstood.
	self
		should: [ Association perform: (rewriter makeNewSelector: #key:value:) withArguments: #( #key #value ) ]
		raise: MessageNotUnderstood.

	rewriter transformCallingSenders: senders initialCaller: initialCaller.

	self shouldnt: [ SCAnotherMockClass new perform: (rewriter makeNewSelector: #bar) ] raise: MessageNotUnderstood.
	self
		shouldnt: [ Dictionary new perform: (rewriter makeNewSelector: #at:put:) withArguments: #( #key 2 ) ]
		raise: MessageNotUnderstood.
	self
		shouldnt: [ Association perform: (rewriter makeNewSelector: #key:value:) withArguments: #( #key #value ) ]
		raise: MessageNotUnderstood
]

{ #category : 'tests' }
SendersChainTransformerTest >> testTransformMessageSendOffset [

	| illSender tenuredCompiledMethod symbolicMessageSendBytecode expectedSelector offset methodToTenure |
	illSender := senders second. "Dictionary >> #at:put:"
	methodToTenure := illSender method.
	offset := illSender offset.
	expectedSelector := rewriter makeNewSelector: (illSender method sourceNodeForPC: offset) selector.

	self
		shouldnt: [ methodToTenure valueWithReceiver: methodToTenure methodClass new arguments: #( #key #value ) ]
		raise: PrimitiveFailed.

	tenuredCompiledMethod := rewriter transformMessageSend: methodToTenure clone offset: offset.

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
