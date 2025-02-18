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

{ #category : 'defaults' }
TenuredSelectorMaker >> defaultTenuredSelector: aByteSymbol [

	^ #_pretenured_ , randomPrefix , '_' , aByteSymbol
]

{ #category : 'initialization' }
TenuredSelectorMaker >> initialize [

	super initialize.
	randomPrefix := (Random new nextInteger: 1000000000) asString
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
	aByteSymbol = #'->' ifTrue: [ ^ #'---->>>' ].
	aByteSymbol = #, ifTrue: [ ^ #,,, ].
	aByteSymbol = #/ ifTrue: [ ^ #///// ].
	aByteSymbol = #==> ifTrue: [ ^ #====>>> ].
	aByteSymbol = #@ ifTrue: [ ^ #@@@@ ].
	"This is necesary to not alter the message precedence"
	self flag: 'This is a hack. The real problem is that we will convert the binary to a keyword message this changing the evaluation order and breaking the code geeration.'.
	aByteSymbol isBinary ifTrue: [ ^ aByteSymbol , aByteSymbol , aByteSymbol , aByteSymbol ].

	^ self defaultTenuredSelector: aByteSymbol
]

{ #category : 'accessing' }
TenuredSelectorMaker >> randomPrefix [

	^ randomPrefix
]
