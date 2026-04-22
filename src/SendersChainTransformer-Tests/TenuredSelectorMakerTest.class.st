"
A TenuredSelectorMakerTest is a test class for testing the behavior of TenuredSelectorMaker
"
Class {
	#name : 'TenuredSelectorMakerTest',
	#superclass : 'TestCase',
	#instVars : [
		'tenuredSelectorMaker'
	],
	#category : 'SendersChainTransformer-Tests-Code-Rewriter',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Code-Rewriter'
}

{ #category : 'running' }
TenuredSelectorMakerTest >> setUp [

	super setUp.

	tenuredSelectorMaker := TenuredSelectorMaker new
]

{ #category : 'tests' }
TenuredSelectorMakerTest >> testMakeSelectorForMethod [

    | expectedSelector |
    expectedSelector := #_pretenured_ , tenuredSelectorMaker randomPrefix , '_' , #foo.
    self
        assert: (tenuredSelectorMaker makeSelectorForMethod: SCMockClassWithDumbMethods >> #foo)
        equals: expectedSelector
]

{ #category : 'tests' }
TenuredSelectorMakerTest >> testMakeSelectorForMethodNotTransformMethods [

    self assert: (tenuredSelectorMaker makeSelectorForMethod: BlockClosure >> #value) equals: #value.
    self assert: (tenuredSelectorMaker makeSelectorForMethod: BlockClosure >> #value:) equals: #value:.
    self assert: (tenuredSelectorMaker makeSelectorForMethod: Semaphore >> #critical:) equals: #critical:.
    self assert: (tenuredSelectorMaker makeSelectorForMethod: Behavior >> #basicNewTenured) equals: #basicNewTenured.
    self assert: (tenuredSelectorMaker makeSelectorForMethod: Behavior >> #basicNewTenured:) equals: #basicNewTenured:.
    self assert: (tenuredSelectorMaker makeSelectorForMethod: Behavior >> #newTenured) equals: #newTenured.
    self assert: (tenuredSelectorMaker makeSelectorForMethod: Behavior >> #newTenured) equals: #newTenured
]

{ #category : 'tests' }
TenuredSelectorMakerTest >> testMakeSelectorForSelector [

    | expectedSelector |
    expectedSelector := #_pretenured_ , tenuredSelectorMaker randomPrefix , '_' , #foo.
    self assert: (tenuredSelectorMaker makeSelectorForSelector: #foo) equals: expectedSelector
]

{ #category : 'tests' }
TenuredSelectorMakerTest >> testMakeSelectorForSelectorBinary [

    | expectedSelector |
    expectedSelector := #_pretenured_ , tenuredSelectorMaker randomPrefix , '_' , 'zyIsf:'.
    self assert: (tenuredSelectorMaker makeSelectorForSelector: #'->') equals: expectedSelector
]

{ #category : 'tests' }
TenuredSelectorMakerTest >> testMakeSelectorForSelectorNotTransformSelectors [

    self assert: (tenuredSelectorMaker makeSelectorForSelector: #initialize) equals: #initialize.
    self assert: (tenuredSelectorMaker makeSelectorForSelector: #value:) equals: #value:.
    self assert: (tenuredSelectorMaker makeSelectorForSelector: #value:value:) equals: #value:value:.
    self assert: (tenuredSelectorMaker makeSelectorForSelector: #basicNewTenured) equals: #basicNewTenured.
    self assert: (tenuredSelectorMaker makeSelectorForSelector: #basicNewTenured:) equals: #basicNewTenured:.
    self assert: (tenuredSelectorMaker makeSelectorForSelector: #newTenured) equals: #newTenured.
    self assert: (tenuredSelectorMaker makeSelectorForSelector: #newTenured:) equals: #newTenured:
]

{ #category : 'tests' }
TenuredSelectorMakerTest >> testMapBinarySelectorToString [

	| result |
	result := tenuredSelectorMaker mapBinarySelectorToString: '->'.
	self assert: result equals: 'zyIsf'.

	result := tenuredSelectorMaker mapBinarySelectorToString: '==>'.
	self assert: result equals: 'cYzxU'.

	result := tenuredSelectorMaker mapBinarySelectorToString: '+'.
	self assert: result equals: 'vIeqd'.

	result := tenuredSelectorMaker mapBinarySelectorToString: '*'.
	self assert: result equals: 'qemed'.

	result := tenuredSelectorMaker mapBinarySelectorToString: ''.
	self assert: result equals: ''
]
