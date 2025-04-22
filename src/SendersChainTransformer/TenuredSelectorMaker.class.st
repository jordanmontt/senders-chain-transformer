Class {
	#name : 'TenuredSelectorMaker',
	#superclass : 'Object',
	#instVars : [
		'randomPrefix'
	],
	#category : 'SendersChainTransformer-Core',
	#package : 'SendersChainTransformer',
	#tag : 'Core'
}

{ #category : 'internals' }
TenuredSelectorMaker >> defaultTenuredSelector: aByteSymbol [

	^ #_pretenured_ , randomPrefix , '_' , aByteSymbol
]

{ #category : 'initialization' }
TenuredSelectorMaker >> initialize [

	super initialize.
	randomPrefix := (Random new nextInteger: 1000000000) asString
]

{ #category : 'internals' }
TenuredSelectorMaker >> isBinaryTenuredSelector: aSymbol [

	| partSize parts len |
	len := aSymbol size.
	len \\ 3 = 0 ifFalse: [ ^ false ].
	partSize := len // 3.
	parts := {
		(aSymbol copyFrom: 1 to: partSize).
		(aSymbol copyFrom: partSize + 1 to: partSize * 2).
		(aSymbol copyFrom: partSize * 2 + 1 to: len) }.

	^ parts allSatisfy: [ :each | each = parts first ]
]

{ #category : 'api' }
TenuredSelectorMaker >> isTenuredSelector: aSymbol [

	^ aSymbol isBinary
		  ifFalse: [ aSymbol includesSubstring: 'tenured' caseSensitive: false ]
		  ifTrue: [ self isBinaryTenuredSelector: aSymbol ]
]

{ #category : 'api' }
TenuredSelectorMaker >> makeSelector: aByteSymbol [
	
	"Allocator methods"
	aByteSymbol = #new ifTrue: [ ^ #newTenured ].
	aByteSymbol = #new: ifTrue: [ ^ #newTenured: ].
	aByteSymbol = #basicNew ifTrue: [ ^ #basicNewTenured ].
	aByteSymbol = #basicNew: ifTrue: [ ^ #basicNewTenured: ].
	
	"Methods called from the allocator methods"
	aByteSymbol = #initialize ifTrue: [ ^ #initialize ].

	"Primitives"
	aByteSymbol = #value ifTrue: [ ^ #value ].
	aByteSymbol = #valueNoContextSwitch ifTrue: [ ^ #valueNoContextSwitch ].
	aByteSymbol = #critical: ifTrue: [ ^ #critical: ].

	"Special selectors"
	aByteSymbol = #'->' ifTrue: [ ^ #'->' ].
	aByteSymbol = #, ifTrue: [ ^ #, ].
	aByteSymbol = #/ ifTrue: [ ^ #/ ].
	aByteSymbol = #==> ifTrue: [ ^ #==> ].
	aByteSymbol = #@ ifTrue: [ ^ #@ ].
	"This is necesary to not alter the message precedence"
	self flag: 'This is a hack. The real problem is that we will convert the binary to a keyword message this changing the evaluation order and breaking the code geeration.'.
	aByteSymbol isBinary ifTrue: [ ^ aByteSymbol , aByteSymbol , aByteSymbol ].

	^ self defaultTenuredSelector: aByteSymbol
]

{ #category : 'accessing' }
TenuredSelectorMaker >> randomPrefix [

	^ randomPrefix
]
