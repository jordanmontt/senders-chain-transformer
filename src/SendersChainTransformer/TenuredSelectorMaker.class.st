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
	randomPrefix := (Random new nextInteger: 99999) asString
]

{ #category : 'api' }
TenuredSelectorMaker >> makeSelector: aByteSymbol [
	
	"Allocator methods"
	aByteSymbol = #new ifTrue: [ ^ #newTenured ].
	aByteSymbol = #new: ifTrue: [ ^ #newTenured: ].
	aByteSymbol = #basicNew ifTrue: [ ^ #basicNewTenured ].
	aByteSymbol = #basicNew: ifTrue: [ ^ #basicNewTenured: ].

	"Primitives"
	aByteSymbol = #value ifTrue: [ ^ #value ].

	"Special selector"
	aByteSymbol = #'->' ifTrue: [ ^ #_pretenured_ , randomPrefix , #_arrow: ].

	^ self defaultTenuredSelector: aByteSymbol
]

{ #category : 'accessing' }
TenuredSelectorMaker >> randomPrefix [

	^ randomPrefix
]
