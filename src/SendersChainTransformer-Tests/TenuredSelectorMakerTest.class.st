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
    expectedSelector := #_pretenured_foo.
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
    expectedSelector := #_pretenured_foo.
    self assert: (tenuredSelectorMaker makeSelectorForSelector: #foo) equals: expectedSelector
]

{ #category : 'tests' }
TenuredSelectorMakerTest >> testMakeSelectorForSelectorBinary [

    | expectedSelector |
    expectedSelector := #_pretenured_02D3E:.
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
	self assert: result equals: '02D3E'.

	result := tenuredSelectorMaker mapBinarySelectorToString: '==>'.
	self assert: result equals: '03D3D3E'.

	result := tenuredSelectorMaker mapBinarySelectorToString: '+'.
	self assert: result equals: '02B'.

	result := tenuredSelectorMaker mapBinarySelectorToString: '*'.
	self assert: result equals: '02A'.

	result := tenuredSelectorMaker mapBinarySelectorToString: ''.
	self assert: result equals: ''
]

{ #category : 'tests' }
TenuredSelectorMakerTest >> testMapStringToBinarySelectorIsInverse [
	"mapStringToBinarySelector: must be the exact inverse of mapBinarySelectorToString:."

	#( '+' '-' '*' '/' '<' '>' '=' '~' '&' '|' '@' '%' ',' '->' '==>' '<=' '>=' '//' )
		do: [ :binarySelector |
			| encoded |
			encoded := tenuredSelectorMaker mapBinarySelectorToString: binarySelector.
			self
				assert: (tenuredSelectorMaker mapStringToBinarySelector: encoded)
				equals: binarySelector asSymbol ]
]

{ #category : 'tests' }
TenuredSelectorMakerTest >> testUntenureSelectorBinaryRoundTrip [
	"Tenuring then untenuring a binary selector must recover the original selector."

	#( #+ #- #* #/ #< #> #= #~ #& #| #@ #% #, #'->' #'==>' #'<=' #'>=' #'//' )
		do: [ :binarySelector |
			| tenured |
			tenured := tenuredSelectorMaker makeSelectorForSelector: binarySelector.
			self
				assert: (tenuredSelectorMaker untenureSelector: tenured)
				equals: binarySelector ]
]

{ #category : 'tests' }
TenuredSelectorMakerTest >> testUntenureSelectorUnaryAndKeyword [
	"Unary and keyword selectors round-trip through the untouched (non-binary) path."

	self
		assert: (tenuredSelectorMaker untenureSelector: #_pretenured_foo)
		equals: #foo.
	self
		assert: (tenuredSelectorMaker untenureSelector: #_pretenured_at:put:)
		equals: #at:put:.
	self
		assert: (tenuredSelectorMaker untenureSelector:
				(tenuredSelectorMaker makeSelectorForSelector: #foo))
		equals: #foo.
	self
		assert: (tenuredSelectorMaker untenureSelector:
				(tenuredSelectorMaker makeSelectorForSelector: #at:put:))
		equals: #at:put:
]

{ #category : 'tests' }
TenuredSelectorMakerTest >> testUntenureSelectorFailsIfNotTenured [

	self should: [ tenuredSelectorMaker untenureSelector: #foo ] raise: Error
]
