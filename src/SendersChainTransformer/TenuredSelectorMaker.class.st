Class {
	#name : 'TenuredSelectorMaker',
	#superclass : 'Object',
	#instVars : [
		'randomPrefix'
	],
	#category : 'SendersChainTransformer-Code-Rewriter',
	#package : 'SendersChainTransformer',
	#tag : 'Code-Rewriter'
}

{ #category : 'internals' }
TenuredSelectorMaker >> defaultTenuredBinarySelector: aByteSymbol [

	^ self defaultTenuredSelector:
		  (self mapBinarySelectorToString: aByteSymbol) , ':'
]

{ #category : 'internals' }
TenuredSelectorMaker >> defaultTenuredSelector: aByteSymbol [

	^ #_pretenured_ , randomPrefix , '_' , aByteSymbol
]

{ #category : 'initialization' }
TenuredSelectorMaker >> initialize [

	super initialize.
	randomPrefix := (Random new nextInteger: 1000000000) asString
]

{ #category : 'api' }
TenuredSelectorMaker >> isTenuredSelector: aSymbol [

	^ aSymbol includesSubstring: 'tenured' caseSensitive: false
]

{ #category : 'api' }
TenuredSelectorMaker >> makeSelector: aByteSymbol [
	| specialSelectors |
	
	"Allocator methods"
	aByteSymbol = #new ifTrue: [ ^ #newTenured ].
	aByteSymbol = #new: ifTrue: [ ^ #newTenured: ].
	aByteSymbol = #basicNew ifTrue: [ ^ #basicNewTenured ].
	aByteSymbol = #basicNew: ifTrue: [ ^ #basicNewTenured: ].

	"Do not transform"
	specialSelectors := #( #initialize #value #valueNoContextSwitch #critical: ).
	(specialSelectors includes: aByteSymbol) ifTrue: [ ^ aByteSymbol ].

	aByteSymbol isBinary ifTrue: [ ^ self defaultTenuredBinarySelector: aByteSymbol ].

	^ self defaultTenuredSelector: aByteSymbol
]

{ #category : 'internals' }
TenuredSelectorMaker >> mapBinarySelectorToString: binarySelector [
	"Method that returns a string for a given another string. The important thing is that always produces the same string for the input and that the results are kind of unique."

	| alphabet base hash stream number |
	binarySelector ifEmpty: [ ^ binarySelector ].

	alphabet := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.
	base := alphabet size.
	hash := binarySelector hash abs.
	stream := WriteStream on: String new.
	number := hash.
	[ number > 0 ] whileTrue: [
			stream nextPut: (alphabet at: number \\ base + 1).
			number := number // base ].
	stream isEmpty ifTrue: [ ^ 'A' ].
	^ stream contents
]

{ #category : 'accessing' }
TenuredSelectorMaker >> randomPrefix [

	^ randomPrefix
]
