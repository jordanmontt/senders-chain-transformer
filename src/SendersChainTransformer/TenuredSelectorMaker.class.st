Class {
	#name : 'TenuredSelectorMaker',
	#superclass : 'Object',
	#instVars : [
		'randomPrefix',
		'doNotTransformMethods',
		'doNotTransformSelectors'
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

    randomPrefix := (Random new nextInteger: 1000000000) asString.

    doNotTransformMethods := { BlockClosure>>#value. BlockClosure>>#value:. BlockClosure>>#value:value:.
        BlockClosure>>#value:value:value:. BlockClosure>>#value:value:value:value:.
        BlockClosure>>#valueNoContextSwitch. Semaphore>>#critical:. Mutex>>#critical: }.
    doNotTransformSelectors := #( #initialize #value #value: #value:value:)
]

{ #category : 'api' }
TenuredSelectorMaker >> isTenuredSelector: aSymbol [

	^ aSymbol includesSubstring: 'tenured' caseSensitive: false
]

{ #category : 'private' }
TenuredSelectorMaker >> makeSelector: aByeSymbol [
	
	"Allocator methods"
	aByeSymbol = #new ifTrue: [ ^ #newTenured ].
	aByeSymbol = #new: ifTrue: [ ^ #newTenured: ].
	aByeSymbol = #basicNew ifTrue: [ ^ #basicNewTenured ].
	aByeSymbol = #basicNew: ifTrue: [ ^ #basicNewTenured: ].

	aByeSymbol isBinary ifTrue: [ ^ self defaultTenuredBinarySelector: aByeSymbol ].
	^ self defaultTenuredSelector: aByeSymbol
]

{ #category : 'api' }
TenuredSelectorMaker >> makeSelectorForMethod: aCompiledMethod [

    | selector |
    selector := aCompiledMethod selector.

    (doNotTransformSelectors includes: selector) ifTrue: [ ^ selector ].
    (doNotTransformMethods includes: aCompiledMethod) ifTrue: [ ^ selector ].

    ^ self makeSelector: selector
]

{ #category : 'api' }
TenuredSelectorMaker >> makeSelectorForSelector: aSymbol [

    (doNotTransformSelectors includes: aSymbol) ifTrue: [ ^ aSymbol ].
    ^ self makeSelector: aSymbol
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
