Class {
	#name : 'SendersChainTransformerWithBlockClosureTest',
	#superclass : 'TestCase',
	#instVars : [
		'codeTransformer',
		'fixture'
	],
	#category : 'SendersChainTransformer-Tests',
	#package : 'SendersChainTransformer-Tests'
}

{ #category : 'running' }
SendersChainTransformerWithBlockClosureTest >> setUp [

	super setUp.

	fixture := SCFullBlockClosureFixture new.
	codeTransformer := SendersChainTransformer new.
	codeTransformer backupSenders: fixture senders caller: fixture initialCaller
]

{ #category : 'running' }
SendersChainTransformerWithBlockClosureTest >> tearDown [

	codeTransformer restoreOriginalState.

	super tearDown
]

{ #category : 'tests' }
SendersChainTransformerWithBlockClosureTest >> testTransformCallingSendersInitialCaller [

	self
		should: [ SCMockWithBlockclosureClass new perform: (codeTransformer makeNewSelector: #theMethod) ]
		raise: MessageNotUnderstood.

	codeTransformer transformCallingSenders: fixture senders initialCaller: fixture initialCaller.

	1 halt.
	self
		shouldnt: [ SCMockWithBlockclosureClass new perform: (codeTransformer makeNewSelector: #theMethod) ]
		raise: MessageNotUnderstood
]
