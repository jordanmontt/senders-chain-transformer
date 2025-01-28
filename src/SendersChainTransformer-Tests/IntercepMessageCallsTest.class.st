Class {
	#name : 'IntercepMessageCallsTest',
	#superclass : 'TestCase',
	#instVars : [
		'handler',
		'p1',
		'p2',
		'p3',
		'p4',
		'proxies',
		'codeTransformer',
		'initialCaller',
		'senders'
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

	initialCaller := MethodWithOffset method: SCMockClassWithDumbMethods >> #foo offset: 45.
	senders := {
		           (MethodWithOffset method: Association class >> #key:value: offset: 42).
		           (MethodWithOffset method: Dictionary >> #at:put: offset: 82).
		           (MethodWithOffset method: SCMockClassWithDumbMethods >> #bar offset: 47) }.

	codeTransformer := CallSiteTransformer new
]

{ #category : 'running' }
IntercepMessageCallsTest >> setUpMethodProxies [

	handler := SCHandler new.
	p1 := MpMethodProxy onMethod: SCMockClassWithDumbMethods >> #foo handler: handler.
	p2 := MpMethodProxy onMethod: SCMockClassWithDumbMethods >> #bar handler: handler.
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
	SCMockClassWithDumbMethods new foo.
	self uninstallInstrumentation.
	
	reversedStack := handler calledMethods.
	self assert: reversedStack last equals: initialCaller selector.
	reversedStack removeLast.

	reversedStack
		with: senders
		do: [ :actualSelector :expectedSender | self assert: actualSelector equals: expectedSender selector ]
]

{ #category : 'tests' }
IntercepMessageCallsTest >> testInitialCallerActuallyCallsTransformedMethods [

	codeTransformer
		backupSenders: senders caller: initialCaller;
		transformCallSite: initialCaller senders: senders;
		installTransformations.

	self installInstrumentation.
	SCMockClassWithDumbMethods new foo.
	self uninstallInstrumentation.
	
	codeTransformer restoreOriginalState.

	self assert: handler calledMethods size equals: 1.
	self assert: handler calledMethods first equals: #foo
]

{ #category : 'running' }
IntercepMessageCallsTest >> uninstallInstrumentation [

	proxies do: [ :proxy | proxy perform: #uninstall ]
]
