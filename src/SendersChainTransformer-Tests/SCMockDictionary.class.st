Class {
	#name : 'SCMockDictionary',
	#superclass : 'Dictionary',
	#category : 'SendersChainTransformer-Tests-Utilities',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Utilities'
}

{ #category : 'automatically-generated' }
SCMockDictionary >> at: key ifAbsent: aBlock [
	"Answer the value associated with the key or, if key isn't found,
	answer the result of evaluating aBlock."

	^((array at: (self findElementOrNil: key))
			ifNil: [aBlock]
			ifNotNil: [:assoc | assoc]) value
]

{ #category : 'automatically-generated' }
SCMockDictionary >> at: key ifAbsentPut: aBlock [
	"Return the value at the given key.
	If the key is not included in the receiver store and return the result
	of evaluating aBlock as the new value."

	^ self at: key ifAbsent: [self at: key put: aBlock value]
]

{ #category : 'automatically-generated' }
SCMockDictionary >> at: key put: anObject [
	"Set the value at key to be anObject.  If key is not found, create a
	new entry for key and set is value to anObject. Answer anObject."

	| index assoc |
	index := self findElementOrNil: key.
	assoc := array at: index.
	assoc
		ifNil: [self atNewIndex: index put: (SCMockAssociation key: key value: anObject)]
		ifNotNil: [assoc value: anObject].
	^ anObject
]
