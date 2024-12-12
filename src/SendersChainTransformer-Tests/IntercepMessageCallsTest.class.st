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
		'proxies'
	],
	#category : 'SendersChainTransformer-Tests',
	#package : 'SendersChainTransformer-Tests'
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

	fixture := SCDefaultFixture new
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
	super tearDown
]

{ #category : 'tests' }
IntercepMessageCallsTest >> testAllMessagesGetCalledWithoutTransformation [

	| reversedStack |
	self installInstrumentation.
	SCMockClass new foo.
	self uninstallInstrumentation.
	
	reversedStack := handler calledMethods reversed.
	self assert: reversedStack first equals: fixture initialCaller selector.
	reversedStack removeFirst.

	reversedStack
		with: fixture senders
		do: [ :actualSelector :expectedSender | self assert: actualSelector equals: expectedSender selector ]
]

{ #category : 'tests' }
IntercepMessageCallsTest >> testInitialCallerActuallyCallsTransformedMethods [

	| codeTransformer |
	codeTransformer := SendersChainTransformer new.
	codeTransformer transformCallingSenders: fixture senders initialCaller: fixture initialCaller.

	self installInstrumentation.
	SCMockClass new foo.
	self uninstallInstrumentation.
	codeTransformer restoreOriginalState.

	self assert: handler calledMethods size equals: 1.
	self assert: handler calledMethods first equals: #foo
]

{ #category : 'running' }
IntercepMessageCallsTest >> uninstallInstrumentation [

	proxies do: [ :proxy | proxy perform: #uninstall ]
]
