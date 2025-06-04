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

	initialCaller := MethodWithOffset method: SCMockClassWithDumbMethods >> #foo offset: 45.
	senders := {
		           (MethodWithOffset method: Association class >> #key:value: offset: 42).
		           (MethodWithOffset method: Dictionary >> #at:put: offset: 82).
		           (MethodWithOffset method: SCMockClassWithDumbMethods >> #bar offset: 47) }.

	codeTransformer := CallSiteTransformer new
]

{ #category : 'tests' }
CallSiteTransformerTest >> testInstallMethodWithNewSelector [

	| aMethodWithOffset tenuredNewSelector clonedCompiledMethod |
	aMethodWithOffset := senders last "SCAnotherMockClass >> #bar".
	tenuredNewSelector := codeTransformer makeNewSelector: #bar.

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
CallSiteTransformerTest >> testTransformCallingSendersInitialCaller [
	"Make sure methods do not exist"
	self
		should: [ SCMockClassWithDumbMethods new perform: (codeTransformer makeNewSelector: #bar) ]
		raise: MessageNotUnderstood.
	self
		should: [ Dictionary new perform: (codeTransformer makeNewSelector: #at:put:) withArguments: #( #key 2 ) ]
		raise: MessageNotUnderstood.
	self
		should: [ Association perform: (codeTransformer makeNewSelector: #key:value:) withArguments: #( #key #value ) ]
		raise: MessageNotUnderstood.

	codeTransformer
		backupSenders: senders caller: initialCaller;
		transformCallSite: initialCaller senders: senders;
		installTransformations.

	self
		shouldnt: [ SCMockClassWithDumbMethods new perform: (codeTransformer makeNewSelector: #bar) ]
		raise: MessageNotUnderstood.
	self
		shouldnt: [ Dictionary new perform: (codeTransformer makeNewSelector: #at:put:) withArguments: #( #key 2 ) ]
		raise: MessageNotUnderstood.
	self
		shouldnt: [ Association perform: (codeTransformer makeNewSelector: #key:value:) withArguments: #( #key #value ) ]
		raise: MessageNotUnderstood.
		
	codeTransformer restoreOriginalState
]

{ #category : 'tests' }
CallSiteTransformerTest >> testTransformMessageSend [

	| aMethodWithOffset tenuredCompiledMethod symbolicMessageSendBytecode expectedSelector |
	aMethodWithOffset := senders second. "Dictionary >> #at:put:"
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

{ #category : 'tests' }
CallSiteTransformerTest >> testTransformMessageSendWithBinarySelector [

	| aMethodWithOffset tenuredCompiledMethod expectedMethodsAST |
	aMethodWithOffset := MethodWithOffset
			method: SCMockClassWithDumbMethods >> #binaryMethod
			offset: 44.
	expectedMethodsAST:= OCParser parseMethod: 'binaryMethod

	self foo: (self ', (codeTransformer selectorMaker makeSelector: #':') ,' 1) andBar: 0'.

	tenuredCompiledMethod := codeTransformer transformMessageSend: aMethodWithOffset.

	self assert: tenuredCompiledMethod parseTree equals: expectedMethodsAST
]
