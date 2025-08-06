Class {
	#name : 'MethodWithOffsetSerializer',
	#superclass : 'Object',
	#category : 'SendersChainTransformer-Serializer',
	#package : 'SendersChainTransformer',
	#tag : 'Serializer'
}

{ #category : 'private' }
MethodWithOffsetSerializer >> asClassName: aString [

    | class |
    class := Smalltalk environment at: (aString substrings: ' ') first asSymbol.
    (aString includesSubstring: 'class') ifTrue: [ ^ class class ].
    ^ class
]

{ #category : 'api' }
MethodWithOffsetSerializer >> deserialize: aString [

	| deserializedArray methodsWithOffsets |
	deserializedArray := (NeoJSONReader fromString: aString).

	methodsWithOffsets := deserializedArray collect: [:anArray | 
			anArray collect: [ :aDict | 
				| compiledMethod offset |
				compiledMethod := OpalCompiler new
					class: (self asClassName: (aDict at: 'methodClass') asSymbol);
					source: (aDict at: 'sourceCode');
					compile.
				offset := NumberParser parse: (aDict at: 'offset').
				IllMethodWithOffset method: compiledMethod offset: offset ] ].
	^ methodsWithOffsets
]

{ #category : 'api' }
MethodWithOffsetSerializer >> serialize: anArray on: writeStream [

	| tempDict jsonString |
	tempDict := anArray collect: [ :array |
			array collect: [ :methodWithOffset | 
				{	'sourceCode' -> methodWithOffset method sourceCode.
					'methodClass' -> methodWithOffset methodClass name.
					'offset' -> methodWithOffset offset asString } asDictionary ] ].
	jsonString := NeoJSONWriter toStringPretty: tempDict.

	writeStream nextPutAll: jsonString.
	writeStream close
]
