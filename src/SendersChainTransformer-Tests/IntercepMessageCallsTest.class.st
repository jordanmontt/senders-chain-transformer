Class {
	#name : 'IntercepMessageCallsTest',
	#superclass : 'TestCase',
	#instVars : [
		'handler',
		'p1',
		'p2',
		'p3',
		'p4',
		'fixture',
		'proxies',
		'codeTransformer'
	],
	#category : 'SendersChainTransformer-Tests-Tests',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Tests'
}

{ #category : 'running' }
IntercepMessageCallsTest >> installInstrumentation [

	self setUpMethodProxies.
	proxies do: [ :proxy | proxy perform: #install ].
	MpMethodProxy enableInstrumentation.
]

{ #category : 'running' }
IntercepMessageCallsTest >> setUp [

	super setUp.

	fixture := SCDefaultFixture new.
	codeTransformer := SendersChainTransformer new.
	codeTransformer backupSenders: fixture senders caller: fixture initialCaller
]

{ #category : 'running' }
IntercepMessageCallsTest >> setUpMethodProxies [

	handler := SCHandler new.
	p1 := MpMethodProxy onMethod: SCMockClass >> #foo handler: handler.
	p2 := MpMethodProxy onMethod: SCAnotherMockClass >> #bar handler: handler.
	p3 := MpMethodProxy onMethod: Dictionary >> #at:put: handler: handler.
	p4 := MpMethodProxy onMethod: Association class >> #key:value: handler: handler.
	proxies := { p1. p2. p3. p4 }.
]

{ #category : 'running' }
IntercepMessageCallsTest >> tearDown [

	self uninstallInstrumentation.
	codeTransformer restoreOriginalState.
	super tearDown
]

{ #category : 'tests' }
IntercepMessageCallsTest >> testAllMessagesGetCalledWithoutTransformation [

	| reversedStack |
	self installInstrumentation.
	SCMockClass new foo.
	self uninstallInstrumentation.
	
	reversedStack := handler calledMethods.
	self assert: reversedStack last equals: fixture initialCaller selector.
	reversedStack removeLast.

	reversedStack
		with: fixture senders
		do: [ :actualSelector :expectedSender | self assert: actualSelector equals: expectedSender selector ]
]

{ #category : 'tests' }
IntercepMessageCallsTest >> testInitialCallerActuallyCallsTransformedMethods [

	codeTransformer transformCallingSenders: fixture senders initialCaller: fixture initialCaller.
	codeTransformer installTransformations.

	self installInstrumentation.
	SCMockClass new foo.
	self uninstallInstrumentation.

	self assert: handler calledMethods size equals: 1.
	self assert: handler calledMethods first equals: #foo
]

{ #category : 'running' }
IntercepMessageCallsTest >> uninstallInstrumentation [

	proxies do: [ :proxy | proxy perform: #uninstall ]
]
