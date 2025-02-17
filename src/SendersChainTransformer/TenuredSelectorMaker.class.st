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

	"Special selector"
	aByteSymbol = #'->' ifTrue: [ ^ #_pretenured_ , randomPrefix , #_arrow: ].
	aByteSymbol = #, ifTrue: [ ^ #_pretenured_ , randomPrefix , #_comma: ].
	aByteSymbol = #/ ifTrue: [ ^ #_pretenured_ , randomPrefix , #_slash: ].
	aByteSymbol = #==> ifTrue: [ ^ #_pretenured_ , randomPrefix , #_super_arrow: ].
	aByteSymbol = #@ ifTrue: [ ^ #_pretenured_ , randomPrefix , #_arrobase: ].

	^ self defaultTenuredSelector: aByteSymbol
]

{ #category : 'accessing' }
TenuredSelectorMaker >> randomPrefix [

	^ randomPrefix
]
