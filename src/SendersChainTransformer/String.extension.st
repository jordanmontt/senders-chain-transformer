Extension { #name : 'String' }

{ #category : '*SendersChainTransformer' }
String class >> newTenured: sizeRequested [
	"Return a new instance with the number of indexable variables specified by the argument."

	^ self == String
		  ifTrue: [ ByteString newTenured: sizeRequested ]
		  ifFalse: [ self basicNew: sizeRequested ]
]
