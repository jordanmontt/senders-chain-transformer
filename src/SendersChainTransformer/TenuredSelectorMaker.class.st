Class {
	#name : 'TenuredSelectorMaker',
	#superclass : 'Object',
	#instVars : [
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

	^ #_pretenured_ , aByteSymbol
]

{ #category : 'initialization' }
TenuredSelectorMaker >> initialize [

    super initialize.

    doNotTransformMethods := { BlockClosure>>#value. BlockClosure>>#value:. BlockClosure>>#value:value:.
        BlockClosure>>#value:value:value:. BlockClosure>>#value:value:value:value:.
        BlockClosure>>#valueNoContextSwitch. Semaphore>>#critical:. Mutex>>#critical:. Behavior>>#basicNewTenured. Behavior>>#basicNewTenured:. Behavior>>#newTenured. Behavior>>#newTenured: .
BlockClosure >> #valueNoContextSwitch }.

    doNotTransformSelectors := #( #newTenured #newTenured: #basicNewTenured #basicNewTenured: #initialize #value #value: #value:value: #shallowCopy #clone #valueNoContextSwitch )
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
	"Encode a binary selector into a reversible, identifier-safe string.
	The encoding is a leading '0' marker followed by two uppercase hex digits per
	character. The leading digit is what lets #untenureSelector: tell an encoded
	binary selector apart from a plain unary/keyword selector, since real selectors
	can never start with a digit. See #mapStringToBinarySelector: for the inverse."

	| stream |
	binarySelector ifEmpty: [ ^ binarySelector ].

	stream := WriteStream on: String new.
	stream nextPut: $0.
	binarySelector do: [ :char |
			| hex |
			hex := char asInteger printString: 16.
			hex size = 1 ifTrue: [ hex := '0' , hex ].
			stream nextPutAll: hex ].
	^ stream contents
]

{ #category : 'internals' }
TenuredSelectorMaker >> mapStringToBinarySelector: aString [
	"Inverse of #mapBinarySelectorToString:. Drops the leading marker and decodes
	each following pair of hex digits back into a character."

	| hexPart stream |
	aString ifEmpty: [ ^ aString asSymbol ].

	hexPart := aString allButFirst.
	stream := WriteStream on: String new.
	1 to: hexPart size by: 2 do: [ :i |
			| pair |
			pair := hexPart copyFrom: i to: i + 1.
			stream nextPut: (Character value: ('16r' , pair) asNumber) ].
	^ stream contents asSymbol
]

{ #category : 'api' }
TenuredSelectorMaker >> untenureSelector: aSymbol [

	| core |
	(self isTenuredSelector: aSymbol) ifFalse: [ self error: 'The selector #', aSymbol , ' is not tenured.' ].

	core := aSymbol allButFirst: #_pretenured_ size.

	"An encoded binary selector's core starts with a digit (the marker) and ends with
	the ':' added by #defaultTenuredBinarySelector:. A real unary/keyword selector can
	never start with a digit, so this branch is unambiguous."
	(core notEmpty and: [ core first isDigit ]) ifTrue: [
		^ self mapStringToBinarySelector: core allButLast ].

	^ core asSymbol
]
