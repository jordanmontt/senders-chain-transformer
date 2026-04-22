Class {
	#name : 'CompiledMethodToSourceCodeSerializer',
	#superclass : 'Object',
	#category : 'SendersChainTransformer-Serializer',
	#package : 'SendersChainTransformer',
	#tag : 'Serializer'
}

{ #category : 'private' }
CompiledMethodToSourceCodeSerializer >> asClassName: aString [

    | class |
    class := Smalltalk environment at: (aString substrings: ' ') first asSymbol.
    (aString includesSubstring: 'class') ifTrue: [ ^ class class ].
    ^ class
]

{ #category : 'api' }
CompiledMethodToSourceCodeSerializer >> deserialize: aString [

    | deserializedArray compiledMethods |
    deserializedArray := (NeoJSONReader fromString: aString).

    compiledMethods := deserializedArray collect: [:aDict | 
        OpalCompiler new
            class: (self asClassName: (aDict at: 'methodClass'));
            source: (aDict at: 'sourceCode');
            compile ].
    ^ compiledMethods
]

{ #category : 'api' }
CompiledMethodToSourceCodeSerializer >> serialize: anArrayOfCompiledMethods on: writeStream [

	| tempDict jsonString |
	tempDict := anArrayOfCompiledMethods collect: [ :aCompiledMethod |
			            { ('sourceCode' -> aCompiledMethod sourceCode).
				           ('methodClass' -> aCompiledMethod methodClass name) } asDictionary ].
	jsonString := NeoJSONWriter toStringPretty: tempDict.

	writeStream nextPutAll: jsonString.
	writeStream close
]
