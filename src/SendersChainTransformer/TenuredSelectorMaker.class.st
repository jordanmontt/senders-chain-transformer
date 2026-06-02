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

    doNotTransformSelectors := #( #newTenured #newTenured: #basicNewTenured #basicNewTenured: #initialize #value #value: #value:value: #shallowCopy #clone #valueNoContextSwitch #@ )
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
	"The encoding starts by a leading '0'.
	The leading digit is what lets #untenureSelector: know is an encoded binary selector.
	See #mapStringToBinarySelector: for the inverse."

	| stream |
	stream := WriteStream on: String new.
	stream nextPut: $0.
	binarySelector do: [ :char | stream nextPutAll: char hex ].
	^ stream contents asSymbol
]

{ #category : 'internals' }
TenuredSelectorMaker >> mapStringToBinarySelector: aString [
	"Inverse of #mapBinarySelectorToString:. Drops the leading marker 0"

    | hexPart stream |
    hexPart := aString allButFirst.
    stream := WriteStream on: String new.
    (hexPart splitOn: '16r') allButFirst do: [ :hex |
        | integerValue |
        integerValue := NumberParser parse: ('16r' , hex).
        stream nextPut: (Character value: integerValue) ].
    ^ stream contents asSymbol
]

{ #category : 'api' }
TenuredSelectorMaker >> untenureSelector: aSymbol [

   | core |
   (self isTenuredSelector: aSymbol) ifFalse: [ self error: 'The selector #' , aSymbol , ' is not tenured.' ].

   core := aSymbol allButFirst: #_pretenured_ size.
   "An encoded binary selector starts with a digit 0 always."
   ^ core first isDigit
        ifTrue: [ self mapStringToBinarySelector: core allButLast ]
        ifFalse: [ core asSymbol ]
]
